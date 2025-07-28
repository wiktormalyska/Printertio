@isTest
global class MockHttpResponseCreateAccountInDamianOrg implements HttpCalloutMock {
    global HttpResponse respond(HttpRequest req) {
        System.assertEquals(true, req.getEndpoint().contains('callout:DamianOrg/services/data/v62.0/sobjects/Account/'));
        System.assertEquals('POST', req.getMethod());
        System.assertEquals('application/json', req.getHeader('Content-Type'));

        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setStatusCode(201);

        Map<String, Object> responsePayload = new Map<String, Object>();
        responsePayload.put('id', '0015Y00002pGk4jQAC');
        responsePayload.put('success', true);
        responsePayload.put('errors', new List<String>());

        response.setBody(JSON.serialize(responsePayload));

        return response;
    }
}