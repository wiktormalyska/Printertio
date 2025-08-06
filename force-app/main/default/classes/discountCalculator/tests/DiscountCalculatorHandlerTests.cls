@IsTest
private class DiscountCalculatorHandlerTests {
    @TestSetup
    static void setup() {
        Product2 product1 = (Product2) new ProductTestDataFactory().create();
        insert product1;

        PricebookEntry pbe1 = (PricebookEntry) new PricebookEntryTestDataFactory(product1).create();
        insert pbe1;

        Account account = (Account) new AccountTestDataFactory().create();
        insert account;
    }

    @IsTest
    static void testApplyDiscountsAfterInsert() {
        Discount__c discount1 = DiscountBuilder.create()
                .withName('Test Discount 1')
                .withIsActive(true)
                .withDiscountType('Time-Bound')
                .withValueType('Percentage')
                .withDiscountValue(10.0)
                .withStartDate(Date.today().addDays(-1))
                .withEndDate(Date.today().addDays(30))
                .build();
        insert discount1;

        Discount__c discount2 = DiscountBuilder.create()
                .withName('Test Discount 2')
                .withIsActive(true)
                .withDiscountType('Time-Bound')
                .withValueType('Amount')
                .withDiscountValue(20.0)
                .withStartDate(Date.today())
                .withEndDate(Date.today().addDays(30))
                .build();
        insert discount2;

        Discount__c discount3 = DiscountBuilder.create()
                .withName('Test Discount 3')
                .withIsActive(false)
                .withDiscountType('Time-Bound')
                .withValueType('Percentage')
                .withDiscountValue(15.0)
                .withStartDate(Date.today().addDays(5))
                .withEndDate(Date.today().addDays(30))
                .build();
        insert discount3;

        Account account = [SELECT Id FROM Account WHERE Name = 'Test Account' LIMIT 1];

        Order order = OrderBuilder.create()
                .withName('Test Order 1')
                .withEffectiveDate(Date.today())
                .withStatus('Draft')
                .withAccountId(account.Id)
                .withPricebook2Id(Test.getStandardPricebookId())
                .build();
        insert order;

        PricebookEntry pbe = [SELECT Id FROM PricebookEntry WHERE Pricebook2Id = :Test.getStandardPricebookId() LIMIT 1];

        OrderItem orderItem = OrderItemBuilder.create()
                .withOrderId(order.Id)
                .withPricebookEntryId(pbe.Id)
                .withQuantity(2)
                .withUnitPrice(100.0)
                .build();
        insert orderItem;

        List<Order> orders = [SELECT Id, TotalAmount, AmountAfterDiscount__c FROM Order WHERE Id = :order.Id];

        Test.startTest();
        DiscountCalculatorHandler.applyDiscountsWhenOrderTriggered(orders);
        Test.stopTest();

        Id activeDiscountId = orders[0].Discount__c;
        Discount__c activeDiscount = [SELECT Id, Name FROM Discount__c WHERE Id = :activeDiscountId];

        System.assertNotEquals(null, activeDiscount, 'Active discount should be applied to the order');
        System.assertEquals('Test Discount 1', activeDiscount.Name, 'The applied discount should be Test Discount 1');
        System.assertEquals(180.0, orders[0].AmountAfterDiscount__c, 'Total amount should be reduced by the discount value');
    }

    @IsTest
    static void testApplyDiscountsAfterInsertWithNoActiveDiscounts() {
        Discount__c discount = DiscountBuilder.create()
                .withName('Inactive Discount')
                .withIsActive(false)
                .withDiscountType('Time-Bound')
                .withValueType('Percentage')
                .withDiscountValue(10.0)
                .withStartDate(Date.today().addDays(1))
                .withEndDate(Date.today().addDays(30))
                .build();
        insert discount;

        Account account = [SELECT Id FROM Account WHERE Name = 'Test Account' LIMIT 1];

        Order order = OrderBuilder.create()
                .withName('Test Order No Discount')
                .withEffectiveDate(Date.today())
                .withStatus('Draft')
                .withAccountId(account.Id)
                .withPricebook2Id(Test.getStandardPricebookId())
                .build();
        insert order;

        PricebookEntry pbe = [SELECT Id FROM PricebookEntry WHERE Pricebook2Id = :Test.getStandardPricebookId() LIMIT 1];

        OrderItem orderItem = OrderItemBuilder.create()
                .withOrderId(order.Id)
                .withPricebookEntryId(pbe.Id)
                .withQuantity(2)
                .withUnitPrice(100.0)
                .build();
        insert orderItem;

        List<Order> orders = [SELECT Id, TotalAmount FROM Order WHERE Id = :order.Id];

        Test.startTest();
        DiscountCalculatorHandler.applyDiscountsWhenOrderTriggered(orders);
        Test.stopTest();

        System.assertEquals(null, orders[0].Discount__c, 'No discount should be applied to the order');
    }
}