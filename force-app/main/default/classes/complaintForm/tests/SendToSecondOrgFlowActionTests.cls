@IsTest
public with sharing class SendToSecondOrgFlowActionTests {

    @TestSetup
    static void setupTestData() {
        Case testCase = (Case) new CaseTestDataFactory().create();
        insert testCase;

        Product2 testProduct = (Product2) new ProductTestDataFactory().create();
        testProduct.externalId = 'EXT001';
        insert testProduct;

        Complaint_Approval_Request__c complaintRequest = (Complaint_Approval_Request__c) new CARTestDataFactory().create();
        complaintRequest.Case__c = testCase.Id;
        complaintRequest.Product__c = testProduct.Id;
        complaintRequest.Is_External__c = true;
        complaintRequest.External_ID__c = 'CAR_EXT_001';
        insert complaintRequest;
    }

    @IsTest
    static void testSendComplaintToSecondOrgSuccess() {
        Complaint_Approval_Request__c complaintRequest = [
                SELECT Id
                FROM Complaint_Approval_Request__c
                LIMIT 1
        ];

        SendToSecondOrgFlowAction.SendToSecondOrgRequest request = new SendToSecondOrgFlowAction.SendToSecondOrgRequest();
        request.complaintApprovalRequestId = complaintRequest.Id;

        Test.startTest();
        List<SendToSecondOrgFlowAction.SendToSecondOrgResult> results =
                SendToSecondOrgFlowAction.sendComplaintToSecondOrg(new List<SendToSecondOrgFlowAction.SendToSecondOrgRequest>{
                        request
                });
        Test.stopTest();

        System.assertEquals(1, results.size());
        System.assertEquals(true, results[0].isSuccess);
        System.assertEquals(null, results[0].message);
    }

    @IsTest
    static void testSendComplaintToSecondOrgWithInvalidId() {
        SendToSecondOrgFlowAction.SendToSecondOrgRequest request = new SendToSecondOrgFlowAction.SendToSecondOrgRequest();
        request.complaintApprovalRequestId = 'invalidId';

        Test.startTest();
        List<SendToSecondOrgFlowAction.SendToSecondOrgResult> results =
                SendToSecondOrgFlowAction.sendComplaintToSecondOrg(new List<SendToSecondOrgFlowAction.SendToSecondOrgRequest>{
                        request
                });
        Test.stopTest();

        System.assertEquals(1, results.size());
        System.assertEquals(false, results[0].isSuccess);
        System.assert(results[0].message.contains('Error sending to second org'));
    }

    @IsTest
    static void testSendComplaintToSecondOrgMultipleRequests() {
        List<Complaint_Approval_Request__c> complaintRequests = [
                SELECT Id
                FROM Complaint_Approval_Request__c
        ];

        SendToSecondOrgFlowAction.SendToSecondOrgRequest request1 = new SendToSecondOrgFlowAction.SendToSecondOrgRequest();
        request1.complaintApprovalRequestId = complaintRequests[0].Id;

        SendToSecondOrgFlowAction.SendToSecondOrgRequest request2 = new SendToSecondOrgFlowAction.SendToSecondOrgRequest();
        request2.complaintApprovalRequestId = 'invalidId';

        Test.startTest();
        List<SendToSecondOrgFlowAction.SendToSecondOrgResult> results =
                SendToSecondOrgFlowAction.sendComplaintToSecondOrg(new List<SendToSecondOrgFlowAction.SendToSecondOrgRequest>{
                        request1, request2
                });
        Test.stopTest();

        System.assertEquals(2, results.size());
        System.assertEquals(true, results[0].isSuccess);
        System.assertEquals(false, results[1].isSuccess);
    }

    @IsTest
    static void testSendComplaintToSecondOrgEmptyList() {
        Test.startTest();
        List<SendToSecondOrgFlowAction.SendToSecondOrgResult> results =
                SendToSecondOrgFlowAction.sendComplaintToSecondOrg(new List<SendToSecondOrgFlowAction.SendToSecondOrgRequest>());
        Test.stopTest();

        System.assertEquals(0, results.size());
    }

}