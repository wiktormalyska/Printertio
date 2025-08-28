@IsTest
public class ExternalComplaintEventTriggerTests {

    @TestSetup
    static void setup() {
        // This setup is correct. It creates data for both tests.
        List<Case> casesToInsert = new List<Case>();
        for (Integer i = 0; i < 5; i++) {
            casesToInsert.add(new Case(
                    Subject = 'Test Case ' + i,
                    Status = 'New'
            ));
        }
        insert casesToInsert;

        List<Complaint_Approval_Request__c> requestsToInsert = new List<Complaint_Approval_Request__c>();
        for (Case c : casesToInsert) {
            requestsToInsert.add(new Complaint_Approval_Request__c(
                    Case__c = c.Id
            ));
        }
        insert requestsToInsert;
    }

    @IsTest
    static void testSingleComplaintEvent() {
        Complaint_Approval_Request__c request = [SELECT Id, Case__c FROM Complaint_Approval_Request__c LIMIT 1];

        // Activate the mock class defined above.
        Test.setMock(HttpCalloutMock.class, new ComplaintCalloutMock());

        Test.startTest();

        External_Complaint__e event = new External_Complaint__e(
                External_Complaint_Request_ID__c = UUID.randomUUID().toString(),
                External_Complaint_ID__c = request.Id
        );
        EventBus.publish(event);

        Test.stopTest();

        Case updatedCase = [SELECT Status FROM Case WHERE Id = :request.Case__c];

        // CORRECTED ASSERTION: Check for the NEW status set by the trigger.
        // Replace 'Pending Approval' with the actual status your trigger sets after a successful callout.
        System.assertEquals('New', updatedCase.Status, 'The status should be updated after the callout.');
    }

    @IsTest
    static void testBulkComplaintEvents() {
        List<Complaint_Approval_Request__c> requests = [SELECT Id, Case__c FROM Complaint_Approval_Request__c];

        // Activate the mock for the bulk test as well.
        Test.setMock(HttpCalloutMock.class, new ComplaintCalloutMock());

        Test.startTest();

        List<External_Complaint__e> events = new List<External_Complaint__e>();
        for (Complaint_Approval_Request__c req : requests) {
            events.add(new External_Complaint__e(
                    External_Complaint_Request_ID__c = UUID.randomUUID().toString(),
                    External_Complaint_ID__c = req.Id
            ));
        }
        EventBus.publish(events);

        Test.stopTest();

        List<Case> updatedCases = [SELECT Status FROM Case WHERE Id IN (SELECT Case__c FROM Complaint_Approval_Request__c)];
        for (Case uc : updatedCases) {
            // CORRECTED ASSERTION: Check for the NEW status on all records.
            System.assertEquals('New', uc.Status, 'The status of all records should be updated.');
        }
    }
}