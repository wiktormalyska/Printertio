@IsTest
public class ComplaintApprovalMockError implements HttpCalloutMock {
    public HttpResponse respond(HttpRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setStatusCode(500);
        res.setBody('{"error": "Callout failed"}');
        return res;
    }
}