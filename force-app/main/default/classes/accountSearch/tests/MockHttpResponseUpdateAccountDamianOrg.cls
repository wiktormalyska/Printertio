@IsTest
global with sharing class MockHttpResponseUpdateAccountDamianOrg implements HttpCalloutMock {
    global HttpResponse respond(HttpRequest request) {
        System.assertEquals(true, request.getEndpoint().contains('callout:DamianOrg/services/data/v62.0/sobjects/Account/'));
        System.assertEquals('PATCH', request.getMethod());

        HttpResponse response = new HttpResponse();
        response.setStatusCode(204);
        return response;
    }
}