public with sharing class SendToSecondOrgFlowAction {

    @InvocableMethod(label='Send Complaint to Second Org' description='Sends complaint approval request to second org')
    public static List<SendToSecondOrgResult> sendComplaintToSecondOrg(List<SendToSecondOrgRequest> requests) {
        List<SendToSecondOrgResult> results = new List<SendToSecondOrgResult>();

        for (SendToSecondOrgRequest request : requests) {
            SendToSecondOrgResult result = new SendToSecondOrgResult();
            try {
                Complaint_Approval_Request__c complaintRequest = [
                        SELECT Id, Case__c, Product__c, Status__c, Is_External__c, External_ID__c,
                                Product__r.Name, Product__r.ProductCode, Product__r.ExternalId,
                                Case__r.CaseNumber, Case__r.Order__c, Amount_To_Refund__c
                        FROM Complaint_Approval_Request__c
                        WHERE Id = :request.complaintApprovalRequestId
                        LIMIT 1
                ];

                sendUpdateCompositeTo2ndOrg(complaintRequest);
                result.isSuccess = true;

            } catch (Exception e) {
                result.isSuccess = false;
                result.message = System.Label.Error_sending_to_second_org + e.getMessage();
                throw new AuraHandledException(result.message);
            }
            results.add(result);
        }

        return results;
    }

    private static void sendUpdateCompositeTo2ndOrg(Complaint_Approval_Request__c complaintRequest) {
        String httpMethod = 'PATCH';
        String recordUrl = ConstUtil.ENDPOINT.SOBJECTS.COMPLAINT_APPROVAL_REQUEST__C + complaintRequest.External_ID__c;

        Map<String, Object> bodyMap = new Map<String, Object>{
                Complaint_Approval_Request__c.Status__c.toString() => complaintRequest.Status__c,
                Complaint_Approval_Request__c.Amount_To_Refund__c.toString() => complaintRequest.Amount_To_Refund__c
        };

        List<Complaint_CompositeRequestQueueable.CompositeSubRequest> subRequests =
                new List<Complaint_CompositeRequestQueueable.CompositeSubRequest>();

        subRequests.add(
                new Complaint_CompositeRequestQueueable.CompositeSubRequest(
                        httpMethod,
                        recordUrl,
                        complaintRequest.Id,
                        bodyMap
                )
        );
        System.enqueueJob(new Complaint_CompositeRequestQueueable(subRequests));
    }

    //Flow Properties
    public class SendToSecondOrgRequest {
        @InvocableVariable(label='Complaint Approval Request ID' required=true)
        public String complaintApprovalRequestId;
    }

    public class SendToSecondOrgResult {
        @InvocableVariable
        public Boolean isSuccess;

        @InvocableVariable
        public String message;
    }
}