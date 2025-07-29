@isTest
global class MockHttpResponseCreateAccount500Error implements HttpCalloutMock {
    global HttpResponse respond(HttpRequest req) {
        System.assertEquals(true, req.getEndpoint().contains('callout:DamianOrg/services/data/v62.0/sobjects/Account/'));
        System.assertEquals('POST', req.getMethod());
        System.assertEquals('application/json', req.getHeader('Content-Type'));

        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setStatusCode(500);

        Map<String, Object> errorPayload = new Map<String, Object>();
        errorPayload.put('message', 'Internal Server Error');
        errorPayload.put('errorCode', 'INTERNAL_ERROR');

        response.setBody(JSON.serialize(errorPayload));

        return response;
    }
}