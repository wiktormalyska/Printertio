@IsTest
public class ComplaintApprovalMockNoRecords implements HttpCalloutMock {
    public HttpResponse respond(HttpRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setStatusCode(404);
        res.setBody('{"error": "No records found"}');
        return res;
    }
}