@IsTest
private with sharing class ProductSyncRetryScheduledJobTests {
//    @TestSetup
//    static void setupTestData() {
//        Test.setMock(HttpCalloutMock.class, new ProductSyncMockHttpSuccess());
//        List<Product2> testProducts = new List<Product2>();
//        for (Integer i = 1; i <= 5; i++) {
//            Product2 product = (Product2) new ProductTestDataFactory().create();
//            product.Name = 'Test Product ' + i;
//            product.ProductCode = 'TEST' + i;
//            product.Description = 'Test Description ' + i;
//            testProducts.add(product);
//        }
//        insert testProducts;
//    }

//    @IsTest
//    static void testExecuteWithNoFailedLogs() {
//        Test.startTest();
//        ProductSyncRetryScheduledJob job = new ProductSyncRetryScheduledJob();
//        job.execute(null);
//        Test.stopTest();
//
//        Assert.isTrue(true, 'Job executed without errors when no failed logs exist');
//    }
//
//    @IsTest
//    static void testProcessFailedSynchronizationsWithSuccessfulRetry() {
//        List<Product2> products = [SELECT Id FROM Product2 LIMIT 2];
//
//        Product_Synchronization_Log__c failedLog = (Product_Synchronization_Log__c) new FailedProductSynchronizationLogFactory().create();
//        failedLog.Retry_Count__c = 1;
//        insert failedLog;
//
//        List<Product_Synchronization_Log_Item__c> logItems = new List<Product_Synchronization_Log_Item__c>();
//        for (Product2 product : products) {
//            logItems.add(new Product_Synchronization_Log_Item__c(
//                    Product_Synchronization_Log__c = failedLog.Id,
//                    Product__c = product.Id
//            ));
//        }
//        insert logItems;
//
//        Test.startTest();
//        ProductSyncRetryScheduledJob job = new ProductSyncRetryScheduledJob();
//        job.execute(null);
//        Test.stopTest();
//
//        Product_Synchronization_Log__c updatedLog = [
//                SELECT Status__c, Retry_Count__c, Response_Body__c
//                FROM Product_Synchronization_Log__c
//                WHERE Id = :failedLog.Id
//        ];
//
//        Assert.areEqual(2, updatedLog.Retry_Count__c, 'Retry count should be incremented');
//    }
//
//    @IsTest
//    static void testProcessFailedSynchronizationsWithMaxRetriesReached() {
//        List<Product2> products = [SELECT Id FROM Product2 LIMIT 2];
//
//        Product_Synchronization_Log__c failedLog = (Product_Synchronization_Log__c) new FailedProductSynchronizationLogFactory().create();
//        failedLog.Retry_Count__c = 3;
//        insert failedLog;
//
//        List<Product_Synchronization_Log_Item__c> logItems = new List<Product_Synchronization_Log_Item__c>();
//        for (Product2 product : products) {
//            logItems.add(new Product_Synchronization_Log_Item__c(
//                    Product_Synchronization_Log__c = failedLog.Id,
//                    Product__c = product.Id
//            ));
//        }
//        insert logItems;
//
//        Test.startTest();
//        ProductSyncRetryScheduledJob job = new ProductSyncRetryScheduledJob();
//        job.execute(null);
//        Test.stopTest();
//
//        Product_Synchronization_Log__c updatedLog = [
//                SELECT Status__c, Retry_Count__c
//                FROM Product_Synchronization_Log__c
//                WHERE Id = :failedLog.Id
//        ];
//
//        Assert.areEqual('FAILED', updatedLog.Status__c, 'Status should be FAILED when max retries reached');
//        Assert.areEqual(3, updatedLog.Retry_Count__c, 'Retry count should remain at max');
//    }
//
//    @IsTest
//    static void testProcessFailedSynchronizationsWithNullRetryCount() {
//        List<Product2> products = [SELECT Id FROM Product2 LIMIT 1];
//
//        Product_Synchronization_Log__c failedLog = (Product_Synchronization_Log__c) new FailedProductSynchronizationLogFactory().create();
//        failedLog.Retry_Count__c = null;
//        insert failedLog;
//
//        Product_Synchronization_Log_Item__c logItem = new Product_Synchronization_Log_Item__c(
//                Product_Synchronization_Log__c = failedLog.Id,
//                Product__c = products[0].Id
//        );
//        insert logItem;
//
//        Test.startTest();
//        ProductSyncRetryScheduledJob job = new ProductSyncRetryScheduledJob();
//        job.execute(null);
//        Test.stopTest();
//
//        Product_Synchronization_Log__c updatedLog = [
//                SELECT Retry_Count__c
//                FROM Product_Synchronization_Log__c
//                WHERE Id = :failedLog.Id
//        ];
//
//        Assert.areEqual(1, updatedLog.Retry_Count__c, 'Retry count should be set to 1 when initially null');
//    }
//
//    @IsTest
//    static void testProcessFailedSynchronizationsWithSyncException() {
//        List<Product2> products = [SELECT Id FROM Product2 LIMIT 1];
//
//        Product_Synchronization_Log__c failedLog = (Product_Synchronization_Log__c) new FailedProductSynchronizationLogFactory().create();
//        failedLog.Retry_Count__c = 1;
//        insert failedLog;
//
//        Product_Synchronization_Log_Item__c logItem = new Product_Synchronization_Log_Item__c(
//                Product_Synchronization_Log__c = failedLog.Id,
//                Product__c = products[0].Id
//        );
//        insert logItem;
//
//        Test.startTest();
//        ProductSyncRetryScheduledJob job = new ProductSyncRetryScheduledJob();
//        job.execute(null);
//        Test.stopTest();
//
//        Product_Synchronization_Log__c updatedLog = [
//                SELECT Status__c, Retry_Count__c, Response_Body__c
//                FROM Product_Synchronization_Log__c
//                WHERE Id = :failedLog.Id
//        ];
//
//        Assert.areEqual(2, updatedLog.Retry_Count__c, 'Retry count should be incremented even on exception');
//    }
//
//    @IsTest
//    static void testProcessFailedSynchronizationsWithMaxRetriesAndException() {
//        Test.setMock(HttpCalloutMock.class, new ProductSyncMockHttpFailed());
//        List<Product2> products = [SELECT Id FROM Product2 LIMIT 1];
//
//        Product_Synchronization_Log__c failedLog = (Product_Synchronization_Log__c) new FailedProductSynchronizationLogFactory().create();
//        failedLog.Retry_Count__c = 3;
//        insert failedLog;
//
//        Product_Synchronization_Log_Item__c logItem = new Product_Synchronization_Log_Item__c(
//                Product_Synchronization_Log__c = failedLog.Id,
//                Product__c = products[0].Id
//        );
//        insert logItem;
//
//        Test.startTest();
//        ProductSyncRetryScheduledJob job = new ProductSyncRetryScheduledJob();
//        job.execute(null);
//        Test.stopTest();
//
//        Product_Synchronization_Log__c updatedLog = [
//                SELECT Status__c, Retry_Count__c, Response_Body__c
//                FROM Product_Synchronization_Log__c
//                WHERE Id = :failedLog.Id
//        ];
//
//        Assert.areEqual('FAILED', updatedLog.Status__c, 'Status should be FAILED when max retries reached after exception');
//        Assert.areEqual(3, updatedLog.Retry_Count__c, 'Retry count should reach max attempts');
//    }
//
//    private class FailedProductSynchronizationLogFactory extends ProductSynchronizationLogTestDataFactory {
//        public override SObject create() {
//            Product_Synchronization_Log__c log = (Product_Synchronization_Log__c) super.create();
//            log.Status__c = 'ERROR';
//            log.Response_Body__c = '[{"id":"01tgK000004iHqrQAE","success":false,"errors":[]}]';
//            log.Retry_Count__c = 0;
//            return log;
//        }
//    }
}