@IsTest
public with sharing class RecurringDateValidatorTests {
    @TestSetup
    static void setup() {

    }

    @IsTest
    static void testRecurringDateInvalidWithoutRepeatBy() {
        Discount__c discount = new Discount__c(
                Recurring_Date_Start__c = null,
                Recurring_Date_End__c = Datetime.now().addDays(1)
        );

        Test.startTest();
        Boolean isValid = RecurringDateValidator.isRecurringDateValidForToday(discount);
        Test.stopTest();

        System.assertEquals(false, isValid, 'Recurring date should be invalid without repeat by options');
    }

    @IsTest
    static void testRecurringDateValidWithTimeOfDay() {
        Discount__c discount = new Discount__c(
                //Added 1 hour to end time to ensure it is valid for at least one hour
                Recurring_Date_Start__c = Datetime.now(),
                Recurring_Date_End__c = Datetime.now().addHours(1),
                Recurring_Date_Repeat_By__c = 'Time of Day'
        );

        Test.startTest();
        Boolean isValid = RecurringDateValidator.isRecurringDateValidForToday(discount);
        Test.stopTest();

        System.assertEquals(true, isValid, 'Recurring date should be valid with Time of Day');
    }

    @IsTest
    static void testRecurringDateValidWithDayOfWeek() {
        Discount__c discount = new Discount__c(
                Recurring_Date_Start__c = Datetime.now(),
                Recurring_Date_End__c = Datetime.now(),
                Recurring_Date_Repeat_By__c = 'Day of the Week'
        );

        Test.startTest();
        Boolean isValid = RecurringDateValidator.isRecurringDateValidForToday(discount);
        Test.stopTest();

        System.assertEquals(true, isValid, 'Recurring date should be valid with Day of the Week');
    }

    @IsTest
    static void testRecurringDateValidWithDayOfMonth() {
        Discount__c discount = new Discount__c(
                Recurring_Date_Start__c = Datetime.now(),
                Recurring_Date_End__c = Datetime.now(),
                Recurring_Date_Repeat_By__c = 'Day of the Month'
        );

        Test.startTest();
        Boolean isValid = RecurringDateValidator.isRecurringDateValidForToday(discount);
        Test.stopTest();

        System.assertEquals(true, isValid, 'Recurring date should be valid with Day of the Month');
    }

    @IsTest
    static void testRecurringDateValidWithMonth() {
        Discount__c discount = new Discount__c(
                Recurring_Date_Start__c = Datetime.now(),
                Recurring_Date_End__c = Datetime.now(),
                Recurring_Date_Repeat_By__c = 'Month'
        );

        Test.startTest();
        Boolean isValid = RecurringDateValidator.isRecurringDateValidForToday(discount);
        Test.stopTest();

        System.assertEquals(true, isValid, 'Recurring date should be valid with Month');
    }

    @IsTest
    static void testRecurringDateValidWithYear() {
        Discount__c discount = new Discount__c(
                Recurring_Date_Start__c = Datetime.now(),
                Recurring_Date_End__c = Datetime.now(),
                Recurring_Date_Repeat_By__c = 'Year'
        );

        Test.startTest();
        Boolean isValid = RecurringDateValidator.isRecurringDateValidForToday(discount);
        Test.stopTest();

        System.assertEquals(true, isValid, 'Recurring date should be valid with Year');
    }

    @IsTest
    static void testRecurringDateInvalidWithTimeOfDayOutsideRange() {
        Discount__c discount = new Discount__c(
                Recurring_Date_Start__c = Datetime.now().addHours(-2),
                Recurring_Date_End__c = Datetime.now().addHours(-1),
                Recurring_Date_Repeat_By__c = 'Time of Day'
        );

        Test.startTest();
        Boolean isValid = RecurringDateValidator.isRecurringDateValidForToday(discount);
        Test.stopTest();

        System.assertEquals(false, isValid, 'Recurring date should be invalid with Time of Day outside range');
    }
}