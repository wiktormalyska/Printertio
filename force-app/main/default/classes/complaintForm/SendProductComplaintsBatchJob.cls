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
            request.setEndpoint(ConstUtil.CONNECTED_APPS.PRODUCT_SYNC.NAMED_CREDENTIAL + ConstUtil.ENDPOINT.PLATFORM_EVENTS.EXTERNAL_COMPLAINT);
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/json;charset=UTF-8');

            Map<String, String> bodyMap = new Map<String, String>{
                    External_Complaint__e.Product_ID__c.toString() => prod.ExternalId,
                    External_Complaint__e.External_Complaint_Request_ID__c.toString() => randomUUID.toString()
            };
            request.setBody(JSON.serialize(bodyMap));

            try {
                HttpResponse response = http.send(request);
                if (response.getStatusCode() == 201) {
                } else {
                    throw new CalloutException(System.Label.Error_sending_complaint);
                }
            } catch (Exception e) {
                throw new CalloutException(System.Label.Error_sending_complaint);
            }
        }
    }

    public void finish(Database.BatchableContext bc) {
    }
}