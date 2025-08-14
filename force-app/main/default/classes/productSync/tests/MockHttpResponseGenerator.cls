public class MockHttpResponseGenerator implements HttpCalloutMock {
    public HttpResponse respond(HttpRequest request) {
        HttpResponse response = new HttpResponse();
        response.setStatusCode(200);

        if (request.getEndpoint().contains('/query?q=')) {
            // Mock query response
            response.setBody('{"records": []}');
        } else if (request.getMethod() == 'POST' || request.getMethod() == 'PATCH') {
            // Mock composite API response
            response.setBody('[{"success": true, "id": "testId123"}]');
        }

        return response;
    }
}