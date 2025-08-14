@IsTest
private class OrderItemsConditionTests {
    @TestSetup
    static void setup() {
        Account account = (Account) new AccountTestDataFactory().create();
        insert account;

        Order order = (Order) new OrderTestDataFactory(account).create();
        insert order;

        Product2 product = (Product2) new ProductTestDataFactory().create();
        insert product;

        PricebookEntry pricebookEntry = (PricebookEntry) new PricebookEntryTestDataFactory(product).create();
        insert pricebookEntry;

        List<OrderItem> orderItems = new List<OrderItem>();
        for (Integer i = 0; i < 5; i++) {
            OrderItem orderItem = (OrderItem) new OrderItemTestDataFactory(order, pricebookEntry).create();
            orderItems.add(orderItem);
        }
        insert orderItems;
    }


    @IsTest
    static void testGetMatchingDiscountBasedOnTotalAmount() {
        Order order = [SELECT Id, TotalAmount, ( SELECT Quantity FROM OrderItems) FROM Order WHERE Status = :ConstUtil.ORDER.STATUS.DRAFT LIMIT 1];
        Test.startTest();
        OrderItemsCondition condition = new OrderItemsCondition();
        Boolean isApplicable = condition.isApplicable(order);
        Test.stopTest();

        System.assertEquals(true, isApplicable, 'Not enough order items to apply the condition');
    }

    @IsTest
    static void testGetName() {
        OrderItemsCondition condition = new OrderItemsCondition();
        String name = condition.getName();

        System.assertEquals('Order have more than ' + ConstUtil.DISCOUNT.CONDITION_TYPE.MINIMUM_ORDER_ITEM_COUNT + ' items', name, 'Condition name does not match expected format');
    }
}