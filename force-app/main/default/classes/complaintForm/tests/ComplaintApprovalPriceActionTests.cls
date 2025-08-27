@IsTest
public with sharing class ComplaintApprovalPriceActionTests {
    @IsTest
    static void testGetUnitPriceFromComplaintApproval_Success() {
        List<ComplaintApprovalPriceRetrieverAction.Request> requests = new List<ComplaintApprovalPriceRetrieverAction.Request>();
        ComplaintApprovalPriceRetrieverAction.Request request = new ComplaintApprovalPriceRetrieverAction.Request();
        request.complaintApprovalId = 'a001234567890ABC';
        requests.add(request);

        Test.setMock(HttpCalloutMock.class, new ComplaintApprovalMockSuccess());

        Test.startTest();
        List<ComplaintApprovalPriceRetrieverAction.Result> results =
                ComplaintApprovalPriceRetrieverAction.getUnitPriceFromComplaintApproval(requests);
        Test.stopTest();

        System.assertEquals(1, results.size());
        System.assertEquals(true, results[0].isSuccess);
        System.assertEquals(100.50, results[0].unitPrice);
        System.assertEquals(null, results[0].errorMessage);
    }

    @IsTest
    static void testGetUnitPriceFromComplaintApproval_NoRecordsFound() {
        List<ComplaintApprovalPriceRetrieverAction.Request> requests = new List<ComplaintApprovalPriceRetrieverAction.Request>();
        ComplaintApprovalPriceRetrieverAction.Request request = new ComplaintApprovalPriceRetrieverAction.Request();
        request.complaintApprovalId = 'a001234567890ABC';
        requests.add(request);

        Test.setMock(HttpCalloutMock.class, new ComplaintApprovalMockNoRecords());

        Test.startTest();
        List<ComplaintApprovalPriceRetrieverAction.Result> results =
                ComplaintApprovalPriceRetrieverAction.getUnitPriceFromComplaintApproval(requests);
        Test.stopTest();

        System.assertEquals(1, results.size());
        System.assertEquals(false, results[0].isSuccess);
        System.assertEquals(null, results[0].unitPrice);
        System.assert(results[0].errorMessage.contains('No records found'));
    }

    @IsTest
    static void testGetUnitPriceFromComplaintApproval_CalloutError() {
        List<ComplaintApprovalPriceRetrieverAction.Request> requests = new List<ComplaintApprovalPriceRetrieverAction.Request>();
        ComplaintApprovalPriceRetrieverAction.Request request = new ComplaintApprovalPriceRetrieverAction.Request();
        request.complaintApprovalId = 'a001234567890ABC';
        requests.add(request);

        Test.setMock(HttpCalloutMock.class, new ComplaintApprovalMockError());

        Test.startTest();
        List<ComplaintApprovalPriceRetrieverAction.Result> results =
                ComplaintApprovalPriceRetrieverAction.getUnitPriceFromComplaintApproval(requests);
        Test.stopTest();

        System.assertEquals(1, results.size());
        System.assertEquals(false, results[0].isSuccess);
        System.assertEquals(null, results[0].unitPrice);
        System.assert(results[0].errorMessage.contains('Callout failed'));
    }

    @IsTest
    static void testGetUnitPriceFromComplaintApproval_ProductNotFound() {
        List<ComplaintApprovalPriceRetrieverAction.Request> requests = new List<ComplaintApprovalPriceRetrieverAction.Request>();
        ComplaintApprovalPriceRetrieverAction.Request request = new ComplaintApprovalPriceRetrieverAction.Request();
        request.complaintApprovalId = 'a001234567890ABC';
        requests.add(request);

        Test.setMock(HttpCalloutMock.class, new ComplaintApprovalMockProductNotFound());

        Test.startTest();
        List<ComplaintApprovalPriceRetrieverAction.Result> results =
                ComplaintApprovalPriceRetrieverAction.getUnitPriceFromComplaintApproval(requests);
        Test.stopTest();

        System.assertEquals(1, results.size());
        System.assertEquals(false, results[0].isSuccess);
        System.assertEquals(null, results[0].unitPrice);
        System.assert(results[0].errorMessage.contains('Unit price not found'));
    }

    @IsTest
    static void testGetUnitPriceFromComplaintApproval_MultipleRequests() {
        List<ComplaintApprovalPriceRetrieverAction.Request> requests = new List<ComplaintApprovalPriceRetrieverAction.Request>();

        ComplaintApprovalPriceRetrieverAction.Request request1 = new ComplaintApprovalPriceRetrieverAction.Request();
        request1.complaintApprovalId = 'a001234567890ABC';
        requests.add(request1);

        ComplaintApprovalPriceRetrieverAction.Request request2 = new ComplaintApprovalPriceRetrieverAction.Request();
        request2.complaintApprovalId = 'a001234567890DEF';
        requests.add(request2);

        Test.setMock(HttpCalloutMock.class, new ComplaintApprovalMockSuccess());

        Test.startTest();
        List<ComplaintApprovalPriceRetrieverAction.Result> results =
                ComplaintApprovalPriceRetrieverAction.getUnitPriceFromComplaintApproval(requests);
        Test.stopTest();

        System.assertEquals(2, results.size());
        System.assertEquals(true, results[0].isSuccess);
        System.assertEquals(true, results[1].isSuccess);
    }
}