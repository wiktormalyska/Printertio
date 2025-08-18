@isTest
public class SynchronizeServiceQueryHttpMock implements HttpCalloutMock {

    private Integer statusCode;
    private String responseBody;
    private Boolean shouldThrowException;

    public SynchronizeServiceQueryHttpMock(Integer statusCode, String responseBody) {
        this.statusCode = statusCode;
        this.responseBody = responseBody;
        this.shouldThrowException = false;
    }

    public SynchronizeServiceQueryHttpMock(Boolean shouldThrowException) {
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
    public static SynchronizeServiceQueryHttpMock createSuccessResponse(List<Map<String, Object>> products) {
        Map<String, Object> responseBody = new Map<String, Object>{
                'totalSize' => products.size(),
                'done' => true,
                'records' => products
        };
        return new SynchronizeServiceQueryHttpMock(200, JSON.serialize(responseBody));
    }

    public static SynchronizeServiceQueryHttpMock createEmptyResponse() {
        Map<String, Object> responseBody = new Map<String, Object>{
                'totalSize' => 0,
                'done' => true,
                'records' => new List<Object>()
        };
        return new SynchronizeServiceQueryHttpMock(200, JSON.serialize(responseBody));
    }

    public static SynchronizeServiceQueryHttpMock createProductResponse(String productId, String externalId) {
        List<Map<String, Object>> products = new List<Map<String, Object>>{
                new Map<String, Object>{
                        'Id' => productId,
                        'ExternalId' => externalId
                }
        };
        return createSuccessResponse(products);
    }

    public static SynchronizeServiceQueryHttpMock createMultipleProductsResponse() {
        List<Map<String, Object>> products = new List<Map<String, Object>>{
                new Map<String, Object>{
                        'Id' => '01t000000000001AAA',
                        'ExternalId' => '01t000000000002BBB'
                },
                new Map<String, Object>{
                        'Id' => '01t000000000003CCC',
                        'ExternalId' => '01t000000000004DDD'
                }
        };
        return createSuccessResponse(products);
    }

    public static SynchronizeServiceQueryHttpMock createErrorResponse() {
        Map<String, Object> errorResponse = new Map<String, Object>{
                'message' => 'INVALID_QUERY',
                'errorCode' => 'MALFORMED_QUERY'
        };
        return new SynchronizeServiceQueryHttpMock(400, JSON.serialize(new List<Object>{errorResponse}));
    }

    public static SynchronizeServiceQueryHttpMock createUnauthorizedResponse() {
        Map<String, Object> errorResponse = new Map<String, Object>{
                'message' => 'Session expired or invalid',
                'errorCode' => 'INVALID_SESSION_ID'
        };
        return new SynchronizeServiceQueryHttpMock(401, JSON.serialize(new List<Object>{errorResponse}));
    }

    public static SynchronizeServiceQueryHttpMock createExceptionResponse() {
        return new SynchronizeServiceQueryHttpMock(true);
    }
}