@IsTest
public class MockHttpResponseGeneratorWithExec implements HttpCalloutMock {
    public HttpResponse respond(HttpRequest req) {
        throw new System.CalloutException('Mock exception');
    }
}