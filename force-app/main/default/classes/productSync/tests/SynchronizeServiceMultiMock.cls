@isTest
public class SynchronizeServiceMultiMock implements HttpCalloutMock {

    private Integer callCount = 0;

    public HTTPResponse respond(HTTPRequest request) {
        callCount++;

        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');

        // First call is the query to getProductsFromExternalOrg
        if (callCount == 1 && request.getMethod() == 'GET') {
            Map<String, Object> queryResponse = new Map<String, Object>{
                    'totalSize' => 1,
                    'done' => true,
                    'records' => new List<Map<String, Object>>{
                            new Map<String, Object>{
                                    'Id' => '01t000000000001AAA',
                                    'ExternalId' => '01t000000000002BBB'
                            }
                    }
            };
            response.setStatusCode(200);
            response.setBody(JSON.serialize(queryResponse));
        }
        // Second call is the composite request for update
        else if (callCount == 2 && request.getMethod() == 'PATCH') {
            List<Map<String, Object>> compositeResponse = new List<Map<String, Object>>{
                    new Map<String, Object>{
                            'success' => true,
                            'id' => '01t000000000001AAA'
                    }
            };
            response.setStatusCode(200);
            response.setBody(JSON.serialize(compositeResponse));
        }

        return response;
    }
}