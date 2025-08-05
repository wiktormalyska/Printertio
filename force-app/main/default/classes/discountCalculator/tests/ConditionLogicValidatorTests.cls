@IsTest
private class ConditionLogicValidatorTests {
    @TestSetup
    static void setup() {
        Account account = (Account) new AccountTestDataFactory().create();
        insert account;

        Contract contract = (Contract) new ContractTestDataFactory(account).create();
        insert contract;

        List<Product2> products = new List<Product2>();
        Product2 product1 = (Product2) new ProductTestDataFactory().create();
        products.add(product1);
        Product2 product2 = (Product2) new ProductTestDataFactory().create();
        products.add(product2);
        insert products;

        Id priceBookId = Test.getStandardPricebookId();

        List<PricebookEntry> pricebookEntries = new List<PricebookEntry>();
        PricebookEntry pbe1 = (PricebookEntry) new PricebookEntryTestDataFactory(product1).create();
        pricebookEntries.add(pbe1);
        PricebookEntry pbe2 = (PricebookEntry) new PricebookEntryTestDataFactory(product2).create();
        pricebookEntries.add(pbe2);
        insert pricebookEntries;

        Order order = (Order) new OrderTestDataFactory(account).create();
        insert order;

        List<OrderItem> orderItems = new List<OrderItem>();
        OrderItem orderItem1 = (OrderItem) new OrderItemTestDataFactory(order, pbe1).create();
        orderItems.add(orderItem1);
        OrderItem orderItem2 = (OrderItem) new OrderItemTestDataFactory(order, pbe2).create();
        orderItems.add(orderItem2);
        insert orderItems;
    }

    @IsTest
    static void testAmount_GreaterThan_ReturnsTrue() {
        Discount__c discount = DiscountBuilder.create()
                .withName('Test Discount')
                .withIsActive(true)
                .withDiscountType('Conditional')
                .withConditionLogicField('Order.Products_Amount')
                .withConditionLogicOperator('>')
                .withConditionLogicNumericValue(1)
                .withValueType('Percentage')
                .withDiscountValue(10.0)
                .build();
        insert discount;

        Order order = [SELECT Id, (SELECT Id, UnitPrice, Quantity FROM OrderItems) FROM Order LIMIT 1];
        System.debug('Order : ' + order);

        Test.startTest();
        Boolean result = ConditionLogicValidator.filterDiscountsByConditionLogic(discount, order);
        Test.stopTest();

        System.assertEquals(true, result, 'Result should be true because the number of products (2) is greater than 1.');
    }

    @IsTest
    static void testAmount_LessThan_ReturnsTrue() {
        Discount__c discount = DiscountBuilder.create()
                .withName('Test Discount')
                .withIsActive(true)
                .withDiscountType('Conditional')
                .withConditionLogicField('Order.Products_Amount')
                .withConditionLogicOperator('<')
                .withConditionLogicNumericValue(5)
                .withValueType('Percentage')
                .withDiscountValue(10.0)
                .build();
        insert discount;

        Order order = [SELECT Id, (SELECT Id, UnitPrice, Quantity FROM OrderItems) FROM Order LIMIT 1];
        System.debug('Order : ' + order);

        Test.startTest();
        Boolean result = ConditionLogicValidator.filterDiscountsByConditionLogic(discount, order);
        Test.stopTest();

        System.assertEquals(true, result, 'Result should be true because the number of products (2) is less than 5.');
    }

    @IsTest
    static void testTotalPrice_Equals_ReturnsTrue() {
        Discount__c discount = DiscountBuilder.create()
                .withName('Test Discount')
                .withIsActive(true)
                .withDiscountType('Conditional')
                .withConditionLogicField('Order.Products_Total_Price')
                .withConditionLogicOperator('==')
                .withConditionLogicNumericValue(200.0)
                .withValueType('Percentage')
                .withDiscountValue(10.0)
                .build();
        insert discount;

        Order order = [SELECT Id, (SELECT Id, UnitPrice, Quantity FROM OrderItems) FROM Order LIMIT 1];
        System.debug('Order : ' + order);

        Test.startTest();
        Boolean result = ConditionLogicValidator.filterDiscountsByConditionLogic(discount, order);
        Test.stopTest();

        System.assertEquals(true, result, 'Result should be true because the total price (650) equals 650.');
    }

