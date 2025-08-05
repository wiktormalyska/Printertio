@IsTest
private class BestDiscountCounterTests {
    @TestSetup
    static void setup() {
        List<Discount__c> discounts = new List<Discount__c>();

        discounts.add((Discount__c)DiscountTestDataFactory.timeBound().create());
        OrderItemTestDataFactory.activeOrderItem().create();
    }

    @IsTest
    static void testGetMatchingDiscountWithPercentage() {
        List<Discount__c> discounts = [SELECT Id, Name, Discount_Type__c, Value_Type__c, Discount_Value__c FROM Discount__c WHERE Is_Active__c = TRUE];
        Order order = [SELECT Id, TotalAmount FROM Order WHERE Status = :ConstUtil.ORDER_STATUS_DRAFT LIMIT 1];
        DiscountSettings settings = new DiscountSettings(ConstUtil.DISCOUNT_STRATEGY_HIGHEST, 50.0);

        Test.startTest();
        Discount__c bestDiscount = BestDiscountCounter.getMatchingDiscount(discounts, settings, order);
        Test.stopTest();

        System.assertNotEquals(null, bestDiscount, 'Best discount should not be null');
        System.assertEquals('Test Discount 1', bestDiscount.Name, 'Best discount should be the one with the highest percentage');
    }
}