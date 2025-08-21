public with sharing class TA_ExternalComplaint implements TriggerAction.AfterInsert {
    public void afterInsert(List<External_Complaint__e> triggerNew) {
        System.debug(triggerNew);
        if (!triggerNew.isEmpty()) {
            createComplaintCases(triggerNew);
        }
    }

    private void createComplaintCases(List<External_Complaint__e> events) {
        System.debug(events);
        Case newCase = new Case(
                Is_External__c = true
        );
        insert newCase;
        System.debug(newCase);

        List<Id> productIds = new List<Id>();
        String randomUUID;
        for (External_Complaint__e event : events) {
            productIds.add(event.Product_ID__c);
            if (event.External_Complaint_Request_ID__c != null) {
                randomUUID = event.External_Complaint_Request_ID__c;
            }
        }
        System.debug(productIds);
        System.debug(randomUUID);

        List<Product2> products = [
                SELECT Id, Name, ExternalId
                FROM Product2
                WHERE Id IN :productIds
        ];
        System.debug('DML Products: ' + products);

        Map<String, Product2> productMap = new Map<String, Product2>();
        for (Product2 product : products) {
            productMap.put(product.Id, product);
        }
        System.debug(productMap);

        List<Complaint_Approval_Request__c> complaintApprovalRequests = new List<Complaint_Approval_Request__c>();

        for (External_Complaint__e event : events) {
            Product2 product = productMap.get(event.Product_ID__c);
            System.debug(product);
            if (product != null) {
                Complaint_Approval_Request__c complaintApprovalRequest = new Complaint_Approval_Request__c(
                        Case__c = newCase.Id,
                        Product__c = product.Id,
                        Status__c = 'Pending Approval'
                );
                complaintApprovalRequests.add(complaintApprovalRequest);
                System.debug(complaintApprovalRequest);
            }
        }
        insert complaintApprovalRequests;
        System.debug(complaintApprovalRequests);

        List<Approval.ProcessSubmitRequest> internalApprovalRequests = new List<Approval.ProcessSubmitRequest>();
        for (Complaint_Approval_Request__c complaintApprovalRequest : complaintApprovalRequests) {
            Approval.ProcessSubmitRequest request = new Approval.ProcessSubmitRequest();
            request.setObjectId(complaintApprovalRequest.Id);
            request.setProcessDefinitionNameOrId('Approving_Complaint');
            internalApprovalRequests.add(request);
        }

        try {
            Approval.ProcessResult[] processResults = Approval.process(internalApprovalRequests, false);
            Boolean allSuccess = true;
            for (Approval.ProcessResult processResult : processResults) {
                if (!processResult.success) {
                    allSuccess = false;
                    throw new DmlException('Error creating approval request: ' + processResult.getErrors());
                } else {
                    System.debug('Success creating approval request');
                }
            }
            //System.debug(processResults);

            System.debug('allSuccess >> ' + String.valueOf(allSuccess));
            if (allSuccess) {
                ExternalComplaintApprovalStatusCallout.sendComplaintApprovalStatusesAsync('SUCCESS', randomUUID);
            }
        } catch (Exception e) {
            throw new CalloutException('Error processing complaint: ' + e.getMessage());
        }
    }
}