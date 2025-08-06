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

    @IsTest
    static void testGetMatchingDiscountWithFixedAmount() {
        // Create a fixed amount discount
        Discount__c fixedDiscount = new Discount__c(
                Name = 'Fixed Discount',
                Discount_Type__c = ConstUtil.DISCOUNT_TYPE_TIME_BOUND,
                Value_Type__c = ConstUtil.DISCOUNT_VALUE_TYPE_FIXED_AMOUNT,
                Discount_Value__c = 50.0,
                Is_Active__c = true,
                Start_Date__c = Date.today(),
                End_Date__c = Date.today().addDays(30)
        );
        insert fixedDiscount;

        List<Discount__c> discounts = [SELECT Id, Name, Value_Type__c, Discount_Value__c FROM Discount__c WHERE Is_Active__c = TRUE];
        Order order = [SELECT Id, TotalAmount FROM Order WHERE Status = :ConstUtil.ORDER_STATUS_DRAFT LIMIT 1];
        DiscountSettings settings = new DiscountSettings(ConstUtil.DISCOUNT_STRATEGY_HIGHEST, 50.0);

        Test.startTest();
        Discount__c bestDiscount = BestDiscountCounter.getMatchingDiscount(discounts, settings, order);
        Test.stopTest();

        System.assertNotEquals(null, bestDiscount, 'Best discount should not be null');
    }

    @IsTest
    static void testGetMatchingDiscountLowestStrategy() {
        // Create multiple discounts with different values
        List<Discount__c> testDiscounts = new List<Discount__c>{
                new Discount__c(
                        Name = 'High Discount',
                        Value_Type__c = ConstUtil.DISCOUNT_VALUE_TYPE_PERCENTAGE,
                        Discount_Value__c = 30.0,
                        Is_Active__c = true
                ),
                new Discount__c(
                        Name = 'Low Discount',
                        Value_Type__c = ConstUtil.DISCOUNT_VALUE_TYPE_PERCENTAGE,
                        Discount_Value__c = 10.0,
                        Is_Active__c = true
                )
        };
        insert testDiscounts;

        List<Discount__c> discounts = [SELECT Id, Name, Value_Type__c, Discount_Value__c FROM Discount__c WHERE Is_Active__c = TRUE];
        Order order = [SELECT Id, TotalAmount FROM Order WHERE Status = :ConstUtil.ORDER_STATUS_DRAFT LIMIT 1];
        DiscountSettings settings = new DiscountSettings(ConstUtil.DISCOUNT_STRATEGY_LOWEST, 50.0);

        Test.startTest();
        Discount__c bestDiscount = BestDiscountCounter.getMatchingDiscount(discounts, settings, order);
        Test.stopTest();

        System.assertNotEquals(null, bestDiscount, 'Best discount should not be null');
    }

    @IsTest
    static void testGetMatchingDiscountWithEmptyList() {
        List<Discount__c> emptyDiscounts = new List<Discount__c>();
        Order order = [SELECT Id, TotalAmount FROM Order WHERE Status = :ConstUtil.ORDER_STATUS_DRAFT LIMIT 1];
        DiscountSettings settings = new DiscountSettings(ConstUtil.DISCOUNT_STRATEGY_HIGHEST, 50.0);

        Test.startTest();
        Discount__c bestDiscount = BestDiscountCounter.getMatchingDiscount(emptyDiscounts, settings, order);
        Test.stopTest();

        System.assertEquals(null, bestDiscount, 'Best discount should be null for empty list');
    }

    @IsTest
    static void testGetMatchingDiscountBasedOnTotalAmountWithPercentage() {
        List<Discount__c> discounts = [SELECT Id, Name, Value_Type__c, Discount_Value__c FROM Discount__c WHERE Is_Active__c = TRUE];
        Decimal totalAmount = 100.0;
        DiscountSettings settings = new DiscountSettings(ConstUtil.DISCOUNT_STRATEGY_HIGHEST, 50.0);

        Test.startTest();
        Discount__c bestDiscount = BestDiscountCounter.getMatchingDiscountBasedOnTotalAmount(discounts, settings, totalAmount);
        Test.stopTest();

        System.assertNotEquals(null, bestDiscount, 'Best discount should not be null');
    }

    @IsTest
    static void testGetMatchingDiscountBasedOnTotalAmountWithFixedAmount() {
        // Create a fixed amount discount
        Discount__c fixedDiscount = new Discount__c(
                Name = 'Fixed Amount Discount',
                Value_Type__c = ConstUtil.DISCOUNT_VALUE_TYPE_FIXED_AMOUNT,
                Discount_Value__c = 25.0,
                Is_Active__c = true
        );
        insert fixedDiscount;

        List<Discount__c> discounts = [SELECT Id, Name, Value_Type__c, Discount_Value__c FROM Discount__c WHERE Is_Active__c = TRUE];
        Decimal totalAmount = 100.0;
        DiscountSettings settings = new DiscountSettings(ConstUtil.DISCOUNT_STRATEGY_HIGHEST, 50.0);

        Test.startTest();
        Discount__c bestDiscount = BestDiscountCounter.getMatchingDiscountBasedOnTotalAmount(discounts, settings, totalAmount);
        Test.stopTest();

        System.assertNotEquals(null, bestDiscount, 'Best discount should not be null');
    }

    @IsTest
    static void testGetMatchingDiscountBasedOnTotalAmountLowestStrategy() {
        // Create multiple discounts
        List<Discount__c> testDiscounts = new List<Discount__c>{
                new Discount__c(
                        Name = 'High Fixed Discount',
                        Value_Type__c = ConstUtil.DISCOUNT_VALUE_TYPE_FIXED_AMOUNT,
                        Discount_Value__c = 40.0,
                        Is_Active__c = true
                ),
                new Discount__c(
                        Name = 'Low Fixed Discount',
                        Value_Type__c = ConstUtil.DISCOUNT_VALUE_TYPE_FIXED_AMOUNT,
                        Discount_Value__c = 15.0,
                        Is_Active__c = true
                )
        };
        insert testDiscounts;

        List<Discount__c> discounts = [SELECT Id, Name, Value_Type__c, Discount_Value__c FROM Discount__c WHERE Is_Active__c = TRUE];
        Decimal totalAmount = 200.0;
        DiscountSettings settings = new DiscountSettings(ConstUtil.DISCOUNT_STRATEGY_LOWEST, 50.0);

        Test.startTest();
        Discount__c bestDiscount = BestDiscountCounter.getMatchingDiscountBasedOnTotalAmount(discounts, settings, totalAmount);
        Test.stopTest();

        System.assertNotEquals(null, bestDiscount, 'Best discount should not be null');
    }

    @IsTest
    static void testGetMatchingDiscountBasedOnTotalAmountWithEmptyList() {
        List<Discount__c> emptyDiscounts = new List<Discount__c>();
        Decimal totalAmount = 100.0;
        DiscountSettings settings = new DiscountSettings(ConstUtil.DISCOUNT_STRATEGY_HIGHEST, 50.0);

        Test.startTest();
        Discount__c bestDiscount = BestDiscountCounter.getMatchingDiscountBasedOnTotalAmount(emptyDiscounts, settings, totalAmount);
        Test.stopTest();

        System.assertEquals(null, bestDiscount, 'Best discount should be null for empty list');
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