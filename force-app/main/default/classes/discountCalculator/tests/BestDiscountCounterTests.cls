@IsTest
private class BestDiscountCounterTests {
    @TestSetup
    static void setup() {
        Discount__c discount1 = (Discount__c) new TimeBoundDiscountDataFactory().create();
        insert discount1;
        Account account = (Account) new AccountTestDataFactory().create();
        insert account;
        Order order = (Order) new OrderTestDataFactory(account).create();
        insert order;
        Product2 product = (Product2) new ProductTestDataFactory().create();
        insert product;
        PricebookEntry pbe = (PricebookEntry) new PricebookEntryTestDataFactory(product).create();
        insert pbe;
        OrderItem orderItem = (OrderItem) new OrderItemTestDataFactory(order, pbe).create();
        insert orderItem;
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
        System.assertEquals('Test Discount', bestDiscount.Name, 'Best discount should be the one with the highest percentage');
    }

    private class TimeBoundDiscountDataFactory extends DiscountTestDataFactory {
        public override SObject create() {
            Discount__c discount = (Discount__c) super.prepare();
            discount.Discount_Type__c = ConstUtil.DISCOUNT_TYPE_TIME_BOUND;
            discount.Value_Type__c = ConstUtil.DISCOUNT_VALUE_TYPE_PERCENTAGE;
            discount.Discount_Value__c = 20.0;
            discount.Start_Date__c = Date.today();
            discount.End_Date__c = Date.today().addDays(30);
            return discount;
        }
    }
}