public with sharing class OrgConnectorMock implements HttpCalloutMock {
    private final Boolean isSuccess;

    public OrgConnectorMock(Boolean isSuccess) {
        this.isSuccess = isSuccess;
    }

    public HttpResponse respond(HttpRequest request) {
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');

        if (isSuccess) {
            String successBody = '{' +
                    '  "totalSize" : 2,' +
                    '  "done" : true,' +
                    '  "records" : [ {' +
                    '    "attributes" : { "type" : "Account" },' +
                    '    "Id" : "001xx000003DHPqAAO",' +
                    '    "Name" : "Test Account 1"' +
                    '  }, {' +
                    '    "attributes" : { "type" : "Account" },' +
                    '    "Id" : "001xx000003DHPqAAP",' +
                    '    "Name" : "Test Account 2"' +
                    '  } ]' +
                    '}';
            response.setBody(successBody);
            response.setStatusCode(200);
            response.setStatus('OK');
        } else {
            String errorBody = '[{' +
                    '  "message" : "The requested resource does not exist",' +
                    '  "errorCode" : "NOT_FOUND"' +
                    '}]';
            response.setBody(errorBody);
            response.setStatusCode(404);
            response.setStatus('Not Found');
        }
        return response;
    }
}