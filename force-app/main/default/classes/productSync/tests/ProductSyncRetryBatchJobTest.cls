@IsTest
public with sharing class ProductSyncRetryBatchJobTest {
    @TestSetup
    static void setupTestData() {
        List<Product2> products = new List<Product2>();
        for (Integer i = 0; i < 5; i++) {
            products.add(new Product2(
                    Name = 'Test Product ' + i,
                    ProductCode = 'TEST' + i,
                    Description = 'Test Description ' + i,
                    IsActive = true,
                    IsExternal__c = false
            ));
        }
        insert products;

        List<Product_Synchronization_Log__c> logs = new List<Product_Synchronization_Log__c>();

        logs.add(new Product_Synchronization_Log__c(
                Product__c = products[0].Id,
                Status__c = ConstUtil.PRODUCT_SYNC.LOGS.STATUS.ERROR,
                Retry_Count__c = 0,
                Request_Body__c = 'Test Request',
                Response_Body__c = 'Test Error Response'
        ));

        logs.add(new Product_Synchronization_Log__c(
                Product__c = products[1].Id,
                Status__c = ConstUtil.PRODUCT_SYNC.LOGS.STATUS.ERROR,
                Retry_Count__c = ConstUtil.PRODUCT_SYNC.LOGS.MAX_RETRY_ATTEMPTS,
                Request_Body__c = 'Max Retry Request',
                Response_Body__c = 'Max Retry Error'
        ));

        logs.add(new Product_Synchronization_Log__c(
                Product__c = null,
                Status__c = ConstUtil.PRODUCT_SYNC.LOGS.STATUS.ERROR,
                Request_Body__c = 'Null Product Request',
                Response_Body__c = 'Null Product Error'
        ));

        logs.add(new Product_Synchronization_Log__c(
                Product__c = products[2].Id,
                Status__c = ConstUtil.PRODUCT_SYNC.LOGS.STATUS.ERROR,
                Retry_Count__c = null,
                Request_Body__c = 'Null Retry Count Request',
                Response_Body__c = 'Null Retry Count Error'
        ));

        insert logs;
    }

    @IsTest
    static void testStartMethod() {
        Test.startTest();
        ProductSyncRetryBatchJob batchJob = new ProductSyncRetryBatchJob();
        Id batchId = Database.executeBatch(batchJob, 200);
        Test.stopTest();

        List<Product_Synchronization_Log__c> errorLogs = [
                SELECT Id FROM Product_Synchronization_Log__c
                WHERE Status__c = :ConstUtil.PRODUCT_SYNC.LOGS.STATUS.ERROR
        ];

        System.assert(errorLogs.size() > 0);
    }

    @IsTest
    static void testExecuteWithRetryableLog() {
        List<Product_Synchronization_Log__c> logs = [
                SELECT Id, Request_Body__c, Response_Body__c, Retry_Count__c, Status__c,
                        Product__c, Product__r.Name, Product__r.ProductCode, Product__r.Description,
                        Product__r.IsActive, Product__r.ExternalId, Product__r.IsExternal__c
                FROM Product_Synchronization_Log__c
                WHERE Retry_Count__c = 0
                LIMIT 1
        ];

        Test.startTest();
        ProductSyncRetryBatchJob batchJob = new ProductSyncRetryBatchJob();
        batchJob.execute(null, logs);
        Test.stopTest();

        Product_Synchronization_Log__c updatedLog = [
                SELECT Retry_Count__c, Status__c
                FROM Product_Synchronization_Log__c
                WHERE Id = :logs[0].Id
        ];

        System.assertEquals(1, updatedLog.Retry_Count__c);
        System.assertEquals(ConstUtil.PRODUCT_SYNC.LOGS.STATUS.ERROR, updatedLog.Status__c);
    }

    @IsTest
    static void testExecuteWithMaxRetriesReached() {
        List<Product_Synchronization_Log__c> logs = [
                SELECT Id, Request_Body__c, Response_Body__c, Retry_Count__c, Status__c,
                        Product__c, Product__r.Name, Product__r.ProductCode, Product__r.Description,
                        Product__r.IsActive, Product__r.ExternalId, Product__r.IsExternal__c
                FROM Product_Synchronization_Log__c
                WHERE Retry_Count__c = :ConstUtil.PRODUCT_SYNC.LOGS.MAX_RETRY_ATTEMPTS
                LIMIT 1
        ];

        Test.startTest();
        ProductSyncRetryBatchJob batchJob = new ProductSyncRetryBatchJob();
        batchJob.execute(null, logs);
        Test.stopTest();

        Product_Synchronization_Log__c updatedLog = [
                SELECT Retry_Count__c, Status__c
                FROM Product_Synchronization_Log__c
                WHERE Id = :logs[0].Id
        ];

        System.assertEquals(ConstUtil.PRODUCT_SYNC.LOGS.STATUS.FAILED, updatedLog.Status__c);
    }

    @IsTest
    static void testExecuteWithNullProduct() {
        List<Product_Synchronization_Log__c> logs = [
                SELECT Id, Request_Body__c, Response_Body__c, Retry_Count__c, Status__c,
                        Product__c, Product__r.Name, Product__r.ProductCode, Product__r.Description,
                        Product__r.IsActive, Product__r.ExternalId, Product__r.IsExternal__c
                FROM Product_Synchronization_Log__c
                WHERE Product__c = NULL
                LIMIT 1
        ];

        Test.startTest();
        ProductSyncRetryBatchJob batchJob = new ProductSyncRetryBatchJob();
        batchJob.execute(null, logs);
        Test.stopTest();

        Product_Synchronization_Log__c updatedLog = [
                SELECT Status__c
                FROM Product_Synchronization_Log__c
                WHERE Id = :logs[0].Id
        ];

        System.assertEquals(ConstUtil.PRODUCT_SYNC.LOGS.STATUS.FAILED, updatedLog.Status__c);
    }

    @IsTest
    static void testExecuteWithNullRetryCount() {
        List<Product_Synchronization_Log__c> logs = [
                SELECT Id, Request_Body__c, Response_Body__c, Retry_Count__c, Status__c,
                        Product__c, Product__r.Name, Product__r.ProductCode, Product__r.Description,
                        Product__r.IsActive, Product__r.ExternalId, Product__r.IsExternal__c
                FROM Product_Synchronization_Log__c
                WHERE Retry_Count__c = NULL
                LIMIT 1
        ];

        Test.startTest();
        ProductSyncRetryBatchJob batchJob = new ProductSyncRetryBatchJob();
        batchJob.execute(null, logs);
        Test.stopTest();

        Product_Synchronization_Log__c updatedLog = [
                SELECT Retry_Count__c, Status__c
                FROM Product_Synchronization_Log__c
                WHERE Id = :logs[0].Id
        ];

        System.assertEquals(1, updatedLog.Retry_Count__c);
        System.assertEquals(ConstUtil.PRODUCT_SYNC.LOGS.STATUS.ERROR, updatedLog.Status__c);
    }

    @IsTest
    static void testFullBatchExecution() {
        Test.startTest();
        ProductSyncRetryBatchJob batchJob = new ProductSyncRetryBatchJob();
        Database.executeBatch(batchJob, 200);
        Test.stopTest();

        List<Product_Synchronization_Log__c> failedLogs = [
                SELECT Status__c
                FROM Product_Synchronization_Log__c
                WHERE Status__c = :ConstUtil.PRODUCT_SYNC.LOGS.STATUS.FAILED
        ];

        System.assert(failedLogs.size() > 0);
    }

    @IsTest
    static void testFinishMethod() {
        Test.startTest();
        ProductSyncRetryBatchJob batchJob = new ProductSyncRetryBatchJob();
        batchJob.finish(null);
        Test.stopTest();

        System.assert(true);
    }
}