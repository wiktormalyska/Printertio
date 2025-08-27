@IsTest
public with sharing class ExternalComplaintCalloutTests {
    @isTest
    static void testConstructor() {
        Map<String, String> testEvents = new Map<String, String>{'key1' => 'value1'};
        UUID testUUID = UUID.randomUUID();

        ExternalComplaintCallout callout = new ExternalComplaintCallout(testEvents, testUUID);

        System.assertNotEquals(null, callout);
    }

    @isTest
    static void testSendComplaintsAsyncWithValidData() {
        Map<String, String> testEvents = new Map<String, String>{'key1' => 'value1'};
        UUID testUUID = UUID.randomUUID();

        Test.startTest();
        ExternalComplaintCallout.sendComplaintsAsync(testEvents, testUUID);
        Test.stopTest();

        System.assertEquals(1, [SELECT COUNT() FROM AsyncApexJob WHERE JobType = 'Queueable']);
    }

    @isTest
    static void testSendComplaintsAsyncWithNullData() {
        UUID testUUID = UUID.randomUUID();

        Test.startTest();
        ExternalComplaintCallout.sendComplaintsAsync(null, testUUID);
        Test.stopTest();

        System.assertEquals(0, [SELECT COUNT() FROM AsyncApexJob WHERE JobType = 'Queueable']);
    }

    @isTest
    static void testSendComplaintsAsyncWithEmptyMap() {
        Map<String, String> emptyEvents = new Map<String, String>();
        UUID testUUID = UUID.randomUUID();

        Test.startTest();
        ExternalComplaintCallout.sendComplaintsAsync(emptyEvents, testUUID);
        Test.stopTest();

        System.assertEquals(0, [SELECT COUNT() FROM AsyncApexJob WHERE JobType = 'Queueable']);
    }

    @isTest
    static void testExecute() {
        Map<String, String> testEvents = new Map<String, String>{'key1' => 'value1'};
        UUID testUUID = UUID.randomUUID();
        ExternalComplaintCallout callout = new ExternalComplaintCallout(testEvents, testUUID);

        Test.startTest();
        System.enqueueJob(callout);
        Test.stopTest();

        System.assertEquals(1, [SELECT COUNT() FROM AsyncApexJob WHERE JobType = 'BatchApex']);
    }
}