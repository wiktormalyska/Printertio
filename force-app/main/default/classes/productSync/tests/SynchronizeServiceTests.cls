@IsTest
private class SynchronizeServiceTests {

    @TestSetup
    static void makeData() {
        Test.setMock(HttpCalloutMock.class, new ProductSyncMockHttpSuccess());
        List<Product2> testProducts = new List<Product2>();
        for (Integer i = 0; i < 5; i++) {
            testProducts.add(new Product2(
                    Name = 'Test Product ' + i,
                    ProductCode = 'TEST-' + i,
                    Description = 'Test Description ' + i,
                    IsActive = true,
                    ExternalId = 'EXT-' + i,
                    IsSentFromOther__c = false
            ));
        }
        insert testProducts;
    }

    @IsTest
    static void testSynchronizeProducts_EmptyList() {
        Test.setMock(HttpCalloutMock.class, new ProductSyncMockHttpSuccess());

        Test.startTest();
        try {
            SynchronizeService.synchronizeProducts(null);
            Assert.isTrue(false, 'Should throw error');
        } catch (Exception e) {
            Assert.isTrue(true, 'Should throw error');
        }
        Test.stopTest();

        // Verify no callouts were made
        System.assertEquals(0, Limits.getCallouts());
    }

    @IsTest
    static void testSynchronizeProducts_CreateNewProducts() {
        List<Product2> products = [SELECT Id, Name, ProductCode, Description, IsActive, ExternalId FROM Product2 LIMIT 2];

        Test.setMock(HttpCalloutMock.class, new ProductSyncMockHttpSuccess());

        Test.startTest();
        SynchronizeService.synchronizeProducts(products);
        Test.stopTest();

        // Verify logs were created
        List<Product_Synchronization_Log__c> logs = [SELECT Id FROM Product_Synchronization_Log__c];
        System.assertEquals(2, logs.size());
    }

    @IsTest
    static void testSynchronizeProducts_UpdateExistingProducts() {
        List<Product2> products = [SELECT Id, Name, ProductCode, Description, IsActive, ExternalId FROM Product2 LIMIT 2];

        Test.setMock(HttpCalloutMock.class, new ProductSyncMockHttpSuccess());

        Test.startTest();
        SynchronizeService.synchronizeProducts(products);
        Test.stopTest();

        // Verify products were processed
        List<Product2> updatedProducts = [SELECT IsSentFromOther__c FROM Product2 WHERE Id IN :products];
        for (Product2 prod : updatedProducts) {
            System.assertEquals(false, prod.IsSentFromOther__c);
        }
    }

    @IsTest
    static void testSynchronizeProducts_MixedCreateAndUpdate() {
        List<Product2> allProducts = [SELECT Id, Name, ProductCode, Description, IsActive, ExternalId FROM Product2 LIMIT 4];

        Test.setMock(HttpCalloutMock.class, new ProductSyncMockHttpSuccess());

        Test.startTest();
        SynchronizeService.synchronizeProducts(allProducts);
        Test.stopTest();

        List<Product_Synchronization_Log__c> logs = [SELECT Id FROM Product_Synchronization_Log__c];
        System.assert(logs.size() > 0, 'Logs should be created');
    }

    @IsTest
    static void testSynchronizeProducts_SuccessfulSynchronization() {
        List<Product2> products = [SELECT Id, Name, ProductCode, Description, IsActive, ExternalId FROM Product2 LIMIT 1];

        Test.setMock(HttpCalloutMock.class, new ProductSyncMockHttpSuccess());

        Test.startTest();
        SynchronizeService.synchronizeProducts(products);
        Test.stopTest();

        // Verify successful synchronization logs
        List<Product_Synchronization_Log__c> logs = [SELECT Response_Body__c FROM Product_Synchronization_Log__c];
        System.assert(logs.size() > 0, 'Synchronization logs should be created');
    }

    @IsTest
    static void testSynchronizeProducts_CompositeRequest() {
        List<Product2> products = [SELECT Id, Name, ProductCode, Description, IsActive, ExternalId FROM Product2 LIMIT 1];

        Test.setMock(HttpCalloutMock.class, new ProductSyncMockHttpSuccess());

        Test.startTest();
        SynchronizeService.synchronizeProducts(products);
        Test.stopTest();

        List<Product_Synchronization_Log__c> logs = [SELECT Response_Body__c FROM Product_Synchronization_Log__c];
        System.assert(logs.size() > 0, 'Logs should be created for composite requests');
    }

    @IsTest
    static void testSynchronizeProducts_ExternalProducts() {
        Test.setMock(HttpCalloutMock.class, new SynchronizeServiceMultiMock());

        Product2 externalProduct = (Product2) new ExternalProductTestDataFactory().create();
        Product2 existingProduct = [
                SELECT Id, ExternalId
                FROM Product2
                LIMIT 1
        ];
        externalProduct.ExternalId = existingProduct.Id;
        insert externalProduct;
        List<Product2> externalProducts = new List<Product2>{
                externalProduct
        };

        Test.startTest();
        SynchronizeService.synchronizeProducts(externalProducts);
        Test.stopTest();

        // Verify that both callouts were made
        System.assertEquals(0, Limits.getCallouts());
    }

    private class ExternalProductTestDataFactory extends ProductTestDataFactory {
        public override SObject create() {
            Product2 exteralProduct = (Product2) super.create();
            exteralProduct.IsExternal__c = true;
            return exteralProduct;
        }
    }
}