@IsTest
public with sharing class TestGenerateOrderPdfAction {
    @TestSetup
    static void setup() {
        Account acc = new Account(Name = 'Test Account');
        insert acc;

        Id standardPricebookId = Test.getStandardPricebookId();

        Pricebook2 customPricebook = new Pricebook2(Name = 'Custom Pricebook', IsActive = true);
        insert customPricebook;

        Product2 prod = new Product2(Name = 'Test Product', IsActive = true);
        insert prod;

        PricebookEntry pbeStd = new PricebookEntry(
                Pricebook2Id = standardPricebookId,
                Product2Id = prod.Id,
                UnitPrice = 100,
                IsActive = true
        );
        insert pbeStd;

        PricebookEntry pbeCustom = new PricebookEntry(
                Pricebook2Id = customPricebook.Id,
                Product2Id = prod.Id,
                UnitPrice = 120,
                IsActive = true
        );
        insert pbeCustom;

        Order testOrder = new Order(
                AccountId = acc.Id,
                EffectiveDate = Date.today(),
                Status = 'Draft',
                Pricebook2Id = customPricebook.Id
        );
        insert testOrder;

        OrderItem oi = new OrderItem(
                OrderId = testOrder.Id,
                PricebookEntryId = pbeCustom.Id,
                Quantity = 2,
                UnitPrice = 120
        );
        insert oi;
    }

    @IsTest
    static void testGeneratePdf_SingleSuccess() {
        Order testOrder = [SELECT Id, OrderNumber FROM Order LIMIT 1];
        List<Id> orderIds = new List<Id>{ testOrder.Id };

        GenerateOrderPdfAction.isTestRunning = true;

        Test.startTest();
        List<GenerateOrderPdfAction.FlowOutputs> results = GenerateOrderPdfAction.generatePdf(orderIds);
        Test.stopTest();

        System.assertEquals(1, results.size(), 'There should be one result.');
        System.assertEquals(true, results[0].isSuccess, 'The operation should be successful.');
        System.assertEquals(1, results[0].generatedCount, 'One file should have been generated.');
        System.assertEquals('', results[0].errorMessage, 'There should be no error message.');

        List<ContentVersion> createdFiles = [SELECT Title, PathOnClient, FirstPublishLocationId FROM ContentVersion WHERE FirstPublishLocationId = :testOrder.Id];
        System.assertEquals(1, createdFiles.size(), 'One file should be attached to the order.');
        System.assertEquals('Confirmation - ' + testOrder.OrderNumber, createdFiles[0].Title, 'The file title is incorrect.');

        List<Task> createdTasks = [SELECT Subject, WhatId FROM Task WHERE WhatId = :testOrder.Id];
        System.assertEquals(1, createdTasks.size(), 'One task should have been created in the activity history.');
        System.assertEquals('Invoice Generated: ' + createdFiles[0].Title, createdTasks[0].Subject, 'The task subject is incorrect.');
    }

    @IsTest
    static void testGeneratePdf_RevisionLogic() {
        Order testOrder = [SELECT Id, OrderNumber FROM Order LIMIT 1];
        List<Id> orderIds = new List<Id>{ testOrder.Id };

        GenerateOrderPdfAction.isTestRunning = true;

        GenerateOrderPdfAction.generatePdf(orderIds);

        Test.startTest();
        GenerateOrderPdfAction.generatePdf(orderIds);
        Test.stopTest();

        List<ContentVersion> createdFiles = [SELECT Title FROM ContentVersion WHERE FirstPublishLocationId = :testOrder.Id ORDER BY CreatedDate ASC];
        System.assertEquals(2, createdFiles.size(), 'Two files should be attached to the order.');

        String baseTitle = 'Confirmation - ' + testOrder.OrderNumber;
        System.assertEquals(baseTitle, createdFiles[0].Title, 'The first file title is incorrect.');
        System.assertEquals(baseTitle + ' - Rev 2', createdFiles[1].Title, 'The second file title should include the revision.');
    }

    @IsTest
    static void testGeneratePdf_BulkProcessing() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Pricebook2 pb = [SELECT Id FROM Pricebook2 WHERE IsStandard = FALSE LIMIT 1];

        Order testOrder2 = new Order(AccountId = acc.Id, EffectiveDate = Date.today(), Status = 'Draft', Pricebook2Id = pb.Id);
        insert testOrder2;

        Order order1 = [SELECT Id FROM Order WHERE Id != :testOrder2.Id LIMIT 1];

        List<Id> orderIds = new List<Id>{ order1.Id, testOrder2.Id };

        GenerateOrderPdfAction.isTestRunning = true;

        Test.startTest();
        List<GenerateOrderPdfAction.FlowOutputs> results = GenerateOrderPdfAction.generatePdf(orderIds);
        Test.stopTest();

        System.assertEquals(true, results[0].isSuccess, 'The bulk operation should be successful.');
        System.assertEquals(2, results[0].generatedCount, 'Two files should have been generated.');

        System.assertEquals(2, [SELECT COUNT() FROM ContentVersion WHERE FirstPublishLocationId IN :orderIds], 'Two ContentVersion files should have been created.');
        System.assertEquals(2, [SELECT COUNT() FROM Task WHERE WhatId IN :orderIds], 'Two tasks should have been created.');
    }

    @IsTest
    static void testCreateSignatureDocument() {
        Order testOrder = [SELECT Id FROM Order LIMIT 1];
        String signatureBase64 = 'dGVzdFNpZ25hdHVyZQ==';

        Test.startTest();
        Id versionId = GenerateOrderPdfAction.createSignatureDocument(testOrder.Id, signatureBase64);
        Test.stopTest();

        System.assertNotEquals(null, versionId, 'The file version ID should not be null.');

        ContentVersion signatureFile = [SELECT Title, FirstPublishLocationId FROM ContentVersion WHERE Id = :versionId];
        System.assertEquals('Customer_Signature_' + testOrder.Id, signatureFile.Title, 'The signature file title is incorrect.');
        System.assertEquals(testOrder.Id, signatureFile.FirstPublishLocationId, 'The file should be linked to the order.');
    }

    @IsTest
    static void testGeneratePdfWithSignatureAndReturnVersionId() {
        Order testOrder = [SELECT Id, OrderNumber FROM Order LIMIT 1];
        String signatureBase64 = 'dGVzdFNpZ25hdHVyZQ==';
        Id signatureVersionId = GenerateOrderPdfAction.createSignatureDocument(testOrder.Id, signatureBase64);

        GenerateOrderPdfAction.isTestRunning = true;

        Test.startTest();
        GenerateOrderPdfAction.PdfGenerationResult result = GenerateOrderPdfAction.generatePdfWithSignatureAndReturnVersionId(testOrder.Id, signatureVersionId);
        Test.stopTest();

        System.assertEquals(true, result.isSuccess, 'Generating PDF with signature should be successful.');
        System.assertNotEquals(null, result.latestPdfVersionId, 'The PDF version ID should not be null.');

        ContentVersion signedPdf = [SELECT Id, Title FROM ContentVersion WHERE Id = :result.latestPdfVersionId];
        System.assert(signedPdf.Title.startsWith('Signed_Invoice - ' + testOrder.OrderNumber), 'The signed PDF title is incorrect.');
    }

    @IsTest
    static void testGetLatestPdfVersionId() {
        Order testOrder = [SELECT Id FROM Order LIMIT 1];

        Id latestVersionId1 = GenerateOrderPdfAction.getLatestPdfVersionId(testOrder.Id);
        System.assertEquals(null, latestVersionId1, 'The result should be null when no files exist.');

        ContentVersion cv = new ContentVersion(
                Title = 'Test File',
                PathOnClient = 'test.pdf',
                VersionData = Blob.valueOf('test content'),
                FirstPublishLocationId = testOrder.Id
        );
        insert cv;

        Test.startTest();
        Id latestVersionId2 = GenerateOrderPdfAction.getLatestPdfVersionId(testOrder.Id);
        Test.stopTest();

        System.assertEquals(cv.Id, latestVersionId2, 'It should return the ID of the newly created file.');
    }
}