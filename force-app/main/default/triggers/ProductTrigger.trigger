trigger ProductTrigger on Product2 (before delete, after insert, after update, before insert ) {
    new MetadataTriggerHandler().run();
}