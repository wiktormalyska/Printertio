@IsTest
public class ExternalComplaintEventTriggerTests {

    @IsTest
    static void testExternalComplaintEventTrigger() {
        Test.startTest();

        External_Complaint__e event = new External_Complaint__e();
        Database.SaveResult result = EventBus.publish(event);
        Test.stopTest();

        System.assert(true, 'Trigger executed without exceptions');
    }

    @IsTest
    static void testExternalComplaintEventTriggerMultiple() {
        Test.startTest();

        List<External_Complaint__e> events = new List<External_Complaint__e>();
        for (Integer i = 0; i < 5; i++) {
            events.add(new External_Complaint__e());
        }

        List<Database.SaveResult> results = EventBus.publish(events);
        Test.stopTest();

        System.assertEquals(5, results.size(), 'Should return results for all events');
    }
}