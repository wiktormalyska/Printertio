trigger ExternalComplaintEventTrigger on External_Complaint__e (after insert) {
    System.debug('Trigger after insert ExternalComplaintEventTrigger');
    new MetadataTriggerHandler().run();
}