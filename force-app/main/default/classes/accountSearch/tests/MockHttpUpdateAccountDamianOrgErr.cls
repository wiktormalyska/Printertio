@IsTest
global with sharing class MockHttpUpdateAccountDamianOrgErr implements HttpCalloutMock {
    global HttpResponse respond(HttpRequest request) {
        System.assertEquals(true, request.getEndpoint().contains('callout:DamianOrg/services/data/v62.0/sobjects/Account/'));
        System.assertEquals('PATCH', request.getMethod());

        HttpResponse response = new HttpResponse();
        response.setStatusCode(500);
        return response;
    }
}