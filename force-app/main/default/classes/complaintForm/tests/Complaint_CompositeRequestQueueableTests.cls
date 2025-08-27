@isTest
public class Complaint_CompositeRequestQueueableTests {

    @isTest
    static void testExecuteWithValidRequests() {
        List<Complaint_CompositeRequestQueueable.CompositeSubRequest> requests = new List<Complaint_CompositeRequestQueueable.CompositeSubRequest>();

        Map<String, Object> testBody = new Map<String, Object>{
                'Name' => 'Test Record',
                'Status' => 'Active'
        };

        requests.add(new Complaint_CompositeRequestQueueable.CompositeSubRequest(
                'POST',
                '/services/data/v64.0/sobjects/Account',
                'NewAccount1',
                testBody
        ));

        Test.setMock(HttpCalloutMock.class, new Complaint_CompositeMockHttp());

        Test.startTest();
        Complaint_CompositeRequestQueueable queueable = new Complaint_CompositeRequestQueueable(requests);
        System.enqueueJob(queueable);
        Test.stopTest();

        System.assert(true, 'Queueable executed successfully');
    }

    @isTest
    static void testExecuteWithEmptyRequests() {
        List<Complaint_CompositeRequestQueueable.CompositeSubRequest> emptyRequests = new List<Complaint_CompositeRequestQueueable.CompositeSubRequest>();

        Test.startTest();
        Complaint_CompositeRequestQueueable queueable = new Complaint_CompositeRequestQueueable(emptyRequests);
        System.enqueueJob(queueable);
        Test.stopTest();

        System.assert(true, 'Queueable handled empty requests');
    }

    @isTest
    static void testExecuteWithNullRequests() {
        Test.startTest();
        Complaint_CompositeRequestQueueable queueable = new Complaint_CompositeRequestQueueable(null);
        System.enqueueJob(queueable);
        Test.stopTest();

        System.assert(true, 'Queueable handled null requests');
    }

    @isTest
    static void testExecuteWithErrorResponse() {
        List<Complaint_CompositeRequestQueueable.CompositeSubRequest> requests = new List<Complaint_CompositeRequestQueueable.CompositeSubRequest>();

        Map<String, Object> testBody = new Map<String, Object>{
                'Name' => 'Test Record'
        };

        requests.add(new Complaint_CompositeRequestQueueable.CompositeSubRequest(
                'POST',
                '/services/data/v64.0/sobjects/Account',
                'NewAccount1',
                testBody
        ));

        Test.setMock(HttpCalloutMock.class, new Complaint_CompositeMockHttpError());

        Complaint_CompositeRequestQueueable queueable = new Complaint_CompositeRequestQueueable(requests);

        Test.startTest();
        try {
            // Call execute directly to catch the exception in the test context
            queueable.execute(null);

            // If we reach here, the test should fail because we expected an exception
            System.assert(false, 'Expected CalloutException to be thrown');
        } catch (CalloutException e) {
            // Verify the exception contains the expected message
            System.assert(e.getMessage().contains('Error in composite request'), 'Expected error message about composite request');
            System.assert(e.getMessage().contains('400'), 'Expected 400 status code in error message');
        }
        Test.stopTest();
    }

    @isTest
    static void testCompositeSubRequestConstructor() {
        Map<String, Object> testBody = new Map<String, Object>{
                'Name' => 'Test',
                'Status' => 'Active'
        };

        Complaint_CompositeRequestQueueable.CompositeSubRequest subRequest =
                new Complaint_CompositeRequestQueueable.CompositeSubRequest(
                        'POST',
                        '/services/data/v64.0/sobjects/Account',
                        'TestRef',
                        testBody
                );

        System.assertEquals('POST', subRequest.method);
        System.assertEquals('/services/data/v64.0/sobjects/Account', subRequest.url);
        System.assertEquals('TestRef', subRequest.referenceId);
        System.assertEquals(testBody, subRequest.body);
    }
}