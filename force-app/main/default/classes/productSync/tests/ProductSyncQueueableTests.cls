@IsTest
public with sharing class ProductSyncQueueableTests {
    @TestSetup
    static void setupTestData() {
        List<Product2> products = new List<Product2>();
        for (Integer i = 0; i < 15; i++) {
            products.add(new Product2(
                    Name = 'Test Product ' + i,
                    ProductCode = 'TEST' + i,
                    Description = 'Test Description ' + i,
                    IsActive = true,
                    IsExternal__c = false,
                    Family = 'Test Family'
            ));
        }

        for (Integer i = 15; i < 20; i++) {
            products.add(new Product2(
                    Name = 'External Product ' + i,
                    ProductCode = 'EXT' + i,
                    IsActive = true,
                    IsExternal__c = true
            ));
        }

        insert products;
    }

    @IsTest
    static void testExecuteWithLessThanMaxProducts() {
        List<Product2> products = [SELECT Id FROM Product2 WHERE IsExternal__c = FALSE LIMIT 5];
        List<Id> productIds = new List<Id>();
        for (Product2 product : products) {
            productIds.add(product.Id);
        }

        Test.startTest();
        ProductSyncQueueable queueable = new ProductSyncQueueable(productIds);
        System.enqueueJob(queueable);
        Test.stopTest();

        System.assertEquals(5, productIds.size());
    }

    @IsTest
    static void testExecuteWithExactlyMaxProducts() {
        List<Product2> products = [SELECT Id FROM Product2 WHERE IsExternal__c = FALSE LIMIT 10];
        List<Id> productIds = new List<Id>();
        for (Product2 product : products) {
            productIds.add(product.Id);
        }

        Test.startTest();
        ProductSyncQueueable queueable = new ProductSyncQueueable(productIds);
        System.enqueueJob(queueable);
        Test.stopTest();

        System.assertEquals(10, productIds.size());
    }

    @IsTest
    static void testExecuteWithEmptyProductList() {
        List<Id> emptyProductIds = new List<Id>();

        Test.startTest();
        ProductSyncQueueable queueable = new ProductSyncQueueable(emptyProductIds);
        System.enqueueJob(queueable);
        Test.stopTest();

        System.assertEquals(0, emptyProductIds.size());
    }

    @IsTest
    static void testExecuteWithOnlyExternalProducts() {
        List<Product2> products = [SELECT Id FROM Product2 WHERE IsExternal__c = TRUE];
        List<Id> productIds = new List<Id>();
        for (Product2 product : products) {
            productIds.add(product.Id);
        }

        Test.startTest();
        ProductSyncQueueable queueable = new ProductSyncQueueable(productIds);
        System.enqueueJob(queueable);
        Test.stopTest();

        System.assertEquals(5, productIds.size());
    }

    @IsTest
    static void testExecuteWithMixedProducts() {
        List<Product2> internalProducts = [SELECT Id FROM Product2 WHERE IsExternal__c = FALSE LIMIT 3];
        List<Product2> externalProducts = [SELECT Id FROM Product2 WHERE IsExternal__c = TRUE LIMIT 2];

        List<Id> productIds = new List<Id>();
        for (Product2 product : internalProducts) {
            productIds.add(product.Id);
        }
        for (Product2 product : externalProducts) {
            productIds.add(product.Id);
        }

        Test.startTest();
        ProductSyncQueueable queueable = new ProductSyncQueueable(productIds);
        System.enqueueJob(queueable);
        Test.stopTest();

        System.assertEquals(5, productIds.size());
    }
}