public with sharing class TA_Products_Synchronise implements TriggerAction.BeforeInsert, TriggerAction.AfterInsert, TriggerAction.AfterUpdate, TriggerAction.BeforeDelete {

    public void beforeInsert(List<Product2> triggerNew) {
        System.debug('Reqinfo '+Request.getCurrent());
        Request reqInfo = Request.getCurrent();
        System.debug('Reqinfoquid '+reqInfo?.getQuiddity());
        for (Product2 product : triggerNew) {
            if (product.IsSentFromOther__c == true) {
                product.isExternal__c = true;
                product.IsSentFromOther__c = false;
            }
        }
    }

    public void afterInsert(List<SObject> triggerNew) {
        List<Id> productIds = new List<Id>();
        for (SObject productObj : Trigger.new) {
            Product2 product = (Product2) productObj;
            if (product.IsExternal__c == false) {
                productIds.add(product.Id);
            }
        }
        if (!productIds.isEmpty()) {
            ProductSyncMassUtil.synchronizeMassProducts(productIds);
        }
    }

    public void afterUpdate(List<Product2> triggerNew, List<Product2> triggerOld) {
        List<Id> productIds = new List<Id>();
        for (Integer i = 0; i < triggerNew.size(); i++) {
            Product2 newProduct = (Product2) triggerNew[i];
            Product2 oldProduct = (Product2) triggerOld[i];

            if (isUserModification(newProduct, oldProduct)) {
                productIds.add(newProduct.Id);
            }
        }

        if (!productIds.isEmpty()) {
            ProductSyncMassUtil.synchronizeMassProducts(productIds);
        }
    }

    public void beforeDelete(List<SObject> triggerOld) {

        List<Product_Deactivation__e> events = new List<Product_Deactivation__e>();

        for (SObject productObject : triggerOld) {
            Product2 product = (Product2) productObject;
            if (product.IsExternal__c == false) {
                events.add(new Product_Deactivation__e(Product_Id__c = product.Id));
                product.addError('Deletion prevented. Product will be deactivated instead.');
            }
        }
        if (!events.isEmpty()) {
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
        Boolean productFamilyChanged = newProduct.Family != oldProduct.Family;

        if (!nameChanged && !codeChanged && !descChanged && !activeChanged && !externalChanged && !externalIdChanged && !productFamilyChanged) {
            return false;
        }

        return true;
    }
}