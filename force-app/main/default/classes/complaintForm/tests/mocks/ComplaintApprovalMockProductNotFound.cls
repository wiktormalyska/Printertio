@isTest
public class ComplaintApprovalMockProductNotFound implements HttpCalloutMock {
    public HttpResponse respond(HttpRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setStatusCode(200);

        String responseBody;
        if (req.getEndpoint().contains('Complaint_Approval_Request__c') && req.getEndpoint().contains('Case__c')) {
            responseBody = '{"records":[{"Id":"a001234567890ABC","Case__c":"5001234567890ABC"}]}';
        } else if (req.getEndpoint().contains('Case') && req.getEndpoint().contains('Order__c')) {
            responseBody = '{"records":[{"Id":"5001234567890ABC","Order__c":"8011234567890ABC"}]}';
        } else if (req.getEndpoint().contains('OrderItem')) {
            responseBody = '{"records":[{"Id":"80i1234567890ABC","Product2Id":"01tDIFFERENT123","UnitPrice":100.50}]}';
        } else if (req.getEndpoint().contains('Product__c')) {
            responseBody = '{"records":[{"Id":"a001234567890ABC","Product__c":"01t1234567890ABC"}]}';
        } else {
            responseBody = '{"records":[]}';
        }

        res.setBody(responseBody);
        return res;
    }
}