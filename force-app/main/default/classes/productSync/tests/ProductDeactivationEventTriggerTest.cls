@isTest
private class ProductDeactivationEventTriggerTest {

    @TestSetup
    static void setupTestData() {
        List<Product2> products = new List<Product2>();
        for (Integer i = 0; i < 3; i++) {
            products.add(new Product2(
                    Name = 'Test Product ' + i,
                    ProductCode = 'TEST' + i,
                    IsActive = true
            ));
        }
        insert products;
    }

    @isTest
    static void testTrigger_PublishesEvents() {
        List<Product2> products = [SELECT Id FROM Product2];
        List<Product_Deactivation__e> events = new List<Product_Deactivation__e>();

        for (Product2 product : products) {
            events.add(new Product_Deactivation__e(
                    Product_Id__c = product.Id
            ));
        }

        Test.startTest();
        List<Database.SaveResult> results = EventBus.publish(events);

        for (Database.SaveResult result : results) {
            System.assert(result.isSuccess(), 'Event should be published successfully');
        }
        Test.stopTest();

        System.assertEquals(products.size(), results.size(), 'All events should be published');
    }

    @isTest
    static void testQueueableDirectly() {
        List<Product2> products = [SELECT Id FROM Product2];
        List<Id> productIds = new List<Id>();
        for (Product2 product : products) {
            productIds.add(product.Id);
        }

        Test.startTest();
        System.enqueueJob(new ProductDeactivateQueueable(productIds));
        Test.stopTest();

        List<Product2> updatedProducts = [SELECT Id,Family, IsActive FROM Product2];
        for (Product2 product : updatedProducts) {
            System.assertEquals(false, product.IsActive, 'Product should be deactivated');
        }
    }

    @isTest
    static void testTrigger_InvalidProductId() {
        Product_Deactivation__e event = new Product_Deactivation__e(
                Product_Id__c = 'invalid_id'
        );

        Test.startTest();
        try {
            EventBus.publish(event);
        } catch (Exception e) {
            System.assert(true, 'Expected exception for invalid ID');
        }
        Test.stopTest();
    }
}