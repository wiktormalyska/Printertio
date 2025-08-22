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

        List<Approval.ProcessSubmitRequest> internalApprovalRequests = new List<Approval.ProcessSubmitRequest>();
        List<Product2> externalComplaintEvents = new List<Product2>();

        Case caseForComplaint = new Case(
                Order__c = itemsToProcess[0].OrderId
        );
        insert caseForComplaint;

        List<Complaint_Approval_Request__c> complaintApprovalRequests = new List<Complaint_Approval_Request__c>();

        for (OrderItem item : itemsToProcess) {
            if (item.Product2.IsExternal__c) {
                externalComplaintEvents.add(item.Product2);
            } else {
                Complaint_Approval_Request__c complaintApprovalRequest = new Complaint_Approval_Request__c();
                complaintApprovalRequest.Case__c = caseForComplaint.Id;
                complaintApprovalRequest.Status__c = ConstUtil.COMPLAINT_APPROVAL_REQUEST_CONST.STATUS.PENDING_APPROVAL;
                complaintApprovalRequest.Product__c = item.Product2Id;
                complaintApprovalRequests.add(complaintApprovalRequest);
            }
        }
        insert complaintApprovalRequests;

        for (Complaint_Approval_Request__c complaintApprovalRequest: complaintApprovalRequests) {
            Approval.ProcessSubmitRequest request = new Approval.ProcessSubmitRequest();
            request.setObjectId(complaintApprovalRequest.Id);
            request.setProcessDefinitionNameOrId(ConstUtil.COMPLAINT_APPROVAL_REQUEST_CONST.PROCESS_DEFINITION_NAME);
            internalApprovalRequests.add(request);
        }
        System.debug(internalApprovalRequests);
        try {
            if (!internalApprovalRequests.isEmpty()) {
                Approval.ProcessResult[] processResults = Approval.process(internalApprovalRequests, false);
                for (Approval.ProcessResult processResult : processResults) {
                    if (!processResult.success) {
                        throw new AuraHandledException(System.Label.Error_creating_approval_request+processResult.getErrors());
                    }
                }
                System.debug(processResults);
            }

            UUID randomUUID = UUID.randomUUID();
            if (!externalComplaintEvents.isEmpty()) {
                ExternalComplaintCallout.sendComplaintsAsync(externalComplaintEvents, randomUUID);
            }
            return new ComplaintSubmissionResult(caseForComplaint.Id, randomUUID?.toString());
        } catch (Exception e) {
            throw new AuraHandledException(System.Label.Error_creating_approval_request+ e.getMessage());
        }
    }
}