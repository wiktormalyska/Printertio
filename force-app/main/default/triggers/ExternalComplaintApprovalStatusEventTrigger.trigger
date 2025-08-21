trigger ExternalComplaintApprovalStatusEventTrigger on External_Complaint_Approval_Status__e (after insert) {
    System.debug('Trigger after insert ExternalComplaintApprovalStatusEventTrigger');
    new MetadataTriggerHandler().run();
}