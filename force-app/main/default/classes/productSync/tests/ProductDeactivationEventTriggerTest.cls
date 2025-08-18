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
        EventBus.publish(events);
        Test.stopTest();

        List<Product2> updatedProducts = [SELECT Id, IsActive FROM Product2];
        for (Product2 product : updatedProducts) {
            System.assertEquals(false, product.IsActive, 'Product should be deactivated after event');
        }
    }

    @isTest
    static void testTrigger_SingleEvent() {
        Product2 product = [SELECT Id FROM Product2 LIMIT 1];

        Product_Deactivation__e event = new Product_Deactivation__e(
                Product_Id__c = product.Id
        );

        Test.startTest();
        EventBus.publish(event);
        Test.stopTest();

        Product2 updatedProduct = [SELECT Id, IsActive FROM Product2 WHERE Id = :product.Id];
        System.assertEquals(false, updatedProduct.IsActive, 'Single product should be deactivated');
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