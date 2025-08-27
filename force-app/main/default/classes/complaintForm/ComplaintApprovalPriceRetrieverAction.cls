global class ComplaintApprovalPriceRetrieverAction {

    @InvocableMethod(label='Get Unit Price from Complaint Approval' description='Retrieves unit price from second org based on complaint approval ID')
    global static List<Result> getUnitPriceFromComplaintApproval(List<Request> requests) {
        List<Result> results = new List<Result>();
        for (Request request : requests) {
            Result result = new Result();
            try {
                result.unitPrice = retrieveUnitPrice(request.complaintApprovalId);
                result.isSuccess = true;
            } catch (Exception e) {
                result.errorMessage = e.getMessage();
                result.isSuccess = false;
            }
            results.add(result);
        }

        return results;
    }

    private static Decimal retrieveUnitPrice(String complaintApprovalId) {
        String complaintQuery =
                'SELECT Id, ' + Complaint_Approval_Request__c.Case__c.toString() + ' ' +
                        'FROM ' + Complaint_Approval_Request__c.SObjectType.getDescribe().getName() + ' ' +
                        'WHERE Id = \'' + complaintApprovalId + '\'';
        HttpResponse complaintResponse = makeCallout(complaintQuery);
        Map<String, Object> complaintData = parseResponse(complaintResponse);
        String caseId = (String) complaintData.get(Complaint_Approval_Request__c.Case__c.toString());

        String caseQuery =
                'SELECT Id, ' + Case.Order__c.toString() + ' ' +
                        'FROM ' + Case.Order__c.toString() + ' ' +
                        'WHERE Id = \'' + caseId + '\'';
        HttpResponse caseResponse = makeCallout(caseQuery);
        Map<String, Object> caseData = parseResponse(caseResponse);
        String orderId = (String) caseData.get(Case.Order__c.toString());

        String orderProductQuery =
                'SELECT Id, ' + OrderItem.Product2Id.toString() + ', ' + OrderItem.UnitPrice.toString() + ' ' +
                        'FROM ' + OrderItem.SObjectType.getDescribe().getName() + ' ' +
                        'WHERE OrderId = \'' + orderId + '\'';
        HttpResponse orderResponse = makeCallout(orderProductQuery);
        List<Object> orderProducts = parseResponseList(orderResponse);

        String complaintProductId = getComplaintProductId(complaintApprovalId);

        for (Object productObj : orderProducts) {
            Map<String, Object> product = (Map<String, Object>) productObj;
            if (product.get(OrderItem.Product2Id.toString()) == complaintProductId) {
                return (Decimal) product.get(OrderItem.UnitPrice.toString());
            }
        }

        throw new CalloutException(System.Label.Unit_price_not_found_for_complaint_approval + complaintApprovalId);
    }

    private static String getComplaintProductId(String complaintApprovalId) {
        String productQuery = 'SELECT Id, ' + Complaint_Approval_Request__c.Product__c.toString() + ' ' +
                'FROM ' + Complaint_Approval_Request__c.SObjectType.getDescribe().getName() + ' ' +
                'WHERE Id = \'' + complaintApprovalId + '\'';
        HttpResponse response = makeCallout(productQuery);
        Map<String, Object> data = parseResponse(response);
        return (String) data.get(Complaint_Approval_Request__c.Product__c.toString());
    }

    private static HttpResponse makeCallout(String soqlQuery) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint(ConstUtil.CONNECTED_APPS.PRODUCT_SYNC.NAMED_CREDENTIAL + ConstUtil.ENDPOINT.QUERY+ EncodingUtil.urlEncode(soqlQuery, 'UTF-8'));
        req.setMethod('GET');
        req.setHeader('Content-Type', 'application/json');

        Http http = new Http();
        HttpResponse response = http.send(req);

        if (response.getStatusCode() != 200) {
            throw new CalloutException('Callout failed: ' + response.getBody());
        }

        return response;
    }

    private static Map<String, Object> parseResponse(HttpResponse response) {
        Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
        List<Object> records = (List<Object>) responseMap.get('records');
        if (records == null || records.isEmpty()) {
            throw new CalloutException(System.Label.No_records_found);
        }

        return (Map<String, Object>) records[0];
    }

    private static List<Object> parseResponseList(HttpResponse response) {
        Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
        List<Object> records = (List<Object>) responseMap.get('records');

        if (records == null || records.isEmpty()) {
            throw new CalloutException(System.Label.No_records_found);
        }

        return records;
    }

    global class Request {
        @InvocableVariable(required=true)
        global String complaintApprovalId;
    }

    global class Result {
        @InvocableVariable
        global Decimal unitPrice;

        @InvocableVariable
        global Boolean isSuccess;

        @InvocableVariable
        global String errorMessage;
    }
}