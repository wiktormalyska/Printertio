@IsTest
public with sharing class ComplaintFormControllerTests {
    @TestSetup
    static void setupTestData() {
        Account testAccount = (Account) new AccountTestDataFactory().create();
        insert testAccount;

        Order testOrder = (Order) new OrderTestDataFactory(testAccount).create();
        insert testOrder;

        Product2 testProduct = (Product2) new ProductTestDataFactory().create();
        insert testProduct;

        PricebookEntry testPricebookEntry = (PricebookEntry) new PricebookEntryTestDataFactory(testProduct).create();
        insert testPricebookEntry;

        OrderItem testOrderItem = (OrderItem) new OrderItemTestDataFactory(testOrder,testPricebookEntry).create();
        insert testOrderItem;
    }

    @IsTest
    static void testGetOrderItemsFromOrderId_Success() {
        Order testOrder = [SELECT Id FROM Order LIMIT 1];
        OrderItem expectedOrderItem = [SELECT Id FROM OrderItem WHERE OrderId = :testOrder.Id LIMIT 1];

        Test.startTest();
        List<OrderItem> result = ComplaintFormController.getOrderItemsFromOrderId(testOrder.Id);
        Test.stopTest();

        Assert.areEqual(1, result.size(), 'Should return one order item');
        Assert.areEqual(expectedOrderItem.Id, result[0].Id, 'Should return correct order item');
    }

    @IsTest
    static void testGetOrderItemsFromOrderId_NoResults() {
        Order testOrder = new Order(
                AccountId = [SELECT Id FROM Account LIMIT 1].Id,
                EffectiveDate = Date.today(),
                Status = 'Draft',
                Pricebook2Id = Test.getStandardPricebookId()
        );
        insert testOrder;

        Test.startTest();
        List<OrderItem> result = ComplaintFormController.getOrderItemsFromOrderId(testOrder.Id);
        Test.stopTest();

        Assert.areEqual(0, result.size(), 'Should return empty list when no order items exist');
    }

    @IsTest
    static void testSubmitComplaintForApproval_Success() {
        OrderItem testOrderItem = [SELECT Id FROM OrderItem LIMIT 1];
        List<Id> orderItemIds = new List<Id>{ testOrderItem.Id };

        Test.startTest();
        ComplaintSubmissionResult result = ComplaintFormController.submitComplaintForApproval(orderItemIds);
        Test.stopTest();

        Assert.isNotNull(result, 'Result should not be null');
    }

    @IsTest
    static void testSubmitComplaintForApproval_EmptyList() {
        List<Id> emptyOrderItemIds = new List<Id>();

        Test.startTest();
        try {
            ComplaintFormController.submitComplaintForApproval(emptyOrderItemIds);
            Assert.fail('Expected AuraHandledException to be thrown');
        } catch (AuraHandledException e) {
            Assert.isNotNull(e.getMessage(), 'Exception message should not be null');
        }
        Test.stopTest();
    }
}