    @IsTest
    static void testTotalPrice_NotEquals_ReturnsTrue() {
        Discount__c discount = DiscountBuilder.create()
                .withName('Test Discount')
                .withIsActive(true)
                .withDiscountType('Conditional')
                .withConditionLogicField('Order.Products_Total_Price')
                .withConditionLogicOperator('!=')
                .withConditionLogicNumericValue(500.0)
                .withValueType('Percentage')
                .withDiscountValue(10.0)
                .build();
        insert discount;

        Order order = [SELECT Id, (SELECT Id, UnitPrice, Quantity FROM OrderItems) FROM Order LIMIT 1];
        System.debug('Order : ' + order);

        Test.startTest();
        Boolean result = ConditionLogicValidator.filterDiscountsByConditionLogic(discount, order);
        Test.stopTest();

        System.assertEquals(true, result, 'Result should be true because the total price (650) is not equal to 500.');
    }

    @IsTest
    static void testTotalPrice_LessThanOrEqual_ReturnsTrue() {
        Discount__c discount = DiscountBuilder.create()
                .withName('Test Discount')
                .withIsActive(true)
                .withDiscountType('Conditional')
                .withConditionLogicField('Order.Products_Total_Price')
                .withConditionLogicOperator('<=')
                .withConditionLogicNumericValue(1000.0)
                .withValueType('Percentage')
                .withDiscountValue(10.0)
                .build();
        insert discount;

        Order order = [SELECT Id, (SELECT Id, UnitPrice, Quantity FROM OrderItems) FROM Order LIMIT 1];
        System.debug('Order : ' + order);

        Test.startTest();
        Boolean result = ConditionLogicValidator.filterDiscountsByConditionLogic(discount, order);
        Test.stopTest();

        System.assertEquals(true, result, 'Result should be false because the total price (650) is not less than or equal to 1000.');
    }

    @IsTest
    static void testTotalPrice_LessThanOrEqual_ReturnsFalse() {
        Discount__c discount = DiscountBuilder.create()
                .withName('Test Discount')
                .withIsActive(true)
                .withDiscountType('Conditional')
                .withConditionLogicField('Order.Products_Total_Price')
                .withConditionLogicOperator('<=')
                .withConditionLogicNumericValue(100.0)
                .withValueType('Percentage')
                .withDiscountValue(10.0)
                .build();
        insert discount;

        Order order = [SELECT Id, (SELECT Id, UnitPrice, Quantity FROM OrderItems) FROM Order LIMIT 1];
        System.debug('Order : ' + order);

        Test.startTest();
        Boolean result = ConditionLogicValidator.filterDiscountsByConditionLogic(discount, order);
        Test.stopTest();

        System.assertEquals(false, result, 'Result should be false because the total price (650) is not less than or equal to 500.');
    }

    @IsTest
    static void testTotalPrice_GreaterThanOrEqual_ReturnsTrue() {
        Discount__c discount = DiscountBuilder.create()
                .withName('Test Discount')
                .withIsActive(true)
                .withDiscountType('Conditional')
                .withConditionLogicField('Order.Products_Total_Price')
                .withConditionLogicOperator('>=')
                .withConditionLogicNumericValue(200.0)
                .withValueType('Percentage')
                .withDiscountValue(10.0)
                .build();
        insert discount;

        Order order = [SELECT Id, (SELECT Id, UnitPrice, Quantity FROM OrderItems) FROM Order LIMIT 1];
        System.debug('Order : ' + order);

        Test.startTest();
        Boolean result = ConditionLogicValidator.filterDiscountsByConditionLogic(discount, order);
        Test.stopTest();

        System.assertEquals(true, result, 'Result should be true because the total price (650) is greater than or equal to 400.');
    }
}