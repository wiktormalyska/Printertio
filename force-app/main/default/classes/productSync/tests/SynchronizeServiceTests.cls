@IsTest
private class SynchronizeServiceTests {

    @TestSetup
    static void makeData() {
        // Create test products
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
        Test.startTest();
        SynchronizeService.synchronizeProducts(new List<Product2>());
        Test.stopTest();

        // Verify no callouts were made
        System.assertEquals(0, Limits.getCallouts());
    }

    @IsTest
    static void testSynchronizeProducts_CreateNewProducts() {
        List<Product2> products = [SELECT Id, Name, ProductCode, Description, IsActive, ExternalId FROM Product2 LIMIT 2];

        // Mock successful query response (no existing products)
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(
                new Map<String, Object>{
                        'getExistingProducts' => createEmptyQueryResponse(),
                        'createProducts' => createSuccessCompositeResponse(2)
                }
        ));

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

        // Mock response with existing products
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(
                new Map<String, Object>{
                        'getExistingProducts' => createQueryResponseWithExistingProducts(products),
                        'updateProducts' => createSuccessCompositeResponse(2)
                }
        ));

        Test.startTest();
        SynchronizeService.synchronizeProducts(products);
        Test.stopTest();

        // Verify products were marked as not sent
        List<Product2> updatedProducts = [SELECT IsSentFromOther__c FROM Product2 WHERE Id IN :products];
        for (Product2 prod : updatedProducts) {
            System.assertEquals(false, prod.IsSentFromOther__c);
        }
    }

    @IsTest
    static void testSynchronizeProducts_MixedCreateAndUpdate() {
        List<Product2> allProducts = [SELECT Id, Name, ProductCode, Description, IsActive, ExternalId FROM Product2 LIMIT 4];
        List<Product2> productsToUpdate = new List<Product2>{
                allProducts[0], allProducts[1]
        };

        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(
                new Map<String, Object>{
                        'getExistingProducts' => createQueryResponseWithExistingProducts(productsToUpdate),
                        'createProducts' => createSuccessCompositeResponse(2),
                        'updateProducts' => createSuccessCompositeResponse(2)
                }
        ));

        Test.startTest();
        SynchronizeService.synchronizeProducts(allProducts);
        Test.stopTest();

        List<Product_Synchronization_Log__c> logs = [SELECT Id FROM Product_Synchronization_Log__c];
        System.assertEquals(3, logs.size()); // One for create, one for update
    }

    @IsTest
    static void testSynchronizeProducts_GetExistingProductsError() {
        List<Product2> products = [SELECT Id, Name, ProductCode, Description, IsActive, ExternalId FROM Product2 LIMIT 1];

        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(
                new Map<String, Object>{
                        'getExistingProducts' => new HttpResponse[]{
                                createErrorResponse(500, 'Server Error')
                        }
                }
        ));

        Test.startTest();
        SynchronizeService.synchronizeProducts(products);
        Test.stopTest();

        // Verify error log was created
        List<Product_Synchronization_Log__c> errorLogs = [SELECT Response_Body__c FROM Product_Synchronization_Log__c];
        System.assertEquals(2, errorLogs.size());
        System.assert(errorLogs[0].Response_Body__c.contains('Błąd krytyczny'));
    }

    @IsTest
    static void testSynchronizeProducts_CompositeRequestException() {
        List<Product2> products = [SELECT Id, Name, ProductCode, Description, IsActive, ExternalId FROM Product2 LIMIT 1];

        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(
                new Map<String, Object>{
                        'getExistingProducts' => createEmptyQueryResponse(),
                        'createProducts' => new CalloutException('Network error')
                }
        ));

        Test.startTest();
        SynchronizeService.synchronizeProducts(products);
        Test.stopTest();

        List<Product_Synchronization_Log__c> errorLogs = [SELECT Response_Body__c FROM Product_Synchronization_Log__c];
        System.assertEquals(2, errorLogs.size());
    }

    // Helper methods for creating mock responses
    private static HttpResponse createEmptyQueryResponse() {
        HttpResponse response = new HttpResponse();
        response.setStatusCode(200);
        response.setBody('{"records": []}');
        return response;
    }

    private static HttpResponse createQueryResponseWithExistingProducts(List<Product2> products) {
        HttpResponse response = new HttpResponse();
        response.setStatusCode(200);

        List<Map<String, Object>> records = new List<Map<String, Object>>();
        for (Product2 prod : products) {
            records.add(new Map<String, Object>{
                    'Id' => 'target' + String.valueOf(prod.Id).substring(3),
                    'ExternalId' => prod.Id
            });
        }

        Map<String, Object> responseBody = new Map<String, Object>{
                'records' => records
        };
        response.setBody(JSON.serialize(responseBody));
        return response;
    }

    private static HttpResponse createSuccessCompositeResponse(Integer recordCount) {
        HttpResponse response = new HttpResponse();
        response.setStatusCode(200);

        List<Map<String, Object>> results = new List<Map<String, Object>>();
        for (Integer i = 0; i < recordCount; i++) {
            results.add(new Map<String, Object>{
                    'success' => true,
                    'id' => 'newId' + i
            });
        }
        response.setBody(JSON.serialize(results));
        return response;
    }

    private static HttpResponse createErrorResponse(Integer statusCode, String errorMessage) {
        HttpResponse response = new HttpResponse();
        response.setStatusCode(statusCode);
        response.setBody(errorMessage);
        return response;
    }

    // Mock HTTP callout class
    private class MockHttpResponseGenerator implements HttpCalloutMock {
        private Map<String, Object> responses;
        private Integer calloutCount = 0;

        public MockHttpResponseGenerator(Map<String, Object> responses) {
            this.responses = responses;
        }

        public HttpResponse respond(HttpRequest request) {
            calloutCount++;

            if (request.getEndpoint().contains('/query?q=')) {
                Object getExistingResponse = responses.get('getExistingProducts');
                if (getExistingResponse instanceof Exception) {
                    throw (Exception) getExistingResponse;
                }
                return (HttpResponse) getExistingResponse;
            } else if (request.getMethod() == 'POST') {
                Object createResponse = responses.get('createProducts');
                if (createResponse instanceof Exception) {
                    throw (Exception) createResponse;
                }
                return (HttpResponse) createResponse;
            } else if (request.getMethod() == 'PATCH') {
                Object updateResponse = responses.get('updateProducts');
                if (updateResponse instanceof Exception) {
                    throw (Exception) updateResponse;
                }
                return (HttpResponse) updateResponse;
            }

            return createErrorResponse(404, 'Not Found');
        }
    }
}