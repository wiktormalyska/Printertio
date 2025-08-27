public with sharing class ComplaintApprovalRequestConst {
    public ComplaintApprovalRequestConst_Status STATUS { get {return new ComplaintApprovalRequestConst_Status();}}
    public final String PROCESS_DEFINITION_NAME { get {return 'Complaint_Approval_Process';}}

    public class ComplaintApprovalRequestConst_Status{
        public final String PENDING_APPROVAL { get {return 'Pending Approval';}}
        public final String WAITING_FOR_RESPONSE_FROM_EXTERNAL_SOURCE { get {return 'Waiting for response from external source';}}
    }

}