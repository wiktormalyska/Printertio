@IsTest
public class NBPSuccessHttpMock implements HttpCalloutMock {
    public static Double generatedRate { get; private set; }

    public HttpResponse respond(HttpRequest request) {

        Double randomRate = 3.5 + (Math.random() * 1.5);
        generatedRate = randomRate;

        String endpoint = request.getEndpoint();
        String currencyCode = endpoint.substringBetween('/a/', '/');

        String responseBody =
                '{' +
                    '"table":"A",' +
                    '"currency":"Waluta testowa",' +
                    '"code":"'+currencyCode.toUpperCase()+'",' +
                    '"rates":[' +
                        '{' +
                            '"no":"123/A/NBP/2025",' +
                            '"effectiveDate":"2025-09-18",' +
                            '"mid":'+String.valueOf(generatedRate)+
                        '}' +
                    ']' +
                '}';

        System.debug(responseBody);

        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody(responseBody);
        response.setStatusCode(200);
        response.setStatus('OK');
        return response;
    }
}