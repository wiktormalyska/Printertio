@IsTest
public class Complaint_CompositeMockHttpError implements HttpCalloutMock {
    public HttpResponse respond(HttpRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setStatusCode(400);
        res.setBody('{"error": "Bad Request"}');
        return res;
    }
}