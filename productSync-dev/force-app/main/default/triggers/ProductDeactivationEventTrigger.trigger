trigger ProductDeactivationEventTrigger on Product_Deactivation__e (after insert) {
    List<Id> productIds = new List<Id>();

    for (Product_Deactivation__e event : Trigger.new) {
        productIds.add(Id.valueOf(event.Product_Id__c));
    }

    System.debug('Processing deactivation events for: ' + productIds);
    System.enqueueJob(new ProductDeactivateQueueable(productIds));
}