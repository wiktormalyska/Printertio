@IsTest
public class ComplaintApprovalMockSuccess implements HttpCalloutMock {
    public HttpResponse respond(HttpRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setStatusCode(200);

        String endpoint = req.getEndpoint();

        if (endpoint.contains('OrderItem')) {
            // Order product query - return list of products
            res.setBody('{"records": [{"Product2Id": "prod123", "UnitPrice": 100.50}, {"Product2Id": "prod456", "UnitPrice": 200.75}]}');
        } else if (endpoint.contains('Case__c')) {
            // Complaint approval query for case - return single record with case ID
            res.setBody('{"records": [{"Case__c": "case123"}]}');
        } else if (endpoint.contains('Order__c')) {
            // Case query for order - return single record with order ID
            res.setBody('{"records": [{"Order__c": "order123"}]}');
        } else if (endpoint.contains('Product__c')) {
            // Complaint approval query for product - return single record with product ID
            res.setBody('{"records": [{"Product__c": "prod123"}]}');
        } else {
            // Default response
            res.setBody('{"records": []}');
        }

        return res;
    }
}