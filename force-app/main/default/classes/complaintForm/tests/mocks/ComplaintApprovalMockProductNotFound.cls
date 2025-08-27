@IsTest
public class ComplaintApprovalMockProductNotFound implements HttpCalloutMock {
    public HttpResponse respond(HttpRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setStatusCode(200);
        
        String endpoint = req.getEndpoint();
        
        if (endpoint.contains('OrderItem')) {
            // Order product query - return products but with different product IDs that won't match
            res.setBody('{"records": [{"Product2Id": "different_prod_id", "UnitPrice": 100.50}]}');
        } else if (endpoint.contains('Case__c')) {
            // Complaint approval query for case - return single record with case ID
            res.setBody('{"records": [{"Case__c": "case123"}]}');
        } else if (endpoint.contains('Order__c')) {
            // Case query for order - return single record with order ID
            res.setBody('{"records": [{"Order__c": "order123"}]}');
        } else if (endpoint.contains('Product__c')) {
            // Complaint approval query for product - return a product ID that won't match the order products
            res.setBody('{"records": [{"Product__c": "nonexistent_prod_id"}]}');
        } else {
            // Default response
            res.setBody('{"records": []}');
        }
        
        return res;
    }
}