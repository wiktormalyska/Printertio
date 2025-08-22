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
        request.setEndpoint(ConstUtil.CONNECTED_APPS.PRODUCT_SYNC.NAMED_CREDENTIAL + ConstUtil.ENDPOINT.PLATFORM_EVENTS.EXTERNAL_COMPLAINT_APPROVAL_STATUS);
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json;charset=UTF-8');

        Map<String, String> bodyMap = new Map<String, String>{
                External_Complaint_Approval_Status__e.Status__c.toString() => status,
                External_Complaint_Approval_Status__e.External_Complaint_Request_ID__c.toString() => randomUUID
        };
        request.setBody(JSON.serialize(bodyMap));
        try {
            HttpResponse response = http.send(request);
            if (response.getStatusCode() == 201) {
            } else {
                throw new CalloutException(System.Label.Error_sending_complaint_approval_status);
            }
        } catch (Exception e) {
            throw new CalloutException(System.Label.Error_sending_complaint_approval_status);
        }

    }
}