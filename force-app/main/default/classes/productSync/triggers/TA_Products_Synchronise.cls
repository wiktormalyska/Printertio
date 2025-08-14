public with sharing class TA_Products_Synchronise implements TriggerAction.BeforeInsert, TriggerAction.AfterInsert, TriggerAction.AfterUpdate, TriggerAction.BeforeDelete {

    public void beforeInsert(List<Product2> triggerNew) {
        System.debug('Trigger beforeInsert called');
        for (Product2 product : triggerNew) {
            if (product.IsSentFromOther__c == true) {
                product.isExternal__c = true;
                product.IsSentFromOther__c = false;
            }
        }
    }

    public void afterInsert(List<SObject> triggerNew) {
        System.debug('Trigger afterInsert called');

        List<Id> productIds = new List<Id>();
        for (SObject productObj : Trigger.new) {
            Product2 product = (Product2) productObj;
            if (product.IsExternal__c != true) {
                productIds.add(product.Id);
            }
        }
        if (!productIds.isEmpty()) {
            System.enqueueJob(new ProductSyncQueueable(productIds));
        }
    }

    public void afterUpdate(List<Product2> triggerNew, List<Product2> triggerOld) {
        System.debug('Trigger afterUpdate called');

        List<Id> productIds = new List<Id>();
        for (Integer i = 0; i < triggerNew.size(); i++) {
            Product2 newProduct = (Product2) triggerNew[i];
            Product2 oldProduct = (Product2) triggerOld[i];

            if (isUserModification(newProduct, oldProduct)) {
                productIds.add(newProduct.Id);
            }
        }

        if (!productIds.isEmpty()) {
            System.enqueueJob(new ProductSyncQueueable(productIds));
        }
    }

    public void beforeDelete(List<SObject> triggerOld) {
        System.debug('Trigger beforeDelete called');

        List<Product_Deactivation__e> events = new List<Product_Deactivation__e>();

        for (SObject productObject : triggerOld) {
            Product2 product = (Product2) productObject;
            if (product.IsExternal__c != true) {
                events.add(new Product_Deactivation__e(Product_Id__c = product.Id));
                product.addError('Deletion prevented. Product will be deactivated instead.');
            }
        }
        if (!events.isEmpty()) {
            System.debug('Publishing events for productIds: ' + events.size());
            EventBus.publish(events);
        }
    }

    public Boolean isUserModification(Product2 newProduct, Product2 oldProduct) {
        if (oldProduct.IsExternal__c != true && newProduct.IsExternal__c == true) {
            return false;
        }
        Boolean nameChanged = newProduct.Name != oldProduct.Name;
        Boolean codeChanged = newProduct.ProductCode != oldProduct.ProductCode;
        Boolean descChanged = newProduct.Description != oldProduct.Description;
        Boolean activeChanged = newProduct.IsActive != oldProduct.IsActive;
        Boolean externalChanged = newProduct.IsExternal__c != oldProduct.IsExternal__c;
        Boolean externalIdChanged = newProduct.ExternalId != oldProduct.ExternalId;

        if (!nameChanged && !codeChanged && !descChanged && !activeChanged && !externalChanged && !externalIdChanged) {
            System.debug('Only IsSentFromOther__c flag changed, skipping synchronization for product: ' + newProduct.Name);
            return false;
        }

        return true;
    }
}