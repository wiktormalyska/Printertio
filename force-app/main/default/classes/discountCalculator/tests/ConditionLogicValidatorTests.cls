@IsTest
public with sharing class ConditionLogicValidatorTests {
    @TestSetup
    static void setup() {
        Account account = new Account(
                Name = 'Test Account',
                Type = 'Customer'
        );
        insert account;

        Contract contract = new Contract(
                AccountId = account.Id,
                StartDate = Date.today(),
                Status = 'Draft',
                ContractTerm = 12
        );

        Product2 product1 = new Product2(
                Name = 'Test Product 1',
                IsActive = true,
                ProductCode = 'TP1',
                Description = 'Test Product 1 Description'
        );
        insert product1;
        Product2 product2 = new Product2(
                Name = 'Test Product 2',
                IsActive = true,
                ProductCode = 'TP2',
                Description = 'Test Product 2 Description'
        );
        insert product2;

        Id priceBookId = Test.getStandardPricebookId();

        PricebookEntry pbe1 = new PricebookEntry(
                Pricebook2Id = priceBookId,
                Product2Id = product1.Id,
                UnitPrice = 100.0,
                IsActive = true
        );
        insert pbe1;
        PricebookEntry pbe2 = new PricebookEntry(
                Pricebook2Id = priceBookId,
                Product2Id = product2.Id,
                UnitPrice = 150.0,
                IsActive = true
        );
        insert pbe2;

        Order order = new Order(
                Name = 'Test Order',
                EffectiveDate = Date.today(),
                Status = 'Draft',
                AccountId = account.Id,
                ContractId = contract.Id,
                Pricebook2Id = priceBookId
        );
        insert order;

        OrderItem orderItem1 = new OrderItem(
                OrderId = order.Id,
                PricebookEntryId = pbe1.Id,
                Quantity = 2,
                UnitPrice = 100.0
        );
        insert orderItem1;
        OrderItem orderItem2 = new OrderItem(
                OrderId = order.Id,
                PricebookEntryId = pbe2.Id,
                Quantity = 3,
                UnitPrice = 150.0
        );
        insert orderItem2;
    }

    @IsTest
    static void testAmount_GreaterThan_ReturnsTrue() {
        Discount__c discount = new Discount__c(
                Name = 'Test Discount',
                Is_Active__c = true,
                Discount_Type__c = 'Conditional',
                Condition_Logic_Field__c = 'Order.Products_Amount',
                Condition_Logic_Operator__c = '>',
                Condition_Logic_Numeric_Value__c = 1,
                Value_Type__c = 'Percentage',
                Discount_Value__c = 10.0
        );
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
        Discount__c discount = new Discount__c(
                Name = 'Test Discount',
                Is_Active__c = true,
                Discount_Type__c = 'Conditional',
                Condition_Logic_Field__c = 'Order.Products_Amount',
                Condition_Logic_Operator__c = '<',
                Condition_Logic_Numeric_Value__c = 5,
                Value_Type__c = 'Percentage',
                Discount_Value__c = 10.0
        );
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
        Discount__c discount = new Discount__c(
                Name = 'Test Discount',
                Is_Active__c = true,
                Discount_Type__c = 'Conditional',
                Condition_Logic_Field__c = 'Order.Products_Total_Price',
                Condition_Logic_Operator__c = '==',
                Condition_Logic_Numeric_Value__c = 650.0,
                Value_Type__c = 'Percentage',
                Discount_Value__c = 10.0
        );
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
        Discount__c discount = new Discount__c(
                Name = 'Test Discount',
                Is_Active__c = true,
                Discount_Type__c = 'Conditional',
                Condition_Logic_Field__c = 'Order.Products_Total_Price',
                Condition_Logic_Operator__c = '!=',
                Condition_Logic_Numeric_Value__c = 500.0,
                Value_Type__c = 'Percentage',
                Discount_Value__c = 10.0
        );
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
        Discount__c discount = new Discount__c(
                Name = 'Test Discount',
                Is_Active__c = true,
                Discount_Type__c = 'Conditional',
                Condition_Logic_Field__c = 'Order.Products_Total_Price',
                Condition_Logic_Operator__c = '<=',
                Condition_Logic_Numeric_Value__c = 1000.0,
                Value_Type__c = 'Percentage',
                Discount_Value__c = 10.0
        );
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
        Discount__c discount = new Discount__c(
                Name = 'Test Discount',
                Is_Active__c = true,
                Discount_Type__c = 'Conditional',
                Condition_Logic_Field__c = 'Order.Products_Total_Price',
                Condition_Logic_Operator__c = '<=',
                Condition_Logic_Numeric_Value__c = 500.0,
                Value_Type__c = 'Percentage',
                Discount_Value__c = 10.0
        );
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
        Discount__c discount = new Discount__c(
                Name = 'Test Discount',
                Is_Active__c = true,
                Discount_Type__c = 'Conditional',
                Condition_Logic_Field__c = 'Order.Products_Total_Price',
                Condition_Logic_Operator__c = '>=',
                Condition_Logic_Numeric_Value__c = 400.0,
                Value_Type__c = 'Percentage',
                Discount_Value__c = 10.0
        );
        insert discount;

        Order order = [SELECT Id, (SELECT Id, UnitPrice, Quantity FROM OrderItems) FROM Order LIMIT 1];
        System.debug('Order : ' + order);

        Test.startTest();
        Boolean result = ConditionLogicValidator.filterDiscountsByConditionLogic(discount, order);
        Test.stopTest();

        System.assertEquals(true, result, 'Result should be true because the total price (650) is greater than or equal to 400.');
    }
}