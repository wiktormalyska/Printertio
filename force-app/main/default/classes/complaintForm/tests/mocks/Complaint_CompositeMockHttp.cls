@IsTest
public class Complaint_CompositeMockHttp implements HttpCalloutMock {
    public HttpResponse respond(HttpRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setStatusCode(200);
        res.setBody('{"compositeResponse": [{"httpStatusCode": 201, "referenceId": "NewAccount1"}]}');
        return res;
    }
}