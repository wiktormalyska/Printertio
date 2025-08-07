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
        Order order = [SELECT Id, TotalAmount FROM Order WHERE Status = :ConstUtil.ORDER.STATUS.DRAFT LIMIT 1];
        DiscountSettings settings = new DiscountSettings(ConstUtil.DISCOUNT.STRATEGY.HIGHEST, 50.0);

        Test.startTest();
        Discount__c bestDiscount = BestDiscountCounter.getMatchingDiscount(discounts, settings, order);
        Test.stopTest();

        System.assertNotEquals(null, bestDiscount, 'Best discount should not be null');
        System.assertEquals('Test Discount', bestDiscount.Name, 'Best discount should be the one with the highest percentage');
    }

    @IsTest
    static void testGetMatchingDiscountWithFixedAmount() {
        // Create a fixed amount discount
        Discount__c fixedDiscount = (Discount__c) new FixedAmountDiscountTestDataFactory().create();
        insert fixedDiscount;

        List<Discount__c> discounts = [SELECT Id, Name, Value_Type__c, Discount_Value__c FROM Discount__c WHERE Is_Active__c = TRUE];
        Order order = [SELECT Id, TotalAmount FROM Order WHERE Status = :ConstUtil.ORDER.STATUS.DRAFT LIMIT 1];
        DiscountSettings settings = new DiscountSettings(ConstUtil.DISCOUNT.STRATEGY.HIGHEST, 50.0);

        Test.startTest();
        Discount__c bestDiscount = BestDiscountCounter.getMatchingDiscount(discounts, settings, order);
        Test.stopTest();

        System.assertNotEquals(null, bestDiscount, 'Best discount should not be null');
    }

    @IsTest
    static void testGetMatchingDiscountLowestStrategy() {
        List<Discount__c> testDiscounts = new List<Discount__c>{
                (Discount__c) new DiscountTestDataFactory().create(),
                (Discount__c) new MaxDiscountTestDataFactory().create()
        };
        insert testDiscounts;

        List<Discount__c> discounts = [SELECT Id, Name, Value_Type__c, Discount_Value__c FROM Discount__c WHERE Is_Active__c = TRUE];
        Order order = [SELECT Id, TotalAmount FROM Order WHERE Status = :ConstUtil.ORDER.STATUS.DRAFT LIMIT 1];
        DiscountSettings settings = new DiscountSettings(ConstUtil.DISCOUNT.STRATEGY.LOWEST, 100.0);

        Test.startTest();
        Discount__c bestDiscount = BestDiscountCounter.getMatchingDiscount(discounts, settings, order);
        Test.stopTest();

        System.assertNotEquals(null, bestDiscount, 'Best discount should not be null');
    }

    @IsTest
    static void testGetMatchingDiscountWithEmptyList() {
        List<Discount__c> emptyDiscounts = new List<Discount__c>();
        Order order = [SELECT Id, TotalAmount FROM Order WHERE Status = :ConstUtil.ORDER.STATUS.DRAFT LIMIT 1];
        DiscountSettings settings = new DiscountSettings(ConstUtil.DISCOUNT.STRATEGY.HIGHEST, 50.0);

        Test.startTest();
        Discount__c bestDiscount = BestDiscountCounter.getMatchingDiscount(emptyDiscounts, settings, order);
        Test.stopTest();

        System.assertEquals(null, bestDiscount, 'Best discount should be null for empty list');
    }

    @IsTest
    static void testGetMatchingDiscountBasedOnTotalAmountWithPercentage() {
        List<Discount__c> discounts = [SELECT Id, Name, Value_Type__c, Discount_Value__c FROM Discount__c WHERE Is_Active__c = TRUE];
        Decimal totalAmount = 100.0;
        DiscountSettings settings = new DiscountSettings(ConstUtil.DISCOUNT.STRATEGY.HIGHEST, 50.0);

        Test.startTest();
        Discount__c bestDiscount = BestDiscountCounter.getMatchingDiscountBasedOnTotalAmount(discounts, settings, totalAmount);
        Test.stopTest();

        System.assertNotEquals(null, bestDiscount, 'Best discount should not be null');
    }

    @IsTest
    static void testGetMatchingDiscountBasedOnTotalAmountWithFixedAmount() {
        // Create a fixed amount discount
        Discount__c fixedDiscount = (Discount__c) new FixedAmountDiscountTestDataFactory().create();
        insert fixedDiscount;

        List<Discount__c> discounts = [SELECT Id, Name, Value_Type__c, Discount_Value__c FROM Discount__c WHERE Is_Active__c = TRUE];
        Decimal totalAmount = 100.0;
        DiscountSettings settings = new DiscountSettings(ConstUtil.DISCOUNT.STRATEGY.HIGHEST, 50.0);

        Test.startTest();
        Discount__c bestDiscount = BestDiscountCounter.getMatchingDiscountBasedOnTotalAmount(discounts, settings, totalAmount);
        Test.stopTest();

        System.assertNotEquals(null, bestDiscount, 'Best discount should not be null');
    }

    @IsTest
    static void testGetMatchingDiscountBasedOnTotalAmountLowestStrategy() {
        // Create multiple discounts
        List<Discount__c> testDiscounts = new List<Discount__c>{
                (Discount__c) new MaxDiscountTestDataFactory().create(),
                (Discount__c) new DiscountTestDataFactory().create()
        };
        insert testDiscounts;

        List<Discount__c> discounts = [SELECT Id, Name, Value_Type__c, Discount_Value__c FROM Discount__c WHERE Is_Active__c = TRUE];
        Decimal totalAmount = 200.0;
        DiscountSettings settings = new DiscountSettings(ConstUtil.DISCOUNT.STRATEGY.LOWEST, 50.0);

        Test.startTest();
        Discount__c bestDiscount = BestDiscountCounter.getMatchingDiscountBasedOnTotalAmount(discounts, settings, totalAmount);
        Test.stopTest();

        System.assertNotEquals(null, bestDiscount, 'Best discount should not be null');
    }

    @IsTest
    static void testGetMatchingDiscountBasedOnTotalAmountWithEmptyList() {
        List<Discount__c> emptyDiscounts = new List<Discount__c>();
        Decimal totalAmount = 100.0;
        DiscountSettings settings = new DiscountSettings(ConstUtil.DISCOUNT.STRATEGY.HIGHEST, 50.0);

        Test.startTest();
        Discount__c bestDiscount = BestDiscountCounter.getMatchingDiscountBasedOnTotalAmount(emptyDiscounts, settings, totalAmount);
        Test.stopTest();

        System.assertEquals(null, bestDiscount, 'Best discount should be null for empty list');
    }

    private class TimeBoundDiscountDataFactory extends DiscountTestDataFactory {
        public override SObject create() {
            Discount__c discount = (Discount__c) super.create();
            discount.Discount_Type__c = ConstUtil.DISCOUNT.TYPE.TIME_BOUND;
            discount.Value_Type__c = ConstUtil.DISCOUNT.VALUE.TYPE.PERCENTAGE;
            discount.Discount_Value__c = 20.0;
            discount.Start_Date__c = Date.today();
            discount.End_Date__c = Date.today().addDays(30);
            return discount;
        }
    }

    private class FixedAmountDiscountTestDataFactory extends DiscountTestDataFactory {
        public override SObject create() {
            Discount__c discount = (Discount__c) super.create();
            discount.Discount_Type__c = ConstUtil.DISCOUNT.TYPE.TIME_BOUND;
            discount.Value_Type__c = ConstUtil.DISCOUNT.VALUE.TYPE.FIXED_AMOUNT;
            discount.Discount_Value__c = 50.0;
            discount.Start_Date__c = Date.today();
            discount.End_Date__c = Date.today().addDays(30);
            return discount;
        }
    }

    private class MaxDiscountTestDataFactory extends DiscountTestDataFactory {
        public override SObject create() {
            Discount__c discount = (Discount__c) super.create();
            discount.Discount_Type__c = ConstUtil.DISCOUNT.TYPE.TIME_BOUND;
            discount.Value_Type__c = ConstUtil.DISCOUNT.VALUE.TYPE.FIXED_AMOUNT;
            discount.Discount_Value__c = 100.0;
            discount.Start_Date__c = Date.today();
            discount.End_Date__c = Date.today().addDays(30);
            return discount;
        }
    }
}