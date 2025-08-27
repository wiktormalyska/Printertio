public with sharing class SendProductComplaintsBatchJob implements Database.Batchable<SObject>, Database.AllowsCallouts, Database.Stateful {
    private final Map<String, String> externalComplaintEvents;
    private final UUID randomUUID;

    public SendProductComplaintsBatchJob(Map<String, String> externalComplaintEvents, UUID randomUUID) {
        this.externalComplaintEvents = externalComplaintEvents;
        this.randomUUID = randomUUID;
    }

    public Iterable<SObject> start(Database.BatchableContext bc) {
        Set<String> productIds = this.externalComplaintEvents.keySet();
        return [SELECT Id, ExternalId FROM Product2 WHERE Id IN :productIds];
    }
    public void execute(Database.BatchableContext bc, List<Product2> scope) {
        Http http = new Http();
        for (Product2 prod : scope) {
            String externalComplaintId = this.externalComplaintEvents.get(prod.Id);

            HttpRequest request = new HttpRequest();
            request.setEndpoint(ConstUtil.CONNECTED_APPS.PRODUCT_SYNC.NAMED_CREDENTIAL + ConstUtil.ENDPOINT.PLATFORM_EVENTS.EXTERNAL_COMPLAINT);
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/json;charset=UTF-8');

            Map<String, String> bodyMap = new Map<String, String>{
                    External_Complaint__e.Product_ID__c.toString() => prod.ExternalId,
                    External_Complaint__e.External_Complaint_Request_ID__c.toString() => randomUUID.toString(),
                    External_Complaint__e.External_Complaint_ID__c.toString() => externalComplaintId
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