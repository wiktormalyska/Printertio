public with sharing class TA_Products_Synchronise implements TriggerAction.AfterInsert, TriggerAction.AfterUpdate, TriggerAction.BeforeDelete {
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

    public void afterUpdate(List<SObject> triggerNew, List<SObject> triggerOld) {
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

    private Boolean isUserModification(Product2 newProduct, Product2 oldProduct) {
        if (oldProduct.IsExternal__c != true && newProduct.IsExternal__c == true) {
            return false;
        }
        return true;
    }
}