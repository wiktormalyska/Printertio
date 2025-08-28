@isTest
private class ProductDeactivateQueueableTest {

    @TestSetup
    static void setupTestData() {
        List<Product2> products = new List<Product2>();
        for (Integer i = 0; i < 5; i++) {
            products.add(new Product2(
                    Name = 'Test Product ' + i,
                    ProductCode = 'TEST' + i,
                    Description = 'Test Description ' + i,
                    IsActive = true
            ));
        }
        insert products;
    }

    @isTest
    static void testExecute_DeactivatesProducts() {
        List<Product2> products = [SELECT Id FROM Product2];
        List<Id> productIds = new List<Id>();
        for (Product2 product : products) {
            productIds.add(product.Id);
        }

        Test.startTest();
        System.enqueueJob(new ProductDeactivateQueueable(productIds));
        Test.stopTest();

        List<Product2> updatedProducts = [SELECT Id, IsActive, Family FROM Product2 WHERE Id IN :productIds];
        for (Product2 product : updatedProducts) {
            System.assertEquals(false, product.IsActive, 'Product should be deactivated');
        }
    }

    @isTest
    static void testExecute_EmptyProductIds() {
        List<Id> emptyProductIds = new List<Id>();

        Test.startTest();
        System.enqueueJob(new ProductDeactivateQueueable(emptyProductIds));
        Test.stopTest();

        List<Product2> products = [SELECT Id, Family, IsActive FROM Product2];
        for (Product2 product : products) {
            System.assertEquals(true, product.IsActive, 'Products should remain active');
        }
    }
}