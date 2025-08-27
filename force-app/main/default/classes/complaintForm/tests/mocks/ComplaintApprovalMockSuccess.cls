@isTest
public class ComplaintApprovalMockSuccess implements HttpCalloutMock {
    private Integer callCount = 0;

    public HttpResponse respond(HttpRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setStatusCode(200);

        String responseBody;
        callCount++;

        if (req.getEndpoint().contains('Complaint_Approval_Request__c') && req.getEndpoint().contains('Case__c')) {
            // First call - complaint approval query
            responseBody = '{"records":[{"Id":"a001234567890ABC","Case__c":"5001234567890ABC"}]}';
        } else if (req.getEndpoint().contains('Case') && req.getEndpoint().contains('Order__c')) {
            // Second call - case query
            responseBody = '{"records":[{"Id":"5001234567890ABC","Order__c":"8011234567890ABC"}]}';
        } else if (req.getEndpoint().contains('OrderItem')) {
            // Third call - order items query
            responseBody = '{"records":[{"Id":"80i1234567890ABC","Product2Id":"01t1234567890ABC","UnitPrice":100.50}]}';
        } else if (req.getEndpoint().contains('Product__c')) {
            // Fourth call - product query
            responseBody = '{"records":[{"Id":"a001234567890ABC","Product__c":"01t1234567890ABC"}]}';
        } else {
            responseBody = '{"records":[]}';
        }

        res.setBody(responseBody);
        return res;
    }
}