public with sharing class EndpointConst {
    public final String COMPOSITE { get {return '/services/data/v64.0/composite/sobjects/';} }
    public PlatformEventEndpoints PLATFORM_EVENTS { get {return new PlatformEventEndpoints();} }

    public class PlatformEventEndpoints {
        public final String EXTERNAL_COMPLAINT_APPROVAL_STATUS = '/services/data/v61.0/sobjects/External_Complaint_Approval_Status__e/';
        public final String EXTERNAL_COMPLAINT = '/services/data/v61.0/sobjects/External_Complaint__e/';
    }
}