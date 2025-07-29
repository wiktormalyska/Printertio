@isTest
global class MockHttpResponseGetDamianOrgAccounts implements HttpCalloutMock {

    global HttpResponse respond(HttpRequest req) {
        System.assertEquals(true, req.getEndpoint().contains('callout:DamianOrg/services/data/v62.0/query?q='));
        System.assertEquals('GET', req.getMethod());

        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setStatusCode(200);

        Map<String, Object> responsePayload = new Map<String, Object>();
        responsePayload.put('totalSize', 2);
        responsePayload.put('done', true);

        List<Map<String, Object>> records = new List<Map<String, Object>>();

        Map<String, Object> record1 = new Map<String, Object>();
        record1.put('Id', '0015Y00002pGk4hQAC');
        record1.put('Name', 'Global Media Test');
        record1.put('Industry', 'Media');
        record1.put('Phone', '(123) 456-7890');
        record1.put('Owner', new Map<String, String>{'Email' => 'owner1@example.com'});
        records.add(record1);

        Map<String, Object> record2 = new Map<String, Object>();
        record2.put('Id', '0015Y00002pGk4iQAC');
        record2.put('Name', 'United Oil & Gas Corp. Test');
        record2.put('Industry', 'Energy');
        record2.put('Phone', '(234) 567-8901');
        record2.put('Owner', new Map<String, String>{'Email' => 'owner2@example.com'});
        records.add(record2);

        responsePayload.put('records', records);
        response.setBody(JSON.serialize(responsePayload));

        return response;
    }
}