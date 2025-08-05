@IsTest
private class TimeBoundValidatorTests {
    @IsTest
    static void testTimeBoundDiscountValid() {
        Discount__c discount = DiscountBuilder.create()
                .withName('Test Discount')
                .withStartDate(Date.today())
                .withEndDate(Date.today().addDays(1))
                .build();

        Test.startTest();
        Boolean isValid = TimeBoundValidator.isValidTimeBoundDiscount(discount);
        Test.stopTest();

        System.assertEquals(true, isValid, 'Time-bound discount should be valid for today');
    }

    @IsTest
    static void testTimeBoundDiscountInvalid() {
        Discount__c discount = DiscountBuilder.create()
                .withName('Test Discount')
                .withStartDate(Date.today().addDays(1))
                .withEndDate(Date.today().addDays(2))
                .build();

        Test.startTest();
        Boolean isValid = TimeBoundValidator.isValidTimeBoundDiscount(discount);
        Test.stopTest();

        System.assertEquals(false, isValid, 'Time-bound discount should be invalid for today');
    }

    @IsTest
    static void testTimeBoundDiscountWithNullDates() {
        Discount__c discount = DiscountBuilder.create()
                .withName('Test Discount')
                .withStartDate(null)
                .withEndDate(null)
                .build();

        Test.startTest();
        Boolean isValid = TimeBoundValidator.isValidTimeBoundDiscount(discount);
        Test.stopTest();

        System.assertEquals(false, isValid, 'Time-bound discount should be invalid when start or end date is null');
    }

    @IsTest
    static void testTimeBoundDiscountWithStartDateAfterEndDate() {
        Discount__c discount = DiscountBuilder.create()
                .withName('Test Discount')
                .withStartDate(Date.today().addDays(2))
                .withEndDate(Date.today().addDays(1))
                .build();

        Test.startTest();
        Boolean isValid = TimeBoundValidator.isValidTimeBoundDiscount(discount);
        Test.stopTest();

        System.assertEquals(false, isValid, 'Time-bound discount should be invalid when start date is after end date');
    }
}