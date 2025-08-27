@IsTest
public with sharing class Complaint_CompositeMockHttp implements HttpCalloutMock {
    public HttpResponse respond(HttpRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setStatusCode(200);

        String responseBody = '{"compositeResponse":[{"body":{"id":"001XX000003DHP0","success":true},"httpStatusCode":201,"referenceId":"NewAccount1"}]}';
        res.setBody(responseBody);

        return res;
    }
}