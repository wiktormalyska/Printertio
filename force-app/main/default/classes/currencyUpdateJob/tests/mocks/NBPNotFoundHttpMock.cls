@IsTest
public class NBPNotFoundHttpMock implements HttpCalloutMock {
    public static Double generatedRate { get; private set; }

    public HttpResponse respond(HttpRequest request) {
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setStatusCode(404);
        return response;
    }
}