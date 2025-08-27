@IsTest
private class TA_ExternalComplaintTests {

    @TestSetup
    static void setup() {
        Product2 product = new Product2(
                Name = 'Test Product',
                ExternalId = 'EXT123'
        );
        insert product;
    }

    @IsTest
    static void testAfterInsertWithEmptyList() {
        TA_ExternalComplaint triggerExComplaint = new TA_ExternalComplaint();
        List<External_Complaint__e> emptyList = new List<External_Complaint__e>();

        Test.startTest();
        triggerExComplaint.afterInsert(emptyList);
        Test.stopTest();

        List<Case> cases = [SELECT Id FROM Case];
        System.assertEquals(0, cases.size());
    }

    @IsTest
    static void testAfterInsertSuccess() {
        Product2 product = [SELECT Id FROM Product2 LIMIT 1];

        External_Complaint__e event = new External_Complaint__e(
                Product_ID__c = product.Id,
                External_Complaint_ID__c = 'EXT-001',
                External_Complaint_Request_ID__c = 'REQ-001'
        );

        TA_ExternalComplaint triggerExComplaint = new TA_ExternalComplaint();

        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(201, 'Created'));
        Test.startTest();
        triggerExComplaint.afterInsert(new List<External_Complaint__e>{event});
        Test.stopTest();

        List<Case> cases = [SELECT Id, Is_External__c FROM Case];
        System.assertEquals(1, cases.size());
        System.assertEquals(true, cases[0].Is_External__c);

        List<Complaint_Approval_Request__c> requests = [
                SELECT Id, Case__c, Product__c, Status__c, Is_External__c, External_ID__c
                FROM Complaint_Approval_Request__c
        ];
        System.assertEquals(1, requests.size());
        System.assertEquals(cases[0].Id, requests[0].Case__c);
        System.assertEquals(product.Id, requests[0].Product__c);
        System.assertEquals(true, requests[0].Is_External__c);
        System.assertEquals('EXT-001', requests[0].External_ID__c);
    }

    @IsTest
    static void testAfterInsertMultipleEvents() {
        Product2 product = [SELECT Id FROM Product2 LIMIT 1];

        List<External_Complaint__e> events = new List<External_Complaint__e>{
                new External_Complaint__e(
                        Product_ID__c = product.Id,
                        External_Complaint_ID__c = 'EXT-001',
                        External_Complaint_Request_ID__c = 'REQ-001'
                ),
                new External_Complaint__e(
                        Product_ID__c = product.Id,
                        External_Complaint_ID__c = 'EXT-002',
                        External_Complaint_Request_ID__c = 'REQ-002'
                )
        };

        TA_ExternalComplaint triggerExComplaint = new TA_ExternalComplaint();

        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(201, 'Created'));
        Test.startTest();
        triggerExComplaint.afterInsert(events);
        Test.stopTest();

        List<Case> cases = [SELECT Id FROM Case];
        System.assertEquals(1, cases.size());

        List<Complaint_Approval_Request__c> requests = [SELECT Id FROM Complaint_Approval_Request__c];
        System.assertEquals(2, requests.size());
    }

    @IsTest
    static void testAfterInsertNullRequestId() {
        Product2 product = [SELECT Id FROM Product2 LIMIT 1];

        External_Complaint__e event = new External_Complaint__e(
                Product_ID__c = product.Id,
                External_Complaint_ID__c = 'EXT-001',
                External_Complaint_Request_ID__c = null
        );

        TA_ExternalComplaint triggerExComplaint = new TA_ExternalComplaint();

        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(201, 'Created'));
        Test.startTest();
        triggerExComplaint.afterInsert(new List<External_Complaint__e>{event});
        Test.stopTest();

        List<Case> cases = [SELECT Id FROM Case];
        System.assertEquals(1, cases.size());

        List<Complaint_Approval_Request__c> requests = [SELECT Id FROM Complaint_Approval_Request__c];
        System.assertEquals(1, requests.size());
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
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"status":"success"}');
            return res;
        }
    }
}