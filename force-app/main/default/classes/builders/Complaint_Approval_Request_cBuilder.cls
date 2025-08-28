public with sharing class Complaint_Approval_Request_cBuilder {
    private Complaint_Approval_Request__c complaintApprovalRequest;

    private Complaint_Approval_Request_cBuilder() {
        complaintApprovalRequest = new Complaint_Approval_Request__c();
    }

    public static Complaint_Approval_Request_cBuilder create() {
        return new Complaint_Approval_Request_cBuilder();
    }

    public Complaint_Approval_Request_cBuilder withCase(Id caseId) {
        complaintApprovalRequest.Case__c = caseId;
        return this;
    }

    public Complaint_Approval_Request_cBuilder withProduct(Id productId) {
        complaintApprovalRequest.Product__c = productId;
        return this;
    }

    public Complaint_Approval_Request_cBuilder withStatus(String status) {
        complaintApprovalRequest.Status__c = status;
        return this;
    }

    public Complaint_Approval_Request_cBuilder withIsExternal(Boolean isExternal) {
        complaintApprovalRequest.Is_External__c = isExternal;
        return this;
    }

    public Complaint_Approval_Request_cBuilder withExternalId(String externalId) {
        complaintApprovalRequest.External_ID__c = externalId;
        return this;
    }

    public Complaint_Approval_Request_cBuilder withAmountToRefund(Decimal amount) {
        complaintApprovalRequest.Amount_To_Refund__c = amount;
        return this;
    }

    public Complaint_Approval_Request__c build() {
        return complaintApprovalRequest;
    }
}