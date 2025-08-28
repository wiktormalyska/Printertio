@IsTest
public class MockHttpExceptionGenerator implements HttpCalloutMock {
    public HttpResponse respond(HttpRequest req) {
        throw new CalloutException('Mock exception');
    }
}