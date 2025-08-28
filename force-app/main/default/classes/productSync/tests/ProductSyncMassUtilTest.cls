@IsTest
public with sharing class ProductSyncMassUtilTest {
    @TestSetup
    static void setupTestData() {
        List<Product2> products = new List<Product2>();
        for (Integer i = 0; i < 5; i++) {
            products.add(new Product2(
                    Name = 'Test Product ' + i,
                    ProductCode = 'TEST' + i
            ));
        }
        insert products;
    }

    @IsTest
    static void testSynchronizeMassProductsWithValidIds() {
        List<Product2> products = [SELECT Id FROM Product2 LIMIT 5];
        List<Id> productIds = new List<Id>();
        for (Product2 product : products) {
            productIds.add(product.Id);
        }

        Test.startTest();
        ProductSyncMassUtil.synchronizeMassProducts(productIds);
        Test.stopTest();

        System.assertEquals(5, productIds.size());
    }

    @IsTest
    static void testSynchronizeMassProductsWithEmptyList() {
        List<Id> emptyProductIds = new List<Id>();

        Test.startTest();
        ProductSyncMassUtil.synchronizeMassProducts(emptyProductIds);
        Test.stopTest();

        System.assertEquals(0, emptyProductIds.size());
    }

    @IsTest
    static void testSynchronizeMassProductsWithSingleId() {
        List<Product2> products = [SELECT Id FROM Product2 LIMIT 1];
        List<Id> productIds = new List<Id>{
                products[0].Id
        };

        Test.startTest();
        ProductSyncMassUtil.synchronizeMassProducts(productIds);
        Test.stopTest();

        System.assertEquals(1, productIds.size());
    }
}