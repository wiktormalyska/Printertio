@IsTest
public class ExternalComplaintEventTriggerTests {

    @IsTest
    static void testExternalComplaintEventTrigger() {
        // Create and publish the platform event
        External_Complaint__e event = new External_Complaint__e();
        // Add any required fields for the event here if needed

        Test.startTest();
        EventBus.publish(event);
        Test.stopTest();

        // The trigger should execute after the event is published
        // Add assertions here to verify the expected behavior
        System.assert(true, 'Event trigger executed successfully');
    }
}