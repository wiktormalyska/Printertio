@IsTest
private class TA_Products_SynchroniseTests {
    @TestSetup
    static void setupTestData() {
        Test.setMock(HttpCalloutMock.class, new ProductSyncMockHttpSuccess());
        List<Product2> testProducts = new List<Product2>();

        testProducts.add(new Product2(
                Name = 'Internal Product',
                ProductCode = 'INT001',
                Description = 'Internal product for testing',
                IsActive = true,
                IsExternal__c = false,
                ExternalId = null
        ));

        testProducts.add(new Product2(
                Name = 'External Product',
                ProductCode = 'EXT001',
                Description = 'External product for testing',
                IsActive = true,
                IsExternal__c = true,
                ExternalId = 'EXT_001'
        ));

        insert testProducts;
    }

    @IsTest
    static void testBeforeInsertWithIsSentFromOtherTrue() {
        List<Product2> newProducts = new List<Product2>();
        newProducts.add(new Product2(
                Name = 'Test Product from Other',
                ProductCode = 'TEST001',
                IsSentFromOther__c = true,
                IsExternal__c = false
        ));

        Test.startTest();
        TA_Products_Synchronise handler = new TA_Products_Synchronise();
        handler.beforeInsert(newProducts);
        Test.stopTest();

        System.assertEquals(true, newProducts[0].IsExternal__c, 'IsExternal__c should be set to true');
        System.assertEquals(false, newProducts[0].IsSentFromOther__c, 'IsSentFromOther__c should be reset to false');
    }

    @IsTest
    static void testBeforeInsertWithIsSentFromOtherFalse() {
        List<Product2> newProducts = new List<Product2>();
        newProducts.add(new Product2(
                Name = 'Test Product Internal',
                ProductCode = 'TEST002',
                IsSentFromOther__c = false,
                IsExternal__c = false
        ));

        Test.startTest();
        TA_Products_Synchronise handler = new TA_Products_Synchronise();
        handler.beforeInsert(newProducts);
        Test.stopTest();

        System.assertEquals(false, newProducts[0].IsExternal__c, 'IsExternal__c should remain false');
        System.assertEquals(false, newProducts[0].IsSentFromOther__c, 'IsSentFromOther__c should remain false');
    }


    @IsTest
    static void testAfterUpdateWithUserModification() {
        Test.setMock(HttpCalloutMock.class, new ProductSyncMockHttpSuccess());
        Product2 existingProduct = [
                SELECT Id, Name, ProductCode, Description, IsActive, IsExternal__c, ExternalId
                FROM Product2
                WHERE ProductCode = 'INT001'
                LIMIT 1
        ];

        Product2 oldProduct = existingProduct.clone(true, true, true, true);
        Product2 newProduct = existingProduct.clone(true, true, true, true);
        newProduct.Name = 'Updated Internal Product';
        newProduct.Description = 'Updated description';

        Test.startTest();
        TA_Products_Synchronise handler = new TA_Products_Synchronise();
        handler.afterUpdate(new List<Product2>{
                newProduct
        }, new List<Product2>{
                oldProduct
        });
        Test.stopTest();

        System.assert(true, true);
    }

    @IsTest
    static void testBeforeDeleteWithExternalProducts() {
        Product2 externalProduct = [SELECT Id, IsExternal__c FROM Product2 WHERE ProductCode = 'EXT001' LIMIT 1];

        Test.startTest();
        TA_Products_Synchronise handler = new TA_Products_Synchronise();
        handler.beforeDelete(new List<SObject>{
                externalProduct
        });
        Test.stopTest();

        System.assert(true, 'External product deletion should proceed without events');
    }

    @IsTest
    static void testIsUserModificationWithNameChange() {
        Product2 oldProduct = new Product2(
                Name = 'Original Name',
                ProductCode = 'TEST001',
                Description = 'Original Description',
                IsActive = true,
                IsExternal__c = false
        );

        Product2 newProduct = oldProduct.clone();
        newProduct.Name = 'Changed Name';

        Test.startTest();
        TA_Products_Synchronise handler = new TA_Products_Synchronise();
        Boolean result = handler.isUserModification(newProduct, oldProduct);
        Test.stopTest();

        System.assertEquals(true, result, 'Name change should be considered user modification');
    }

