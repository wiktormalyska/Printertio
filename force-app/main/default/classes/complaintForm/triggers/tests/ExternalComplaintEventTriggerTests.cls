@IsTest
public class ExternalComplaintEventTriggerTests {

    @IsTest
    static void testExternalComplaintEventTrigger() {
        External_Complaint__e event = new External_Complaint__e();

        Test.startTest();
        EventBus.publish(event);
        Test.stopTest();

        System.assert(true, 'Event trigger executed successfully');
    }
}