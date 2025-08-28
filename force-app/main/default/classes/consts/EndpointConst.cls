public with sharing class EndpointConst {
    public final String COMPOSITE_SOBJECTS { get {return '/services/data/v64.0/composite/sobjects/';} }
    public final String COMPOSITE { get {return '/services/data/v64.0/composite/';} }
    public final String QUERY { get {return '/services/data/v64.0/query/?q=';} }
    public PlatformEventEndpoints PLATFORM_EVENTS { get {return new PlatformEventEndpoints();} }
    public SObjectEndpoints SOBJECTS { get {return new SObjectEndpoints();} }

    public class PlatformEventEndpoints {
        public final String EXTERNAL_COMPLAINT_APPROVAL_STATUS = '/services/data/v61.0/sobjects/External_Complaint_Approval_Status__e/';
        public final String EXTERNAL_COMPLAINT = '/services/data/v61.0/sobjects/External_Complaint__e/';
    }

    public class SObjectEndpoints {
        public final String COMPLAINT_APPROVAL_REQUEST_C { get {return '/services/data/v64.0/sobjects/Complaint_Approval_Request__c/';} }
    }
}