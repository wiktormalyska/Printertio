@IsTest
private class RecurringDateValidatorTests {
    @TestSetup
    static void setup() {
        // Setup can remain empty or be removed
    }

    @IsTest
    static void testRecurringDateInvalidWithoutRepeatBy() {
        Discount__c discount = DiscountBuilder.create()
                .withName('Test Discount')
                .withRecurringDateStart(null)
                .withRecurringDateEnd(Datetime.now().addDays(1))
                .build();

        Test.startTest();
        Boolean isValid = RecurringDateValidator.isRecurringDateValidForToday(discount);
        Test.stopTest();

        System.assertEquals(false, isValid, 'Recurring date should be invalid without repeat by options');
    }

    @IsTest
    static void testRecurringDateValidWithTimeOfDay() {
        Discount__c discount = DiscountBuilder.create()
                .withName('Test Discount')
                .withRecurringDateStart(Datetime.now())
                .withRecurringDateEnd(Datetime.now().addHours(1))
                .withRecurringDateRepeatBy('Time of Day')
                .build();

        Test.startTest();
        Boolean isValid = RecurringDateValidator.isRecurringDateValidForToday(discount);
        Test.stopTest();

        System.assertEquals(true, isValid, 'Recurring date should be valid with Time of Day');
    }

    @IsTest
    static void testRecurringDateValidWithDayOfWeek() {
        Discount__c discount = DiscountBuilder.create()
                .withName('Test Discount')
                .withRecurringDateStart(Datetime.now())
                .withRecurringDateEnd(Datetime.now().addHours(1))
                .withRecurringDateRepeatBy('Day of the Week')
                .build();

        Test.startTest();
        Boolean isValid = RecurringDateValidator.isRecurringDateValidForToday(discount);
        Test.stopTest();

        System.assertEquals(true, isValid, 'Recurring date should be valid with Day of the Week');
    }

    @IsTest
    static void testRecurringDateValidWithDayOfMonth() {
        Discount__c discount = DiscountBuilder.create()
                .withName('Test Discount')
                .withRecurringDateStart(Datetime.now())
                .withRecurringDateEnd(Datetime.now().addHours(1))
                .withRecurringDateRepeatBy('Day of the Month')
                .build();

        Test.startTest();
        Boolean isValid = RecurringDateValidator.isRecurringDateValidForToday(discount);
        Test.stopTest();

        System.assertEquals(true, isValid, 'Recurring date should be valid with Day of the Month');
    }

    @IsTest
    static void testRecurringDateValidWithMonth() {
        Discount__c discount = DiscountBuilder.create()
                .withName('Test Discount')
                .withRecurringDateStart(Datetime.now())
                .withRecurringDateEnd(Datetime.now().addHours(1))
                .withRecurringDateRepeatBy('Month')
                .build();

        Test.startTest();
        Boolean isValid = RecurringDateValidator.isRecurringDateValidForToday(discount);
        Test.stopTest();

        System.assertEquals(true, isValid, 'Recurring date should be valid with Month');
    }

    @IsTest
    static void testRecurringDateValidWithYear() {
        Discount__c discount = DiscountBuilder.create()
                .withName('Test Discount')
                .withRecurringDateStart(Datetime.now())
                .withRecurringDateEnd(Datetime.now().addHours(1))
                .withRecurringDateRepeatBy('Year')
                .build();

        Test.startTest();
        Boolean isValid = RecurringDateValidator.isRecurringDateValidForToday(discount);
        Test.stopTest();

        System.assertEquals(true, isValid, 'Recurring date should be valid with Year');
    }

    @IsTest
    static void testRecurringDateInvalidWithTimeOfDayOutsideRange() {
        Discount__c discount = DiscountBuilder.create()
                .withName('Test Discount')
                .withRecurringDateStart(Datetime.now().addHours(-2))
                .withRecurringDateEnd(Datetime.now().addHours(-1))
                .withRecurringDateRepeatBy('Time of Day')
                .build();

        Test.startTest();
        Boolean isValid = RecurringDateValidator.isRecurringDateValidForToday(discount);
        Test.stopTest();

        System.assertEquals(false, isValid, 'Recurring date should be invalid with Time of Day outside range');
    }
}