public with sharing class SynchronizeService {

    private static final String PRODUCT_ENDPOINT = ConstUtil.ENDPOINT.COMPOSITE;
    private static final String NAMED_CREDENTIAL = ConstUtil.CONNECTED_APPS.PRODUCT_SYNC.NAMED_CREDENTIAL;
    private static final String API_VERSION = 'v64.0';

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
                product.ExternalId = targetId;
                productsToUpdate.add(product);
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
        List<Id> sourceProductIds = new List<Id>();

        for (Product2 product : products) {
            recordsToProcess.add(new Map<String, Object>{
                    'attributes' => new Map<String, Object>{
                            'type' => 'Product2'
                    },
                    'Name' => product.Name,
                    'ProductCode' => product.ProductCode,
                    'Description' => product.Description,
                    'IsActive' => product.IsActive,
                    'ExternalId' => product.Id,
                    'IsSentFromOther__c' => true
            });
            sourceProductIds.add(product.Id);
        }

        performCompositeRequest('POST', recordsToProcess, sourceProductIds);
    }

    private static List<Product2> updateProducts(List<Product2> products) {
        List<Map<String, Object>> recordsToProcess = new List<Map<String, Object>>();
        List<Id> sourceProductIds = new List<Id>();

        for (Product2 product : products) {
            recordsToProcess.add(new Map<String, Object>{
                    'attributes' => new Map<String, Object>{
                            'type' => 'Product2'
                    },
                    'Id' => product.ExternalId,
                    'Name' => product.Name,
                    'ProductCode' => product.ProductCode,
                    'Description' => product.Description,
                    'IsActive' => product.IsActive
            });
            sourceProductIds.add(product.Id);
        }

        Map<Id, Boolean> results = performCompositeRequest('PATCH', recordsToProcess, sourceProductIds);
        List<Product2> successfulUpdates = new List<Product2>();
        for (Product2 p : products) {
            if (results.get(p.Id) == true) {
                successfulUpdates.add(p);
            }
        }
        return successfulUpdates;
    }

    private static Map<Id, Boolean> performCompositeRequest(String httpMethod, List<Map<String, Object>> records, List<Id> sourceProductIds) {
        HttpRequest request = new HttpRequest();
        request.setEndpoint(NAMED_CREDENTIAL + PRODUCT_ENDPOINT);
        request.setMethod(httpMethod);
        request.setHeader('Content-Type', 'application/json');
        request.setTimeout(120000);

        Map<String, Object> requestBody = new Map<String, Object>{
                'allOrNone' => false,
                'records' => records
        };
        String jsonBody = JSON.serialize(requestBody);
        request.setBody(jsonBody);

        Map<Id, Boolean> operationStatusById = new Map<Id, Boolean>();

        try {
            HttpResponse response = new Http().send(request);
            createLogWithItems(jsonBody, response.getBody(), response.getStatusCode(), sourceProductIds);

            if (response.getStatusCode() == 200) {
                List<Object> results = (List<Object>) JSON.deserializeUntyped(response.getBody());
                for (Integer i = 0; i < results.size(); i++) {
                    Map<String, Object> result = (Map<String, Object>) results[i];
                    Boolean success = (Boolean) result.get('success');
                    operationStatusById.put(sourceProductIds[i], success);
                }
            } else {
                for (Id productId : sourceProductIds) {
                    operationStatusById.put(productId, false);
                }
            }
        } catch (Exception e) {
            createErrorLog('Error making composite callout:' + e.getMessage(), jsonBody);
            for (Id productId : sourceProductIds) {
                operationStatusById.put(productId, false);
            }
        }
        return operationStatusById;
    }

    private static void createLogWithItems(String requestBody, String responseBody, Integer statusCode, List<Id> productIds) {
        ProductSynchronizationLogBuilder.LogStatus status = (statusCode == 200) ?
                ProductSynchronizationLogBuilder.LogStatus.SUCCESS :
                ProductSynchronizationLogBuilder.LogStatus.ERROR;

        Product_Synchronization_Log__c log = ProductSynchronizationLogBuilder.create()
                .withRequestBody(requestBody)
                .withResponseBody(responseBody)
                .withStatus(status)
                .build();
        insert log;

        List<Product_Synchronization_Log_Item__c> logItems = new List<Product_Synchronization_Log_Item__c>();
        for (Id prodId : productIds) {
            logItems.add(new Product_Synchronization_Log_Item__c(
                    Product__c = prodId,
                    Product_Synchronization_Log__c = log.Id
            ));
        }
        if (!logItems.isEmpty()) {
            insert logItems;
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
        List<Object> records = (List<Object>) responseMap.get('records');

        return records;
    }
}