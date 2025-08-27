@IsTest
public with sharing class Complaint_CompositeMockHttpError implements HttpCalloutMock {
    public HttpResponse respond(HttpRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setStatusCode(400);
        res.setStatus('Bad Request');

        String errorBody = '{"message":"Bad Request","errorCode":"INVALID_INPUT"}';
        res.setBody(errorBody);

        return res;
    }
}