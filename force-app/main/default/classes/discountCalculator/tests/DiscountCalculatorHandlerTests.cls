@IsTest
private class DiscountCalculatorHandlerTests {
    @TestSetup
    static void setup() {
        Test.setMock(HttpCalloutMock.class, new ProductSyncMockHttpSuccess());
        Product2 product1 = (Product2) new ProductTestDataFactory().create();
        insert product1;

        PricebookEntry pbe = (PricebookEntry) new PricebookEntryTestDataFactory(product1).create();
        insert pbe;

        Account account = (Account) new AccountTestDataFactory().create();
        insert account;

        Order order = (Order) new OrderTestDataFactory(account).create();
        insert order;

        OrderItem orderItem = (OrderItem) new OrderItemTestDataFactory(order, pbe).create();
        insert orderItem;
    }

    @IsTest
    static void testApplyDiscountsAfterInsert() {
        List<Discount__c> discounts = new List<Discount__c>();

        Discount__c discount1 = (Discount__c) new lowDiscountTestDataFactory().create();
        discounts.add(discount1);

        Discount__c discount2 = (Discount__c) new mediumDiscountTestDataFactory().create();
        discounts.add(discount2);
        Discount__c discount3 = (Discount__c) new highDiscountTestDataFactory().create();
        discounts.add(discount3);

        insert discounts;

        List<Order> orders = [SELECT Id, TotalAmount, AmountAfterDiscount__c FROM Order];

        Test.startTest();
        DiscountCalculatorHandler.applyDiscountsWhenOrderTriggered(orders);
        Test.stopTest();

        Id activeDiscountId = orders[0].Discount__c;
        Discount__c activeDiscount = [SELECT Id, Name FROM Discount__c WHERE Id = :activeDiscountId];

        System.assertNotEquals(null, activeDiscount, 'Active discount should be applied to the order');
        System.assertEquals('Test Discount', activeDiscount.Name, 'The applied discount should be Test Discount 1');
        System.assertEquals(50, orders[0].AmountAfterDiscount__c, 'Total amount should be reduced by the discount value');
    }

    @IsTest
    static void testApplyDiscountsAfterInsertWithNoActiveDiscounts() {
        Discount__c discount = (Discount__c) new inactiveDiscountTestDataFactory().create();
        insert discount;

        List<Order> orders = [SELECT Id, TotalAmount FROM Order];

        Test.startTest();
        DiscountCalculatorHandler.applyDiscountsWhenOrderTriggered(orders);
        Test.stopTest();

        System.assertEquals(null, orders[0].Discount__c, 'No discount should be applied to the order');
    }

    private class lowDiscountTestDataFactory extends DiscountTestDataFactory {
        public override SObject create() {
            Discount__c discount = (Discount__c) super.create();
            discount.Discount_Value__c = 5.0;
            return discount;
        }
    }

    private class mediumDiscountTestDataFactory extends DiscountTestDataFactory {
        public override SObject create() {
            Discount__c discount = (Discount__c) super.create();
            discount.Discount_Value__c = 20.0;
            return discount;
        }
    }

    private class highDiscountTestDataFactory extends DiscountTestDataFactory {
        public override SObject create() {
            Discount__c discount = (Discount__c) super.create();
            discount.Discount_Value__c = 50.0;
            return discount;
        }
    }

    private class inactiveDiscountTestDataFactory extends DiscountTestDataFactory {
        public override SObject create() {
            Discount__c discount = (Discount__c) super.create();
            discount.Is_Active__c = false;
            return discount;
        }
    }
}