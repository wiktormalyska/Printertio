@isTest
public class SynchronizeServiceHttpMock implements HttpCalloutMock {

    private Integer statusCode;
    private String responseBody;
    private Boolean shouldThrowException;

    public SynchronizeServiceHttpMock(Integer statusCode, String responseBody) {
        this.statusCode = statusCode;
        this.responseBody = responseBody;
        this.shouldThrowException = false;
    }

    public SynchronizeServiceHttpMock(Boolean shouldThrowException) {
        this.shouldThrowException = shouldThrowException;
    }

    public HTTPResponse respond(HTTPRequest request) {
        if (shouldThrowException) {
            throw new CalloutException('Mock exception for testing');
        }

        HttpResponse response = new HttpResponse();
        response.setStatusCode(statusCode);
        response.setBody(responseBody);
        response.setHeader('Content-Type', 'application/json');
        return response;
    }

    // Helper methods to create common response scenarios
    public static SynchronizeServiceHttpMock createSuccessResponse(Integer recordCount) {
        List<Map<String, Object>> results = new List<Map<String, Object>>();
        for (Integer i = 0; i < recordCount; i++) {
            results.add(new Map<String, Object>{
                    'success' => true,
                    'id' => '001' + String.valueOf(i).leftPad(15, '0')
            });
        }
        return new SynchronizeServiceHttpMock(200, JSON.serialize(results));
    }

    public static SynchronizeServiceHttpMock createMixedResponse(Integer successCount, Integer failureCount) {
        List<Map<String, Object>> results = new List<Map<String, Object>>();
        for (Integer i = 0; i < successCount; i++) {
            results.add(new Map<String, Object>{
                    'success' => true,
                    'id' => '001' + String.valueOf(i).leftPad(15, '0')
            });
        }
        for (Integer i = 0; i < failureCount; i++) {
            results.add(new Map<String, Object>{
                    'success' => false,
                    'errors' => new List<Map<String, Object>>{
                            new Map<String, Object>{
                                    'message' => 'Test error message',
                                    'statusCode' => 'FIELD_CUSTOM_VALIDATION_EXCEPTION'
                            }
                    }
            });
        }
        return new SynchronizeServiceHttpMock(200, JSON.serialize(results));
    }

    public static SynchronizeServiceHttpMock createErrorResponse() {
        return new SynchronizeServiceHttpMock(400, '{"error":"Bad Request"}');
    }

    public static SynchronizeServiceHttpMock createExceptionResponse() {
        return new SynchronizeServiceHttpMock(true);
    }
}