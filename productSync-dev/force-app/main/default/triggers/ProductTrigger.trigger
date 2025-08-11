trigger ProductTrigger on Product2 (before delete, after insert, after update) {
    new MetadataTriggerHandler().run();
}