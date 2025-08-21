public with sharing class ComplaintFormService {
    public static List<OrderItem> getOrderItemsFromOrderId(Id orderId) {
        List<OrderItem> orderItems = [
                SELECT Id, OrderId, Quantity, Product2.ProductCode, Product2.Name, TotalPrice, Product2.IsExternal__c
                FROM OrderItem
                WHERE OrderId = :orderId
        ];
        System.debug(orderItems);
        return orderItems;
    }

    public static ComplaintSubmissionResult submitComplaintForApproval(List<Id> orderItemIds) {
        System.debug(orderItemIds);
        if (orderItemIds == null || orderItemIds.isEmpty()) {
            throw new AuraHandledException('You must select at least one product.');
        }

        List<OrderItem> itemsToProcess = [
                SELECT Id, OrderId, Product2.IsExternal__c, Product2.ExternalId
                FROM OrderItem
                WHERE Id IN :orderItemIds
        ];
        System.debug(itemsToProcess);

        List<Approval.ProcessSubmitRequest> internalApprovalRequests = new List<Approval.ProcessSubmitRequest>();
        List<Product2> externalComplaintEvents = new List<Product2>();

        Case caseForComplaint = new Case(
                Order__c = itemsToProcess[0].OrderId
        );
        insert caseForComplaint;
        System.debug(caseForComplaint);

        List<Complaint_Approval_Request__c> complaintApprovalRequests = new List<Complaint_Approval_Request__c>();

        for (OrderItem item : itemsToProcess) {
            if (item.Product2.IsExternal__c) {
                externalComplaintEvents.add(item.Product2);
            } else {
                Complaint_Approval_Request__c complaintApprovalRequest = new Complaint_Approval_Request__c();
                complaintApprovalRequest.Case__c = caseForComplaint.Id;
                complaintApprovalRequest.Status__c = 'Pending Approval';
                complaintApprovalRequest.Product__c = item.Product2Id;
                complaintApprovalRequests.add(complaintApprovalRequest);
            }
        }
        System.debug(complaintApprovalRequests);
        insert complaintApprovalRequests;

        for (Complaint_Approval_Request__c complaintApprovalRequest: complaintApprovalRequests) {
            Approval.ProcessSubmitRequest request = new Approval.ProcessSubmitRequest();
            request.setObjectId(complaintApprovalRequest.Id);
            request.setProcessDefinitionNameOrId('Approving_Complaint');
            internalApprovalRequests.add(request);
        }
        System.debug(internalApprovalRequests);
        try {
            if (!internalApprovalRequests.isEmpty()) {
                Approval.ProcessResult[] processResults = Approval.process(internalApprovalRequests, false);
                for (Approval.ProcessResult processResult : processResults) {
                    if (!processResult.success) {
                        throw new AuraHandledException('Error creating approval request: '+processResult.getErrors());
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
            throw new AuraHandledException('Error processing complaint: ' + e.getMessage());
        }
    }
}