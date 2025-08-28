@IsTest
public with sharing class ExternalComplaintApprovalCalloutTests {
    @isTest
    static void testSendComplaintApprovalStatusesAsyncWithValidParams() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(201, 'Created'));

        Test.startTest();
        UUID testUUID = UUID.randomUUID();
        ExternalComplaintApprovalStatusCallout.sendComplaintApprovalStatusesAsync('Approved', testUUID.toString());
        Test.stopTest();

        System.assertEquals(0, Limits.getQueueableJobs());
    }

    @isTest
    static void testSendComplaintApprovalStatusesAsyncWithNullStatus() {
        Test.startTest();
        UUID testUUID = UUID.randomUUID();
        ExternalComplaintApprovalStatusCallout.sendComplaintApprovalStatusesAsync(null, testUUID.toString());
        Test.stopTest();

        System.assertEquals(0, Limits.getQueueableJobs());
    }

    @isTest
    static void testSendComplaintApprovalStatusesAsyncWithEmptyStatus() {
        Test.startTest();
        UUID testUUID = UUID.randomUUID();
        ExternalComplaintApprovalStatusCallout.sendComplaintApprovalStatusesAsync('', testUUID.toString());
        Test.stopTest();

        System.assertEquals(0, Limits.getQueueableJobs());
    }

    @isTest
    static void testExecuteWithSuccessfulResponse() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(201, 'Created'));
        UUID testUUID = UUID.randomUUID();
        ExternalComplaintApprovalStatusCallout callout = new ExternalComplaintApprovalStatusCallout('Approved', testUUID.toString());

        Test.startTest();
        callout.execute(null);
        Test.stopTest();
    }

    @isTest
    static void testExecuteWithFailureResponse() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(400, 'Bad Request'));
        UUID testUUID = UUID.randomUUID();
        ExternalComplaintApprovalStatusCallout callout = new ExternalComplaintApprovalStatusCallout('Approved', testUUID.toString());

        Test.startTest();
        try {
            callout.execute(null);
            System.assert(false, 'Expected CalloutException');
        } catch (CalloutException e) {
            System.assert(true);
        }
        Test.stopTest();
    }

    @isTest
    static void testExecuteWithHttpException() {
        Test.setMock(HttpCalloutMock.class, new MockHttpExceptionGenerator());
        UUID testUUID = UUID.randomUUID();
        ExternalComplaintApprovalStatusCallout callout = new ExternalComplaintApprovalStatusCallout('Approved', testUUID.toString());

        Test.startTest();
        try {
            callout.execute(null);
            System.assert(false, 'Expected CalloutException');
        } catch (CalloutException e) {
            System.assert(true);
        }
        Test.stopTest();
    }

    public class MockHttpResponseGenerator implements HttpCalloutMock {
        private Integer statusCode;
        private String status;

        public MockHttpResponseGenerator(Integer statusCode, String status) {
            this.statusCode = statusCode;
            this.status = status;
        }

        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(statusCode);
            res.setStatus(status);
            return res;
        }
    }

    public class MockHttpExceptionGenerator implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            throw new CalloutException('Mock exception');
        }
    }
}