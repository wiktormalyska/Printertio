trigger ExternalComplaintApprovalStatusEventTrigger on External_Complaint_Approval_Status__e (after insert) {
    new MetadataTriggerHandler().run();
}