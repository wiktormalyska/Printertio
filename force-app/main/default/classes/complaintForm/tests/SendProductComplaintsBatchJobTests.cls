@IsTest
public with sharing class SendProductComplaintsBatchJobTests {

    @TestSetup
    static void makeData() {
        Product2 testProduct = new Product2(
                Name = 'Test Product',
                ExternalId = 'EXT123'
        );
        insert testProduct;
    }

    @IsTest
    static void testBatchJobCreation() {
        Map<String, String> testEvents = new Map<String, String>{'key1' => 'value1'};
        UUID testUUID = UUID.randomUUID();

        SendProductComplaintsBatchJob batchJob = new SendProductComplaintsBatchJob(testEvents, testUUID);

        System.assertNotEquals(null, batchJob);
    }

    @IsTest
    static void testStartMethod() {
        Product2 product = [SELECT Id FROM Product2 LIMIT 1];
        Map<String, String> testEvents = new Map<String, String>{product.Id => 'complaint123'};
        UUID testUUID = UUID.randomUUID();

        SendProductComplaintsBatchJob batchJob = new SendProductComplaintsBatchJob(testEvents, testUUID);

        Test.startTest();
        Iterable<SObject> result = batchJob.start(null);
        Test.stopTest();

        List<Product2> products = (List<Product2>) result;
        System.assertEquals(1, products.size());
        System.assertEquals(product.Id, products[0].Id);
    }

    @IsTest
    static void testExecuteMethodSuccess() {
        Product2 product = [SELECT Id, ExternalId FROM Product2 LIMIT 1];
        Map<String, String> testEvents = new Map<String, String>{product.Id => 'complaint123'};
        UUID testUUID = UUID.randomUUID();

        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(201, 'Created'));

        SendProductComplaintsBatchJob batchJob = new SendProductComplaintsBatchJob(testEvents, testUUID);
        List<Product2> scope = new List<Product2>{product};

        Test.startTest();
        batchJob.execute(null, scope);
        Test.stopTest();
    }

    @IsTest
    static void testExecuteMethodFailure() {
        Product2 product = [SELECT Id, ExternalId FROM Product2 LIMIT 1];
        Map<String, String> testEvents = new Map<String, String>{product.Id => 'complaint123'};
        UUID testUUID = UUID.randomUUID();

        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(400, 'Bad Request'));

        SendProductComplaintsBatchJob batchJob = new SendProductComplaintsBatchJob(testEvents, testUUID);
        List<Product2> scope = new List<Product2>{product};

        Test.startTest();
        try {
            batchJob.execute(null, scope);
            System.assert(false, 'Expected CalloutException');
        } catch (CalloutException e) {
            System.assert(true);
        }
        Test.stopTest();
    }

    @IsTest
    static void testExecuteMethodException() {
        Product2 product = [SELECT Id, ExternalId FROM Product2 LIMIT 1];
        Map<String, String> testEvents = new Map<String, String>{product.Id => 'complaint123'};
        UUID testUUID = UUID.randomUUID();

        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorWithExec());

        SendProductComplaintsBatchJob batchJob = new SendProductComplaintsBatchJob(testEvents, testUUID);
        List<Product2> scope = new List<Product2>{product};

        Test.startTest();
        try {
            batchJob.execute(null, scope);
            System.assert(false, 'Expected CalloutException');
        } catch (CalloutException e) {
            System.assert(true);
        }
        Test.stopTest();
    }

    @IsTest
    static void testFinishMethod() {
        Map<String, String> testEvents = new Map<String, String>{'key1' => 'value1'};
        UUID testUUID = UUID.randomUUID();

        SendProductComplaintsBatchJob batchJob = new SendProductComplaintsBatchJob(testEvents, testUUID);

        Test.startTest();
        batchJob.finish(null);
        Test.stopTest();
    }
}