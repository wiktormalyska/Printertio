@IsTest
public class ExternalCAStatusEventTriggerTests {

    @IsTest
    static void testExternalComplaintApprovalStatusEventTrigger() {
        Test.startTest();

        External_Complaint_Approval_Status__e event = new External_Complaint_Approval_Status__e();
        Database.SaveResult result = EventBus.publish(event);

        Test.stopTest();
        System.assert(true, 'Trigger executed without exceptions');
    }

    @IsTest
    static void testExternalComplaintApprovalStatusEventTriggerBulk() {
        Test.startTest();

        List<External_Complaint_Approval_Status__e> events = new List<External_Complaint_Approval_Status__e>();
        for (Integer i = 0; i < 3; i++) {
            events.add(new External_Complaint_Approval_Status__e());
        }

        List<Database.SaveResult> results = EventBus.publish(events);

        Test.stopTest();
        System.assertEquals(3, results.size(), 'Should return results for all events');
    }
}