public with sharing class TA_ExternalComplaint implements TriggerAction.AfterInsert {
    public void afterInsert(List<External_Complaint__e> triggerNew) {
        if (!triggerNew.isEmpty()) {
            createComplaintCases(triggerNew);
        }
    }

    private void createComplaintCases(List<External_Complaint__e> events) {
        Case newCase = new Case(
                Is_External__c = true
        );
        insert newCase;

        List<Id> productIds = new List<Id>();
        String randomUUID;
        for (External_Complaint__e event : events) {
            productIds.add(event.Product_ID__c);
            if (event.External_Complaint_Request_ID__c != null) {
                randomUUID = event.External_Complaint_Request_ID__c;
            }
        }
        List<Product2> products = [
                SELECT Id, Name, ExternalId
                FROM Product2
                WHERE Id IN :productIds
        ];

        Map<String, Product2> productMap = new Map<String, Product2>();
        for (Product2 product : products) {
            productMap.put(product.Id, product);
        }

        List<Complaint_Approval_Request__c> complaintApprovalRequests = new List<Complaint_Approval_Request__c>();

        for (External_Complaint__e event : events) {
            Product2 product = productMap.get(event.Product_ID__c);
            if (product != null) {
                Complaint_Approval_Request__c complaintApprovalRequest = new Complaint_Approval_Request__c(
                        Case__c = newCase.Id,
                        Product__c = product.Id,
                        Status__c = ConstUtil.COMPLAINT_APPROVAL_REQUEST_CONST.STATUS.PENDING_APPROVAL
                );
                complaintApprovalRequests.add(complaintApprovalRequest);
            }
        }
        insert complaintApprovalRequests;

        List<Approval.ProcessSubmitRequest> internalApprovalRequests = new List<Approval.ProcessSubmitRequest>();
        for (Complaint_Approval_Request__c complaintApprovalRequest : complaintApprovalRequests) {
            Approval.ProcessSubmitRequest request = new Approval.ProcessSubmitRequest();
            request.setObjectId(complaintApprovalRequest.Id);
            request.setProcessDefinitionNameOrId(ConstUtil.COMPLAINT_APPROVAL_REQUEST_CONST.PROCESS_DEFINITION_NAME);
            internalApprovalRequests.add(request);
        }

        try {
            Approval.ProcessResult[] processResults = Approval.process(internalApprovalRequests, false);
            Boolean allSuccess = true;
            for (Approval.ProcessResult processResult : processResults) {
                if (!processResult.success) {
                    allSuccess = false;
                    throw new DmlException(System.Label.Error_creating_approval_request + processResult.getErrors());
                }
            }

            if (allSuccess) {
                ExternalComplaintApprovalStatusCallout.sendComplaintApprovalStatusesAsync(
                        ConstUtil.PLATFORM_EVENTS.EXTERNAL_COMPLAINT_APPROVAL_STATUS.STATUS.SUCCESS,
                        randomUUID);
            }
        } catch (Exception e) {
            throw new CalloutException(System.Label.Error_processing_complaint + e.getMessage());
        }
    }
}