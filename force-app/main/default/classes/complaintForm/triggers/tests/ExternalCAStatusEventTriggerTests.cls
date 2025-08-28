@IsTest
public class ExternalCAStatusEventTriggerTests {
    @TestSetup
    static void setupTestData() {
        Case casea = new Case();
        insert casea;

        List<Complaint_Approval_Request__c> requestsToInsert = new List<Complaint_Approval_Request__c>();
        for (Integer i = 0; i < 5; i++) {
            requestsToInsert.add(new Complaint_Approval_Request__c(
                    Case__c = casea.Id
            ));
        }
        insert requestsToInsert;
    }

    @IsTest
    static void testSingleEventPublication() {
        Complaint_Approval_Request__c request = [
                SELECT Id, Status__c
                FROM Complaint_Approval_Request__c
                LIMIT 1
        ];

        Test.startTest();

        External_Complaint_Approval_Status__e event = new External_Complaint_Approval_Status__e(
                Status__c = 'SUCCESS',
                External_Complaint_Request_ID__c = request.Id
        );
        Database.SaveResult sr = EventBus.publish(event);
        Test.stopTest();

        System.assert(sr.isSuccess(), 'Publikacja zdarzenia powinna się powieść.');

        Complaint_Approval_Request__c updatedRequest = [
                SELECT Id, Status__c
                FROM Complaint_Approval_Request__c
                WHERE Id = :request.Id
        ];

        System.assertEquals(null, updatedRequest.Status__c);
    }

    @IsTest
    static void testBulkEventPublication() {
        List<Complaint_Approval_Request__c> requests = [
                SELECT Id, Status__c, Case__c
                FROM Complaint_Approval_Request__c
        ];

        List<External_Complaint_Approval_Status__e> eventsToPublish = new List<External_Complaint_Approval_Status__e>();
        for (Complaint_Approval_Request__c req : requests) {
            eventsToPublish.add(new External_Complaint_Approval_Status__e(
                    Status__c = 'APPROVED_BULK',
                    External_Complaint_Request_ID__c = req.Id
            ));
        }

        Test.startTest();
        List<Database.SaveResult> results = EventBus.publish(eventsToPublish);

        Test.stopTest();
        List<Complaint_Approval_Request__c> updatedRequests = [
                SELECT Id, Status__c
                FROM Complaint_Approval_Request__c
                WHERE Id IN :requests
        ];

        for (Complaint_Approval_Request__c updatedReq : updatedRequests) {
            System.assertEquals(null, updatedReq.Status__c);
        }
    }
}