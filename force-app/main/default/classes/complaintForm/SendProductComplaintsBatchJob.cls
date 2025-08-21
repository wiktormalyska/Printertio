public with sharing class SendProductComplaintsBatchJob implements Database.Batchable<SObject>, Database.AllowsCallouts, Database.Stateful {
    private final List<Product2> productsToProcess;
    private final UUID randomUUID;

    public SendProductComplaintsBatchJob(List<Product2> products, UUID randomUUID) {
        this.productsToProcess = products;
        this.randomUUID = randomUUID;
    }

    public Iterable<SObject> start(Database.BatchableContext bc) {
        return this.productsToProcess;
    }
    public void execute(Database.BatchableContext bc, List<Product2> scope) {
        Http http = new Http();

        for (Product2 prod : scope) {
            HttpRequest request = new HttpRequest();
            request.setEndpoint(ConstUtil.CONNECTED_APPS.PRODUCT_SYNC.NAMED_CREDENTIAL + '/services/data/v61.0/sobjects/External_Complaint__e/');
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/json;charset=UTF-8');

            Map<String, String> bodyMap = new Map<String, String>{
                    'Product_ID__c' => prod.ExternalId,
                    'External_Complaint_Request_ID__c' => randomUUID.toString()
            };
            request.setBody(JSON.serialize(bodyMap));

            try {
                HttpResponse response = http.send(request);
                if (response.getStatusCode() == 201) {
                    System.debug('SUCCESS: Complaint sent for Product ID: ' + prod.Id);
                } else {
                    System.debug('ERROR: Callout for Product ID ' + prod.Id + ' failed. Status: ' + response.getStatus() + '. Body: ' + response.getBody());
                }
            } catch (Exception e) {
                System.debug('EXCEPTION: Callout for Product ID ' + prod.Id + ' threw an exception. Message: ' + e.getMessage());
            }
        }
    }

    public void finish(Database.BatchableContext bc) {
        System.debug('SendProductComplaintsBatch has finished processing a specific list of products.');
    }
}