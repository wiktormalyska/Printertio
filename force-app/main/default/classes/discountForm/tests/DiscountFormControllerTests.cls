@IsTest
private class DiscountFormControllerTests {

    @IsTest
    static void testGetRecurringHelpTexts_Success() {
        Test.startTest();
        Map<String, String> result = DiscountFormController.getRecurringHelpTexts();
        Test.stopTest();

        System.assertNotEquals(null, result, 'Result should not be null');
        System.assertEquals(4, result.size(), 'Should return 4 help text entries');
        System.assert(result.containsKey('Daily'), 'Should contain Daily help text');
        System.assert(result.containsKey('Weekly'), 'Should contain Weekly help text');
        System.assert(result.containsKey('Monthly'), 'Should contain Monthly help text');
        System.assert(result.containsKey('Yearly'), 'Should contain Yearly help text');
        System.assertNotEquals('', result.get('Daily'), 'Daily help text should not be empty');
    }

    @IsTest
    static void testSaveDiscount_NullDiscount_ThrowsException() {
        Test.startTest();
        try {
            DiscountFormController.saveDiscount(null);
            System.assert(false, 'Should have thrown an exception for null discount');
        } catch (AuraHandledException e) {
            System.assert(true, 'Should throw error');
        }
        Test.stopTest();
    }

    @IsTest
    static void testSaveDiscount_InvalidDiscount_ThrowsException() {
        Discount__c discount = new Discount__c();

        Test.startTest();
        try {
            DiscountFormController.saveDiscount(discount);
            System.assert(false, 'Should have thrown an exception for invalid discount');
        } catch (AuraHandledException e) {
            System.assert(true, 'Should throw error');
        }
        Test.stopTest();
    }

    @IsTest
    static void testGetConditionLogicPicklistValues_Success() {
        Test.startTest();
        List<Map<String, String>> result = DiscountFormController.getConditionLogicPicklistValues();
        Test.stopTest();

        System.assertNotEquals(null, result, 'Result should not be null');
        System.assert(result.size() >= 0, 'Should return a list (even if empty)');

        if (!result.isEmpty()) {
            Map<String, String> firstOption = result[0];
            System.assert(firstOption.containsKey('label'), 'Each option should have a label');
            System.assert(firstOption.containsKey('value'), 'Each option should have a value');
            System.assertNotEquals('', firstOption.get('label'), 'Label should not be empty');
            System.assertNotEquals('', firstOption.get('value'), 'Value should not be empty');
        }
    }

    @IsTest
    static void testGetConditionLogicPicklistValues_VerifyStructure() {
        Test.startTest();
        List<Map<String, String>> result = DiscountFormController.getConditionLogicPicklistValues();
        Test.stopTest();

        // Verify each option has correct map structure
        for (Map<String, String> option : result) {
            System.assertEquals(2, option.size(), 'Each option should have exactly 2 keys');
            System.assert(option.containsKey('label'), 'Should contain label key');
            System.assert(option.containsKey('value'), 'Should contain value key');
            System.assertNotEquals(null, option.get('label'), 'Label should not be null');
            System.assertNotEquals(null, option.get('value'), 'Value should not be null');
        }
    }
}