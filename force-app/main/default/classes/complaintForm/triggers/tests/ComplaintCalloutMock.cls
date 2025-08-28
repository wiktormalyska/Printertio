@IsTest
global class ComplaintCalloutMock implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {
        // Create a fake response.
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"status": "success", "message": "Approval status received."}');
        res.setStatusCode(201);
        return res;
    }
}