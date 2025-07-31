@IsTest
public with sharing class DiscountCalculatorHandlerTests {
    @TestSetup
    static void setup() {
        Product2 product1 = new Product2(
                Name = 'Test Product 1',
                IsActive = true,
                ProductCode = 'TP1',
                Description = 'Test Product 1 Description'
        );
        insert product1;

        Id priceBookId = Test.getStandardPricebookId();

        PricebookEntry pbe1 = new PricebookEntry(
                Pricebook2Id = priceBookId,
                Product2Id = product1.Id,
                UnitPrice = 100.0,
                IsActive = true
        );
        insert pbe1;
        Account account = new Account(
                Name = 'Test Account'
        );
        insert account;

    }
    @IsTest
    static void testApplyDiscountsAfterInsert() {
        Discount__c discount1 = new Discount__c(
                Name = 'Test Discount 1',
                Is_Active__c = true,
                Discount_Type__c = 'Time-Bound',
                Value_Type__c = 'Percentage',
                Discount_Value__c = 10.0,
                Start_Date__c = Date.today(),
                End_Date__c = Date.today().addDays(30)
        );
        insert discount1;
        Discount__c discount2 = new Discount__c(
                Name = 'Test Discount 2',
                Is_Active__c = true,
                Discount_Type__c = 'Time-Bound',
                Value_Type__c = 'Amount',
                Discount_Value__c = 20.0,
                Start_Date__c = Date.today(),
                End_Date__c = Date.today().addDays(30)
        );
        insert discount2;
        Discount__c discount3 = new Discount__c(
                Name = 'Test Discount 3',
                Is_Active__c = false,
                Discount_Type__c = 'Time-Bound',
                Value_Type__c = 'Percentage',
                Discount_Value__c = 15.0,
                Start_Date__c = Date.today().addDays(+5),
                End_Date__c = Date.today().addDays(30)
        );
        insert discount3;

        Account account = [
                SELECT Id
                FROM Account
                WHERE Name = 'Test Account'
                LIMIT 1
        ];

        List<Order> orders = new List<Order>{
                new Order(
                        Name = 'Test Order 1',
                        EffectiveDate = Date.today(),
                        Status = 'Draft',
                        AccountId = account.Id,
                        Pricebook2Id = Test.getStandardPricebookId()
                )
        };
        insert orders;
        PricebookEntry pbe = [
                SELECT Id, Product2Id, UnitPrice
                FROM PricebookEntry
                WHERE Pricebook2Id = :Test.getStandardPricebookId()
                LIMIT 1
        ];

        List<OrderItem> orderItems = new List<OrderItem>{
                new OrderItem(
                        OrderId = orders[0].Id,
                        PricebookEntryId = pbe.Id,
                        Quantity = 2,
                        UnitPrice = 100.0
                )
        };
        insert orderItems;

        orders[0] = [SELECT Id, TotalAmount FROM Order WHERE Id = :orders[0].Id];
        Test.startTest();
        DiscountCalculatorHandler.applyDiscountsAfterInsert(orders);
        Test.stopTest();
        List<Applied_Discount__c> appliedDiscounts = [
                SELECT Id, Order__c, Discount__c, Amount_Discounted__c, Name
                FROM Applied_Discount__c
                WHERE Order__c = :orders[0].Id
        ];
        System.assertEquals(1, appliedDiscounts.size(), 'One discount should be applied to the order');
        System.assertEquals('Test Discount 1', appliedDiscounts[0].Name, 'Discount name should match the applied discount');
        System.assertEquals(20.0, appliedDiscounts[0].Amount_Discounted__c, 'Discount amount should be calculated correctly');
    }

    @IsTest
    static void testApplyDiscountsAfterInsertWithNoActiveDiscounts() {
        Discount__c discount = new Discount__c(
                Name = 'Inactive Discount',
                Is_Active__c = false,
                Discount_Type__c = 'Time-Bound',
                Value_Type__c = 'Percentage',
                Discount_Value__c = 10.0,
                Start_Date__c = Date.today(),
                End_Date__c = Date.today().addDays(30)
        );
        insert discount;
        Account account = [
                SELECT Id
                FROM Account
                WHERE Name = 'Test Account'
                LIMIT 1
        ];
        List<Order> orders = new List<Order>{
                new Order(
                        Name = 'Test Order No Discount',
                        EffectiveDate = Date.today(),
                        Status = 'Draft',
                        AccountId = account.Id,
                        Pricebook2Id = Test.getStandardPricebookId()
                )
        };
        insert orders;
        PricebookEntry pbe = [
                SELECT Id, Product2Id, UnitPrice
                FROM PricebookEntry
                WHERE Pricebook2Id = :Test.getStandardPricebookId()
                LIMIT 1
        ];
        List<OrderItem> orderItems = new List<OrderItem>{
                new OrderItem(
                        OrderId = orders[0].Id,
                        PricebookEntryId = pbe.Id,
                        Quantity = 2,
                        UnitPrice = 100.0
                )
        };
        insert orderItems;
        orders[0] = [SELECT Id, TotalAmount FROM Order WHERE Id = :orders[0].Id];
        Test.startTest();
        DiscountCalculatorHandler.applyDiscountsAfterInsert(orders);
        Test.stopTest();
        List<Applied_Discount__c> appliedDiscounts = [
                SELECT Id, Order__c, Discount__c, Amount_Discounted__c, Name
                FROM Applied_Discount__c
                WHERE Order__c = :orders[0].Id

        ];
        System.assertEquals(0, appliedDiscounts.size(), 'No discounts should be applied to the order when no active discounts are available');
        System.assertEquals(200.0, orders[0].TotalAmount, 'Total amount should remain unchanged when no discounts are applied');
    }
}