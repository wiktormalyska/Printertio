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

        // Convert CompositeSubRequest objects to the format expected by Salesforce Composite API
        List<Map<String, Object>> formattedRequests = new List<Map<String, Object>>();
        Integer requestCounter = 0;

        for (CompositeSubRequest subReq : subRequests) {
            // Ensure reference ID is valid for Composite API (alphanumeric + underscore, starts with letter)
            String validReferenceId = 'ref_' + requestCounter;
            if (String.isNotBlank(subReq.referenceId)) {
                // Clean the reference ID by removing invalid characters and ensuring it starts with a letter
                validReferenceId = 'ref_' + subReq.referenceId.replaceAll('[^a-zA-Z0-9_]', '_');
            }

            Map<String, Object> formattedRequest = new Map<String, Object>{
                'method' => subReq.method,
                'url' => subReq.url,
                'referenceId' => validReferenceId
            };

            // Only add body for methods that support it (POST, PATCH, PUT)
            if (subReq.body != null && (subReq.method == 'POST' || subReq.method == 'PATCH' || subReq.method == 'PUT')) {
                formattedRequest.put('body', subReq.body);
            }

            formattedRequests.add(formattedRequest);
            requestCounter++;
        }

        Map<String, Object> compositeRequest = new Map<String, Object>{
                'allOrNone' => false,
                'compositeRequest' => formattedRequests
        };

        String jsonBody = JSON.serialize(compositeRequest);
        System.debug('Composite Request JSON: ' + jsonBody);

        HttpRequest req = new HttpRequest();
        req.setEndpoint(NAMED_CREDENTIAL + ConstUtil.ENDPOINT.COMPOSITE);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json;charset=UTF-8');
        req.setBody(jsonBody);

        Http http = new Http();
        try {
            HttpResponse res = http.send(req);

            System.debug('Response Status Code: ' + res.getStatusCode());
            System.debug('Response Body: ' + res.getBody());

            if (res.getStatusCode() != 200) {
                throw new CalloutException(System.Label.Error_in_composite_request + res.getStatusCode().toString() + ' ' + res.getStatus() + ' - Response: ' + res.getBody());
            }
        } catch (Exception e) {
            throw new CalloutException(System.Label.Error_in_composite_request + e.getMessage());
        }
    }
}