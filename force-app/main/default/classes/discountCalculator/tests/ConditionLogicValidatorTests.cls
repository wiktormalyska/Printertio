@IsTest
private class ConditionLogicValidatorTests {
    @TestSetup
    static void setup() {
        Test.setMock(HttpCalloutMock.class, new ProductSyncMockHttpSuccess());
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

        List<PricebookEntry> pricebookEntries = new List<PricebookEntry>();
        PricebookEntry pbe1 = (PricebookEntry) new PricebookEntryTestDataFactory(product1).create();
        pricebookEntries.add(pbe1);
        PricebookEntry pbe2 = (PricebookEntry) new PricebookEntryTestDataFactory(product2).create();
        pricebookEntries.add(pbe2);
        insert pricebookEntries;

        Order order = (Order) new OrderTestDataFactory(account).create();
        insert order;

        OrderItem orderItem = (OrderItem) new FiveQuantityOrderItemTestDataFactory(order, pbe1).create();
        insert orderItem;

        Discount__c discount = (Discount__c) new ConditionLogicDiscountTestDataFactory().create();
        insert discount;
    }

    @IsTest
    static void testFilterDiscountsByConditionLogic() {
        Discount__c discount = [SELECT Id, Name, Condition_Logic__c FROM Discount__c WHERE Is_Active__c = TRUE LIMIT 1];
        Order order = [SELECT Id, TotalAmount, (SELECT Quantity FROM OrderItems) FROM Order WHERE Status = :ConstUtil.ORDER.STATUS.DRAFT LIMIT 1];
        Test.startTest();
        Boolean filteredDiscounts = ConditionLogicValidator.filterDiscountsByConditionLogic(discount, order);
        Test.stopTest();

        System.assertEquals(true, filteredDiscounts, 'Discount should be applicable based on condition logic');
    }

    private class ConditionLogicDiscountTestDataFactory extends DiscountTestDataFactory {
        public override SObject create() {
            Discount__c discount = (Discount__c) super.create();
            discount.Name = 'Condition Logic Discount';
            discount.Condition_Logic__c = 'OrderItemsCondition';
            return discount;
        }
    }

    private class FiveQuantityOrderItemTestDataFactory extends OrderItemTestDataFactory {
        private FiveQuantityOrderItemTestDataFactory(Order order, PricebookEntry pricebookEntry) {
            super(order, pricebookEntry);
        }

        public override SObject create() {
            OrderItem orderItem = (OrderItem) super.create();
            orderItem.Quantity = 5;
            return orderItem;
        }
    }
}