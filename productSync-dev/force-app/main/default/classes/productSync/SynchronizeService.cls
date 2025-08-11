public with sharing class SynchronizeService {

    public static Map<String, String> getExistingProductIds(List<Product2> products) {
        Http http = new Http();
        HttpRequest request = new HttpRequest();

        List<String> externalIds = new List<String>();
        for (Product2 product : products) {
            externalIds.add(product.Id);
        }

        String soqlQuery = 'SELECT Id, ExternalId FROM Product2 WHERE ExternalId IN (\'' +
                String.join(externalIds, '\',\'') + '\')';
        String encodedQuery = EncodingUtil.urlEncode(soqlQuery, 'UTF-8');

        String queryEndpoint = NAMED_CREDENTIAL + '/services/data/v64.0/query?q=' + encodedQuery;
        request.setEndpoint(queryEndpoint);
        request.setMethod('GET');
        request.setHeader('Content-Type', 'application/json');
        request.setTimeout(60000);

        Map<String, String> externalIdToTargetId = new Map<String, String>();

        try {
            HttpResponse response = http.send(request);
            if (response.getStatusCode() == 200) {
                Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                List<Object> records = (List<Object>) responseMap.get('records');

                for (Object recordObj : records) {
                    Map<String, Object> record = (Map<String, Object>) recordObj;
                    String targetId = (String) record.get('Id');
                    String externalId = (String) record.get('ExternalId');
                    externalIdToTargetId.put(externalId, targetId);
                }

                System.debug('Found ' + records.size() + ' existing products in target org');
            } else {
                System.debug('Error querying products: ' + response.getBody());
            }
        } catch (Exception e) {
            System.debug('Exception occurred while checking existing products: ' + e.getMessage());
        }

        return externalIdToTargetId;
    }

    private static String PRODUCT_ENDPOINT = ConstUtil.ENDPOINT.COMPOSITE;
    private static String NAMED_CREDENTIAL = ConstUtil.CONNECTED_APPS
            .PRODUCT_SYNC.NAMED_CREDENTIAL;

    public static void createProducts(List<Product2> products) {
        Http http = new Http();
        HttpRequest request = new HttpRequest();

        request.setEndpoint(NAMED_CREDENTIAL + PRODUCT_ENDPOINT);
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');

        List<Map<String, Object>> productRecords = new List<Map<String, Object>>();

        for (Product2 product : products) {

            Map<String, Object> productRecord = new Map<String, Object>();
            productRecord.put('attributes', new Map<String, Object>{
                    'type' => 'Product2'
            });

            productRecord.put('Name', product.Name);
            productRecord.put('ProductCode', product.ProductCode);
            productRecord.put('Description', product.Description);
            productRecord.put('IsActive', product.IsActive);
            productRecord.put('IsExternal__c', true);
            productRecord.put('ExternalId', product.Id);

            productRecords.add(productRecord);
        }

        Map<String, Object> requestBody = new Map<String, Object>{
                'allOrNone' => false,
                'records' => productRecords
        };

        String jsonBody = JSON.serialize(requestBody);
        request.setBody(jsonBody);
        request.setTimeout(60000);

        try {
            HttpResponse response = http.send(request);
            if (response.getStatusCode() == 200 || response.getStatusCode() == 201) {
                System.debug('Products successfully sent to target org');
                System.debug('Response: ' + response.getBody());
            } else {
                System.debug('Error sending products. Status: ' + response.getStatusCode());
                System.debug('Response: ' + response.getBody());
            }
        } catch (Exception e) {
            System.debug('Exception occurred: ' + e.getMessage());
        }
    }

    public static void updateProducts(List<Product2> products) {
        Http http = new Http();
        HttpRequest request = new HttpRequest();

        request.setEndpoint(NAMED_CREDENTIAL + PRODUCT_ENDPOINT);
        request.setMethod('PATCH');
        request.setHeader('Content-Type', 'application/json');

        List<Map<String, Object>> productRecords = new List<Map<String, Object>>();

        for (Product2 product : products) {
            Map<String, Object> productRecord = new Map<String, Object>();
            productRecord.put('attributes', new Map<String, Object>{
                    'type' => 'Product2'
            });

            productRecord.put('Id', product.ExternalId);
            productRecord.put('Name', product.Name);
            productRecord.put('ProductCode', product.ProductCode);
            productRecord.put('Description', product.Description);
            productRecord.put('IsActive', product.IsActive);
            productRecord.put('IsExternal__c', true);
            productRecord.put('Id', product.ExternalId);

            productRecords.add(productRecord);
        }

        Map<String, Object> requestBody = new Map<String, Object>{
                'allOrNone' => false,
                'records' => productRecords
        };

        String jsonBody = JSON.serialize(requestBody);
        request.setBody(jsonBody);
        request.setTimeout(60000);

        try {
            HttpResponse response = http.send(request);
            if (response.getStatusCode() == 200) {
                System.debug('Products successfully updated in target org');
                System.debug('Response: ' + response.getBody());
            } else {
                System.debug('Error updating products. Status: ' + response.getStatusCode());
                System.debug('Response: ' + response.getBody());
            }
        } catch (Exception e) {
            System.debug('Exception occurred: ' + e.getMessage());
        }
    }

    public static void synchronizeProducts(List<Product2> products) {
        Map<String, String> existingProducts = getExistingProductIds(products);
        List<Product2> productsToCreate = new List<Product2>();
        List<Product2> productsToUpdate = new List<Product2>();

        for (Product2 product : products) {
            if (existingProducts.containsKey(product.Id)) {
                product.ExternalId = existingProducts.get(product.Id);
                productsToUpdate.add(product);
            } else {
                productsToCreate.add(product);
            }
        }
        System.debug('Products to create: ' + productsToCreate.size());

        if (!productsToCreate.isEmpty()) {
            System.debug('Creating ' + productsToCreate.size() + ' new products');
            createProducts(productsToCreate);
        }

        if (!productsToUpdate.isEmpty()) {
            System.debug('Updating ' + productsToUpdate.size() + ' existing products');
            updateProducts(productsToUpdate);
        }
    }
}