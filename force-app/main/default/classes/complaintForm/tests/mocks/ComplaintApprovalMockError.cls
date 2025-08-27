@isTest
public class ComplaintApprovalMockError implements HttpCalloutMock {
    public HttpResponse respond(HttpRequest req) {
        HttpResponse res = new HttpResponse();
        res.setStatusCode(500);
        res.setStatus('Internal Server Error');
        res.setBody('{"error":"Internal server error"}');
        return res;
    }
}