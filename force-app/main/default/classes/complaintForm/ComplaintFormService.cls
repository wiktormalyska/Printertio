public with sharing class ComplaintFormService {
    public static List<OrderItem> getOrderItemsFromOrderId(Id orderId) {
        List<OrderItem> orderItems = [
                SELECT Id, OrderId, Quantity, Product2.ProductCode, Product2.Name, TotalPrice, Product2.IsExternal__c
                FROM OrderItem
                WHERE OrderId = :orderId
        ];
        return orderItems;
    }

    public static ComplaintSubmissionResult submitComplaintForApproval(List<Id> orderItemIds) {
        if (orderItemIds == null || orderItemIds.isEmpty()) {
            throw new AuraHandledException(System.Label.You_must_select_at_least_one_product);
        }

        List<OrderItem> itemsToProcess = [
                SELECT Id, OrderId, Product2.IsExternal__c, Product2.ExternalId
                FROM OrderItem
                WHERE Id IN :orderItemIds
        ];


        Case caseForComplaint = new Case(
                Order__c = itemsToProcess[0].OrderId
        );
        insert caseForComplaint;

        List<Complaint_Approval_Request__c> complaintApprovalRequests = new List<Complaint_Approval_Request__c>();

        for (OrderItem item : itemsToProcess) {
            Complaint_Approval_Request__c complaintApprovalRequest = new Complaint_Approval_Request__c();
            complaintApprovalRequest.Case__c = caseForComplaint.Id;
            complaintApprovalRequest.Status__c = ConstUtil.COMPLAINT_APPROVAL_REQUEST_CONST.STATUS.PENDING_APPROVAL;
            complaintApprovalRequest.Product__c = item.Product2Id;
            if (item.Product2.IsExternal__c) {
                complaintApprovalRequest.Is_External__c = true;
                complaintApprovalRequest.Status__c = ConstUtil.COMPLAINT_APPROVAL_REQUEST_CONST.STATUS.WAITING_FOR_RESPONSE_FROM_EXTERNAL_SOURCE;
            }
            complaintApprovalRequests.add(complaintApprovalRequest);
        }
        try {
            if (!complaintApprovalRequests.isEmpty()) {
                insert complaintApprovalRequests;
                String flowApiName = ConstUtil.COMPLAINT_APPROVAL_REQUEST_CONST.PROCESS_DEFINITION_NAME;

                for (Complaint_Approval_Request__c requestToSubmit : complaintApprovalRequests) {
                    Map<String, Object> params = new Map<String, Object>();
                    params.put('recordId', requestToSubmit.Id);
                    params.put('submitter', UserInfo.getUserId());
                    Flow.Interview.createInterview(flowApiName, params).start();
                }
            }
            //Product, Id of complaintApprovalRequest
            Map<String, String> externalComplaintEvents = new Map<String, String>();
            for (Complaint_Approval_Request__c complaintApprovalRequest : complaintApprovalRequests) {
                if (complaintApprovalRequest.Is_External__c) {
                    externalComplaintEvents.put(complaintApprovalRequest.Product__c, complaintApprovalRequest.Id);
                }
            }
            UUID randomUUID = UUID.randomUUID();
            if (!externalComplaintEvents.isEmpty()) {
                ExternalComplaintCallout.sendComplaintsAsync(externalComplaintEvents, randomUUID);
            }
            return new ComplaintSubmissionResult(caseForComplaint.Id, randomUUID?.toString());
        } catch (Exception e) {
            throw new AuraHandledException(System.Label.Error_creating_approval_request + e.getMessage());
        }
    }
}