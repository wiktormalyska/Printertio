@IsTest
public with sharing class TimeBoundValidatorTests {
    @IsTest
    static void testTimeBoundDiscountValid() {
        Discount__c discount = new Discount__c(
            Start_Date__c = Date.today(),
            End_Date__c = Date.today().addDays(1)
        );

        Test.startTest();
        Boolean isValid = TimeBoundValidator.isValidTimeBoundDiscount(discount);
        Test.stopTest();

        System.assertEquals(true, isValid, 'Time-bound discount should be valid for today');
    }

    @IsTest
    static void testTimeBoundDiscountInvalid() {
        Discount__c discount = new Discount__c(
            Start_Date__c = Date.today().addDays(1),
            End_Date__c = Date.today().addDays(2)
        );

        Test.startTest();
        Boolean isValid = TimeBoundValidator.isValidTimeBoundDiscount(discount);
        Test.stopTest();

        System.assertEquals(false, isValid, 'Time-bound discount should be invalid for today');
    }

    @IsTest
    static void testTimeBoundDiscountWithNullDates() {
        Discount__c discount = new Discount__c(
            Start_Date__c = null,
            End_Date__c = null
        );

        Test.startTest();
        Boolean isValid = TimeBoundValidator.isValidTimeBoundDiscount(discount);
        Test.stopTest();

        System.assertEquals(false, isValid, 'Time-bound discount should be invalid when start or end date is null');
    }

    @IsTest
    static void testTimeBoundDiscountWithStartDateAfterEndDate() {
        Discount__c discount = new Discount__c(
            Start_Date__c = Date.today().addDays(2),
            End_Date__c = Date.today().addDays(1)
        );

        Test.startTest();
        Boolean isValid = TimeBoundValidator.isValidTimeBoundDiscount(discount);
        Test.stopTest();

        System.assertEquals(false, isValid, 'Time-bound discount should be invalid when start date is after end date');
    }
}