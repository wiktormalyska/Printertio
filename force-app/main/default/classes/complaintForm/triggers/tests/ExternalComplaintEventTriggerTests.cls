@IsTest
public class ExternalComplaintEventTriggerTests {

    @IsTest
    static void testExternalComplaintEventTrigger() {
        Test.startTest();

        External_Complaint__e event = new External_Complaint__e();
        Database.SaveResult result = EventBus.publish(event);

        // Force immediate delivery in test context
        Test.getEventBus().deliver();

        Test.stopTest();

        System.assert(result.isSuccess(), 'Event should publish successfully');
    }

    @IsTest
    static void testExternalComplaintEventTriggerMultiple() {
        Test.startTest();

        List<External_Complaint__e> events = new List<External_Complaint__e>();
        for (Integer i = 0; i < 5; i++) {
            events.add(new External_Complaint__e());
        }

        List<Database.SaveResult> results = EventBus.publish(events);
        Test.getEventBus().deliver();

        Test.stopTest();

        for (Database.SaveResult result : results) {
            System.assert(result.isSuccess(), 'All events should publish successfully');
        }
    }
}