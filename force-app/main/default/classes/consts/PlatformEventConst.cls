public with sharing class PlatformEventConst {
    public ExternalComplaintApprovalStatus EXTERNAL_COMPLAINT_APPROVAL_STATUS { get {return new ExternalComplaintApprovalStatus();}}

    @AuraEnabled(Cacheable=true)
    public static String getExternalComplaintApprovalStatusChannel() {
        return new PlatformEventChannelNameConst().EXTERNAL_COMPLAINT_APPROVAL_STATUS;
    }

    public class PlatformEventChannelNameConst {
        public final String EXTERNAL_COMPLAINT_APPROVAL_STATUS { get {return '/event/External_Complaint_Approval_Status__e';} }
    }

    @AuraEnabled(Cacheable=true)
    public static String getExternalComplaintApprovalStatus_StatusSuccess() {
        return new ExternalComplaintApprovalStatus_Status().SUCCESS;
    }

    @AuraEnabled(Cacheable=true)
    public static String getExternalComplaintApprovalStatus_StatusFailed() {
        return new ExternalComplaintApprovalStatus_Status().FAILED;
    }
    public class ExternalComplaintApprovalStatus {
        public PlatformEventChannelNameConst CHANNEL_NAME { get {return new PlatformEventChannelNameConst();} }
        public ExternalComplaintApprovalStatus_Status STATUS { get {return new ExternalComplaintApprovalStatus_Status();}}
    }

    public class ExternalComplaintApprovalStatus_Status {
        public final String SUCCESS { get {return 'SUCCESS';} }
        public final String FAILED { get {return 'FAILED';} }
    }
}