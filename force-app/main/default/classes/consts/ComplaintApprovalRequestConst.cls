public with sharing class ComplaintApprovalRequestConst {
    public ComplaintApprovalRequestConst_Status STATUS { get {return new ComplaintApprovalRequestConst_Status();}}
    public final String PROCESS_DEFINITION_NAME { get {return 'Approving_Complaint';}}

    public class ComplaintApprovalRequestConst_Status{
        public final String PENDING_APPROVAL { get {return 'Pending Approval';}}
    }

}