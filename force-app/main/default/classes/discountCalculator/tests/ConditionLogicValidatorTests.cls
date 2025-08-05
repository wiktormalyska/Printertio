@IsTest
private class ConditionLogicValidatorTests {
    @TestSetup
    static void setup() {
        Account account = AccountBuilder.create()
                .withName('Test Account')
                .withType('Customer')
                .build();
        insert account;

        Contract contract = ContractBuilder.create()
                .withAccountId(account.Id)
                .withStartDate(Date.today())
                .withStatus('Draft')
                .withContractTerm(12)
                .build();
        insert contract;

        Product2 product1 = ProductBuilder.create()
                .withName('Test Product 1')
                .withIsActive(true)
                .withProductCode('TP1')
                .withDescription('Test Product 1 Description')
                .build();
        insert product1;

        Product2 product2 = ProductBuilder.create()
                .withName('Test Product 2')
                .withIsActive(true)
                .withProductCode('TP2')
                .withDescription('Test Product 2 Description')
                .build();
        insert product2;

        Id priceBookId = Test.getStandardPricebookId();

        PricebookEntry pbe1 = PricebookEntryBuilder.create()
                .withPricebook2Id(priceBookId)
                .withProduct2Id(product1.Id)
                .withUnitPrice(100.0)
                .withIsActive(true)
                .build();
        insert pbe1;

        PricebookEntry pbe2 = PricebookEntryBuilder.create()
                .withPricebook2Id(priceBookId)
                .withProduct2Id(product2.Id)
                .withUnitPrice(150.0)
                .withIsActive(true)
                .build();
        insert pbe2;

        Order order = OrderBuilder.create()
                .withName('Test Order')
                .withEffectiveDate(Date.today())
                .withStatus('Draft')
                .withAccountId(account.Id)
                .withContractId(contract.Id)
                .withPricebook2Id(priceBookId)
                .build();
        insert order;

        OrderItem orderItem1 = OrderItemBuilder.create()
                .withOrderId(order.Id)
                .withPricebookEntryId(pbe1.Id)
                .withQuantity(2)
                .withUnitPrice(100.0)
                .build();
        insert orderItem1;

        OrderItem orderItem2 = OrderItemBuilder.create()
                .withOrderId(order.Id)
                .withPricebookEntryId(pbe2.Id)
                .withQuantity(3)
                .withUnitPrice(150.0)
                .build();
        insert orderItem2;
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
                .withConditionLogicNumericValue(650.0)
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
                .withConditionLogicNumericValue(400.0)
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