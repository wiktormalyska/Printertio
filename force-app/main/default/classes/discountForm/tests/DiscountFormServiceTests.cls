@IsTest
private class DiscountFormServiceTests {

    @IsTest
    static void testGetRecurringHelpTexts() {
        Test.startTest();
        Map<String, String> helpTexts = DiscountFormService.getRecurringHelpTexts();
        Test.stopTest();

        System.assertNotEquals(null, helpTexts, 'Help texts should not be null');
    }

    @IsTest
    static void testSaveDiscount() {
        Discount__c discount = (Discount__c) new DiscountTestDataFactory().create();

        Test.startTest();
        Id discountId = DiscountFormService.saveDiscount(discount);
        Test.stopTest();

        System.assertNotEquals(null, discountId, 'Discount ID should not be null after saving');

        // Verify the discount was saved correctly
        Discount__c savedDiscount = [SELECT Id, Name, Value_Type__c, Discount_Value__c FROM Discount__c WHERE Id = :discountId];
        System.assertEquals('Test Discount', savedDiscount.Name, 'Discount name should match');
    }
}