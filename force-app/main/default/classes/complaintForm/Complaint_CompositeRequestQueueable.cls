public with sharing class Complaint_CompositeRequestQueueable implements Queueable, Database.AllowsCallouts {
    private final List<CompositeSubRequest> subRequests;
    private final String apiVersion = 'v64.0';
    private static final String NAMED_CREDENTIAL = ConstUtil.CONNECTED_APPS.PRODUCT_SYNC.NAMED_CREDENTIAL;


    public class CompositeSubRequest {
        public String method;
        public String url;
        public String referenceId;
        public Map<String, Object> body;

        public CompositeSubRequest(String method, String url, String referenceId, Map<String, Object> body) {
            this.method = method;
            this.url = url;
            this.referenceId = referenceId;
            this.body = body;
        }
    }

    public Complaint_CompositeRequestQueueable(List<CompositeSubRequest> requests) {
        this.subRequests = requests;
    }

    public void execute(QueueableContext context) {
        if (subRequests == null || subRequests.isEmpty()) {
            return;
        }

        Map<String, Object> compositeRequest = new Map<String, Object>{
                'allOrNone' => false,
                'compositeRequest' => this.subRequests
        };

        String jsonBody = JSON.serialize(compositeRequest);
        HttpRequest req = new HttpRequest();
        req.setEndpoint(NAMED_CREDENTIAL + ConstUtil.ENDPOINT.COMPOSITE);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json;charset=UTF-8');
        req.setBody(jsonBody);

        Http http = new Http();
        try {
            HttpResponse res = http.send(req);

            if (res.getStatusCode() != 200) {
                throw new CalloutException(System.Label.Error_in_composite_request + res.getStatusCode().toString() + ' ' + res.getStatus());
            }
        } catch (Exception e) {
            throw new CalloutException(System.Label.Error_in_composite_request + e.getMessage());
        }
    }
}