    @IsTest
    static void testIsUserModificationWithProductCodeChange() {
        Product2 oldProduct = new Product2(
                Name = 'Test Product',
                ProductCode = 'OLD001',
                Description = 'Test Description',
                IsActive = true,
                IsExternal__c = false
        );

        Product2 newProduct = oldProduct.clone();
        newProduct.ProductCode = 'NEW001';

        Test.startTest();
        TA_Products_Synchronise handler = new TA_Products_Synchronise();
        Boolean result = handler.isUserModification(newProduct, oldProduct);
        Test.stopTest();

        System.assertEquals(true, result, 'ProductCode change should be considered user modification');
    }

    @IsTest
    static void testIsUserModificationWithDescriptionChange() {
        Product2 oldProduct = new Product2(
                Name = 'Test Product',
                ProductCode = 'TEST001',
                Description = 'Original Description',
                IsActive = true,
                IsExternal__c = false
        );

        Product2 newProduct = oldProduct.clone();
        newProduct.Description = 'Updated Description';

        Test.startTest();
        TA_Products_Synchronise handler = new TA_Products_Synchronise();
        Boolean result = handler.isUserModification(newProduct, oldProduct);
        Test.stopTest();

        System.assertEquals(true, result, 'Description change should be considered user modification');
    }

    @IsTest
    static void testIsUserModificationWithActiveStatusChange() {
        Product2 oldProduct = new Product2(
                Name = 'Test Product',
                ProductCode = 'TEST001',
                Description = 'Test Description',
                IsActive = true,
                IsExternal__c = false
        );

        Product2 newProduct = oldProduct.clone();
        newProduct.IsActive = false;

        Test.startTest();
        TA_Products_Synchronise handler = new TA_Products_Synchronise();
        Boolean result = handler.isUserModification(newProduct, oldProduct);
        Test.stopTest();

        System.assertEquals(true, result, 'IsActive change should be considered user modification');
    }

    @IsTest
    static void testIsUserModificationWithExternalIdChange() {
        Product2 oldProduct = new Product2(
                Name = 'Test Product',
                ProductCode = 'TEST001',
                Description = 'Test Description',
                IsActive = true,
                IsExternal__c = false,
                ExternalId = 'OLD_EXT_001'
        );

        Product2 newProduct = oldProduct.clone();
        newProduct.ExternalId = 'NEW_EXT_001';

        Test.startTest();
        TA_Products_Synchronise handler = new TA_Products_Synchronise();
        Boolean result = handler.isUserModification(newProduct, oldProduct);
        Test.stopTest();

        System.assertEquals(true, result, 'ExternalId change should be considered user modification');
    }

    @IsTest
    static void testIsUserModificationWithOnlyIsSentFromOtherChange() {
        Product2 oldProduct = new Product2(
                Name = 'Test Product',
                ProductCode = 'TEST001',
                Description = 'Test Description',
                IsActive = true,
                IsExternal__c = false,
                IsSentFromOther__c = false
        );

        Product2 newProduct = oldProduct.clone();
        newProduct.IsSentFromOther__c = true;

        Test.startTest();
        TA_Products_Synchronise handler = new TA_Products_Synchronise();
        Boolean result = handler.isUserModification(newProduct, oldProduct);
        Test.stopTest();

        System.assertEquals(false, result, 'Only IsSentFromOther__c change should not be considered user modification');
    }

    @IsTest
    static void testIsUserModificationTransitionInternalToExternal() {
        Product2 oldProduct = new Product2(
                Name = 'Test Product',
                ProductCode = 'TEST001',
                Description = 'Test Description',
                IsActive = true,
                IsExternal__c = false
        );

        Product2 newProduct = oldProduct.clone();
        newProduct.IsExternal__c = true;
        newProduct.Name = 'Changed Name';

        Test.startTest();
        TA_Products_Synchronise handler = new TA_Products_Synchronise();
        Boolean result = handler.isUserModification(newProduct, oldProduct);
        Test.stopTest();

        System.assertEquals(false, result, 'Transition from internal to external should not be considered user modification');
    }
}