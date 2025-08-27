public class MockHttpResponseGenerator implements HttpCalloutMock {
    private Integer statusCode;
    private String status;

    public MockHttpResponseGenerator(Integer statusCode, String status) {
        this.statusCode = statusCode;
        this.status = status;
    }

    public HttpResponse respond(HttpRequest req) {
        HttpResponse res = new HttpResponse();
        res.setStatusCode(statusCode);
        res.setStatus(status);
        return res;
    }
}