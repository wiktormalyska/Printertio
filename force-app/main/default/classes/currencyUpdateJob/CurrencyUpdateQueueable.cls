public class CurrencyUpdateQueueable implements Queueable, Database.AllowsCallouts {
    private List<String> currencyCodes;

    public CurrencyUpdateQueueable(List<String> currencyCodes) {
        this.currencyCodes = currencyCodes;
    }

    public void execute(QueueableContext context) {
        try {
            // Perform the API callout inside queueable
            List<Double> rates = performCallout(currencyCodes);
            System.debug('Currency rates retrieved: ' + rates);
            updateCurrencyRates(rates);
        } catch (Exception e) {
            System.debug(System.LoggingLevel.ERROR, 'Queueable currency update failed: ' + e.getMessage());
        }
    }

    private List<Double> performCallout(List<String> currencyCodes) {
        List<Double> responseRates = new List<Double>();
        Http http = new Http();

        for (String currencyCode : currencyCodes) {
            Double currencyRate = null;

            try {
                HttpRequest httpRequest = new HttpRequest();
                String endpoint = 'callout:NBP_API/api/exchangerates/rates/a/' + currencyCode + '?format=json';
                httpRequest.setEndpoint(endpoint);
                httpRequest.setMethod('GET');
                httpRequest.setTimeout(10000);

                HttpResponse httpResponse = http.send(httpRequest);

                if (httpResponse.getStatusCode() == 200) {
                    Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(httpResponse.getBody());
                    List<Object> ratesList = (List<Object>) results.get('rates');

                    if (ratesList != null && !ratesList.isEmpty()) {
                        Map<String, Object> firstRate = (Map<String, Object>) ratesList[0];
                        Object midRate = firstRate.get('mid');

                        if (midRate instanceof Decimal || midRate instanceof Double) {
                            currencyRate = 1 / ((Decimal) midRate).doubleValue();
                        }
                    }
                } else {
                    System.debug(System.LoggingLevel.WARN, 'NBP API returned status ' + httpResponse.getStatusCode() + ' for currency ' + currencyCode);
                }
            } catch (Exception e) {
                System.debug(System.LoggingLevel.ERROR, 'Callout failed for ' + currencyCode + '. Error: ' + e.getMessage());
            }
            responseRates.add(currencyRate);
        }
        return responseRates;
    }

    private void updateCurrencyRates(List<Double> rates) {
        for (Integer i = 0; i < currencyCodes.size() && i < rates.size(); i++) {
            String currencyCode = currencyCodes[i];
            Double rate = rates[i];

            if (rate != null) {
                updateSingleCurrencyRate(currencyCode, rate);
            }
        }
    }

    private static void updateSingleCurrencyRate(String currencyCode, Double rate) {
        try {
            // Check if a rate already exists for today
            List<DatedConversionRate> existingRates = [
                    SELECT Id, ConversionRate
                    FROM DatedConversionRate
                    WHERE IsoCode = :currencyCode
                    AND StartDate = TODAY
                    LIMIT 1
            ];

            if (existingRates.isEmpty()) {
                System.debug('No existing rate found for ' + currencyCode + ' for today - skipping update');
                return;
            }

            // Update existing record
            DatedConversionRate existingRate = existingRates[0];
            Http http = new Http();
            HttpRequest request = new HttpRequest();

            request.setEndpoint(URL.getOrgDomainUrl().toExternalForm() + '/services/data/v64.0/sobjects/DatedConversionRate/' + existingRate.Id);
            request.setBody('{ "ConversionRate": ' + rate + ' }');
            request.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());
            request.setHeader('Content-Type', 'application/json');
            request.setMethod('PATCH');

            HttpResponse res = http.send(request);

            if (res.getStatusCode() == 200 || res.getStatusCode() == 204) {
                System.debug('Successfully updated currency rate for ' + currencyCode + ' from ' + existingRate.ConversionRate + ' to ' + rate);
            } else {
                System.debug(System.LoggingLevel.ERROR, 'Failed to update currency rate for ' + currencyCode + '. Status: ' + res.getStatusCode() + ', Body: ' + res.getBody());
            }
        } catch (Exception e) {
            System.debug(System.LoggingLevel.ERROR, 'Failed to update currency rate for ' + currencyCode + ': ' + e.getMessage());
        }
    }
}