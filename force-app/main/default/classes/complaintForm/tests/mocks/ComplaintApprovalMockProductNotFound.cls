@IsTest
public class ComplaintApprovalMockProductNotFound implements HttpCalloutMock {
    public HttpResponse respond(HttpRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setStatusCode(200);
        
        String endpoint = req.getEndpoint();
        
        if (endpoint.contains('OrderItem')) {
            res.setBody('{"records": [{"Product2Id": "different_prod_id", "UnitPrice": 100.50}]}');
        } else if (endpoint.contains('Case__c')) {
            res.setBody('{"records": [{"Case__c": "case123"}]}');
        } else if (endpoint.contains('Order__c')) {
            res.setBody('{"records": [{"Order__c": "order123"}]}');
        } else if (endpoint.contains('Product__c')) {
            res.setBody('{"records": [{"Product__c": "nonexistent_prod_id"}]}');
        } else {
            res.setBody('{"records": []}');
        }
        
        return res;
    }
}