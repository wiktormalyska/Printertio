public class ExternalComplaintApprovalStatusCallout implements Queueable, Database.AllowsCallouts {
    private String status;
    private String randomUUID;

    public ExternalComplaintApprovalStatusCallout(String status, String randomUUID) {
        this.status = status;
        this.randomUUID = randomUUID;
    }

    public static void sendComplaintApprovalStatusesAsync(String status, String randomUUID) {
        System.debug(status + ' : '+randomUUID);
        if (status != null && status != '') {
            System.enqueueJob(new ExternalComplaintApprovalStatusCallout(status, randomUUID));
        }
    }

    public void execute(QueueableContext context) {
        Http http = new Http();

        HttpRequest request = new HttpRequest();
        request.setEndpoint(ConstUtil.CONNECTED_APPS.PRODUCT_SYNC.NAMED_CREDENTIAL + '/services/data/v61.0/sobjects/External_Complaint_Approval_Status__e/');
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json;charset=UTF-8');

        Map<String, String> bodyMap = new Map<String, String>{
                'Status__c' => status,
                'External_Complaint_Request_ID__c' => randomUUID
        };
        request.setBody(JSON.serialize(bodyMap));
        System.debug(JSON.serialize(bodyMap));
        try {
            HttpResponse response = http.send(request);
            System.debug(response);
            if (response.getStatusCode() == 201) {
                System.debug('SUCCESS: Complaint approval status sent for UUID: ' + randomUUID);
            } else {
                System.debug('ERROR: Callout for UUID ' + randomUUID + ' failed. Status: ' + response.getStatus() + '. Body: ' + response.getBody());
            }
        } catch (Exception e) {
            System.debug('EXCEPTION: Callout for UUID ' + randomUUID + ' threw an exception. Message: ' + e.getMessage());
        }

    }
}