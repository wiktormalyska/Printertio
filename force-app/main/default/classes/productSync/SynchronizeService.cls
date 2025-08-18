public with sharing class SynchronizeService {

    private static final String PRODUCT_ENDPOINT = ConstUtil.ENDPOINT.COMPOSITE;
    private static final String NAMED_CREDENTIAL = ConstUtil.CONNECTED_APPS.PRODUCT_SYNC.NAMED_CREDENTIAL;
    private static final String API_VERSION = 'v64.0';

    public class CompositeResult {
        public Boolean isSuccess { get; set; }
        public String errorMessage { get; set; }

        public CompositeResult(Boolean isSuccess, String errorMessage) {
            this.isSuccess = isSuccess;
            this.errorMessage = errorMessage;
        }
    }

    public static void synchronizeProducts(List<Product2> products) {
        if (products.isEmpty()) {
            return;
        }

        Map<String, String> existingProductsMap;
        try {
            existingProductsMap = getExistingProductIds(products);
        } catch (Exception e) {
            createErrorLog('Error verifying external org products: ' + e.getMessage(), JSON.serialize(products));
            return;
        }

        List<Product2> productsToCreate = new List<Product2>();
        List<Product2> productsToUpdate = new List<Product2>();

        for (Product2 product : products) {
            String targetId = existingProductsMap.get(product.Id);
            if (String.isBlank(targetId) && String.isNotBlank(product.ExternalId)) {
                targetId = existingProductsMap.get(product.ExternalId);
            }

            if (String.isNotBlank(targetId)) {
                Product2 productClone = product.clone(true, true);
                productClone.ExternalId = targetId; // Modyfikujemy klona, a nie oryginał
                productsToUpdate.add(productClone);
            } else {
                productsToCreate.add(product);
            }
        }

        List<Product2> successfulUpdates = new List<Product2>();

        if (!productsToCreate.isEmpty()) {
            createProducts(productsToCreate);
        }

        if (!productsToUpdate.isEmpty()) {
            successfulUpdates = updateProducts(productsToUpdate);
        }

        if (!successfulUpdates.isEmpty()) {
            try {
                List<Product2> localProductsToUpdate = new List<Product2>();
                for (Product2 prod : successfulUpdates) {
                    localProductsToUpdate.add(new Product2(
                            Id = prod.Id,
                            IsSentFromOther__c = false
                    ));
                }
                update localProductsToUpdate;
            } catch (Exception e) {
                createErrorLog('Error when updating internal org flags: ' + e.getMessage(), JSON.serialize(successfulUpdates));
            }
        }
    }

    private static Map<String, String> getExistingProductIds(List<Product2> products) {
        Set<String> idsToQuery = getIdToQueryFromProductsExternalId(products);
        if (idsToQuery.isEmpty()) {
            return new Map<String, String>();
        }

        String soqlQuery = createSoqlQueryReceivingProductsByExternalId(idsToQuery);

        Map<String, String> idMapping = new Map<String, String>();
        List<Object> records = getProductsFromExternalOrg(soqlQuery);

        for (Object recordObj : records) {
            Map<String, Object> record = (Map<String, Object>) recordObj;
            String targetId = (String) record.get('Id');
            String externalId = (String) record.get('ExternalId');

            if (String.isNotBlank(externalId)) {
                idMapping.put(externalId, targetId);
            }
            idMapping.put(targetId, targetId);
        }
        return idMapping;
    }

    private static void createProducts(List<Product2> products) {
        List<Map<String, Object>> recordsToProcess = new List<Map<String, Object>>();
        Map<Integer, Id> indexToProductIdMap = new Map<Integer, Id>();

        for (Integer i = 0; i < products.size(); i++) {
            Product2 product = products[i];

            // FIX: Create a new, writable map from the read-only one
            Map<String, Object> productMap = new Map<String, Object>(product.getPopulatedFieldsAsMap());

            // Now you can safely modify the new map
            productMap.put('ExternalId', product.Id);
            productMap.put('IsSentFromOther__c', true);
            productMap.remove('Id');

            Map<String, Object> recordData = new Map<String, Object>{
                    'attributes' => new Map<String, Object>{'type' => 'Product2'}
            };
            recordData.putAll(productMap);
            recordsToProcess.add(recordData);
            indexToProductIdMap.put(i, product.Id);
        }

        performCompositeRequest('POST', recordsToProcess, indexToProductIdMap);
    }


    private static List<Product2> updateProducts(List<Product2> products) {
        List<Map<String, Object>> recordsToProcess = new List<Map<String, Object>>();
        Map<Integer, Id> indexToProductIdMap = new Map<Integer, Id>();

        for (Integer i = 0; i < products.size(); i++) {
            Product2 product = products[i];
            Map<String, Object> productMap = product.getPopulatedFieldsAsMap();
            if (productMap.containsKey('ExternalId')) {
                productMap.put('Id', productMap.get('ExternalId'));
                productMap.remove('ExternalId');
            }

            Map<String, Object> recordToProcess = new Map<String, Object>{
                    'attributes' => new Map<String, Object>{'type' => 'Product2'}
            };
            recordToProcess.putAll(productMap);
            recordsToProcess.add(recordToProcess);
            indexToProductIdMap.put(i, product.Id);
        }

        Map<Id, CompositeResult> results = performCompositeRequest('PATCH', recordsToProcess, indexToProductIdMap);

        List<Product2> successfulUpdates = new List<Product2>();
        for (Product2 p : products) {
            if (results.containsKey(p.Id) && results.get(p.Id).isSuccess) {
                successfulUpdates.add(p);
            }
        }
        return successfulUpdates;
    }

    private static Map<Id, CompositeResult> performCompositeRequest(String httpMethod, List<Map<String, Object>> records, Map<Integer, Id> indexToProductIdMap) {
        HttpRequest request = new HttpRequest();
        request.setEndpoint(NAMED_CREDENTIAL + PRODUCT_ENDPOINT);
        request.setMethod(httpMethod);
        request.setHeader('Content-Type', 'application/json');
        request.setTimeout(120000);

        Map<String, Object> requestBodyMap = new Map<String, Object>{
                'allOrNone' => false,
                'records' => records
        };
        String jsonBody = JSON.serialize(requestBodyMap);
        request.setBody(jsonBody);

        Map<Id, CompositeResult> resultsById = new Map<Id, CompositeResult>();
        List<Id> sourceProductIds = new List<Id>(indexToProductIdMap.values());

        try {
            HttpResponse response = new Http().send(request);

            // Logujemy wyniki za pomocą nowej, uproszczonej metody
            logResults(jsonBody, response.getBody(), response.getStatusCode(), indexToProductIdMap);

            if (response.getStatusCode() == 200 || response.getStatusCode() == 201) {
                List<Object> results = (List<Object>) JSON.deserializeUntyped(response.getBody());
                for (Integer i = 0; i < results.size(); i++) {
                    Map<String, Object> result = (Map<String, Object>) results[i];
                    Boolean success = (Boolean) result.get('success');
                    Id sourceProductId = indexToProductIdMap.get(i);
                    String errorMessage = '';

                    if (!success) {
                        List<Object> errors = (List<Object>) result.get('errors');
                        if (errors != null && !errors.isEmpty()) {
                            Map<String, Object> firstError = (Map<String, Object>) errors[0];
                            errorMessage = (String) firstError.get('message');
                        }
                    }
                    resultsById.put(sourceProductId, new CompositeResult(success, errorMessage));
                }
            } else {
                String errorDetails = 'Callout failed with status code: ' + response.getStatusCode() + ' and body: ' + response.getBody();
                for (Id productId : sourceProductIds) {
                    resultsById.put(productId, new CompositeResult(false, errorDetails));
                }
            }
        } catch (Exception e) {
            for (Id productId : sourceProductIds) {
                resultsById.put(productId, new CompositeResult(false, 'Exception during callout: ' + e.getMessage()));
            }
            logResults(jsonBody, 'Exception: ' + e.getMessage(), 500, indexToProductIdMap);
        }
        return resultsById;
    }

    private static void logResults(String requestBody, String responseBody, Integer statusCode, Map<Integer, Id> indexToProductIdMap) {
        List<Product_Synchronization_Log__c> logsToInsert = new List<Product_Synchronization_Log__c>();

        Map<String, Object> parsedRequest = (Map<String, Object>) JSON.deserializeUntyped(requestBody);
        List<Object> requestRecords = (List<Object>) parsedRequest.get('records');

        List<Object> responseResults = new List<Object>();
        // Sprawdzamy, czy odpowiedź jest w poprawnym formacie JSON i czy da się ją zdeserializować
        if ((statusCode == 200 || statusCode == 201) && String.isNotBlank(responseBody) && responseBody.startsWith('[')) {
            try {
                responseResults = (List<Object>) JSON.deserializeUntyped(responseBody);
            } catch (Exception e) {
                // Jeśli deserializacja się nie powiedzie, traktujemy całą odpowiedź jako tekst błędu
                responseResults = new List<Object>();
            }
        }

        for (Integer i = 0; i < requestRecords.size(); i++) {
            Id productId = indexToProductIdMap.get(i);
            if (productId == null) continue;

            String singleRequestPayload = JSON.serialize(requestRecords[i]);
            String singleResponsePayload = '';
            String statusValue = 'ERROR';

            if (i < responseResults.size()) {
                Map<String, Object> result = (Map<String, Object>) responseResults[i];
                singleResponsePayload = JSON.serialize(result);
                if (result.containsKey('success') && result.get('success') instanceOf Boolean && (Boolean)result.get('success')) {
                    statusValue = 'SUCCESS';
                }
            } else {
                singleResponsePayload = 'Callout failed with status code: ' + statusCode + '. Full response: ' + responseBody;
            }

            logsToInsert.add(new Product_Synchronization_Log__c(
                    Product__c = productId,
                    Request_Body__c = singleRequestPayload,
                    Response_Body__c = singleResponsePayload,
                    Status__c = statusValue
            ));
        }

        if (!logsToInsert.isEmpty()) {
            insert logsToInsert;
        }
    }

    private static void createErrorLog(String errorMessage, String requestPayload) {
        Product_Synchronization_Log__c log = ProductSynchronizationLogBuilder.create()
                .withRequestBody(requestPayload)
                .withResponseBody('Critical error: ' + errorMessage)
                .withStatus(ProductSynchronizationLogBuilder.LogStatus.ERROR)
                .build();
        insert log;
    }

    private static Set<String> getIdToQueryFromProductsExternalId(List<Product2> products) {
        Set<String> idsToQuery = new Set<String>();
        for (Product2 product : products) {
            idsToQuery.add(product.Id);
            if (String.isNotBlank(product.ExternalId)) {
                idsToQuery.add(product.ExternalId);
            }
        }
        return idsToQuery;
    }

    private static String createSoqlQueryReceivingProductsByExternalId(Set<String> idsToQuery){
        return 'SELECT Id, ExternalId FROM Product2 WHERE ExternalId IN (\'' +
                String.join(new List<String>(idsToQuery), '\',\'') + '\') OR Id IN (\'' +
                String.join(new List<String>(idsToQuery), '\',\'') + '\')';
    }

    private static List<Object> getProductsFromExternalOrg(String soqlQuery){
        HttpRequest request = new HttpRequest();
        request.setEndpoint(NAMED_CREDENTIAL + '/services/data/' + API_VERSION + '/query?q=' + EncodingUtil.urlEncode(soqlQuery, 'UTF-8'));
        request.setMethod('GET');
        request.setHeader('Content-Type', 'application/json');
        request.setTimeout(60000);

        HttpResponse response = new Http().send(request);

        if (response.getStatusCode() != 200) {
            throw new CalloutException('Error receiving products from external Org');
        }

        Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
        return (List<Object>) responseMap.get('records');
    }
}