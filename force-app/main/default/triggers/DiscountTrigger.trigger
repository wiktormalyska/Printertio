trigger DiscountTrigger on Discount__c (after insert, after update, after delete) {
    new MetadataTriggerHandler().run();
}