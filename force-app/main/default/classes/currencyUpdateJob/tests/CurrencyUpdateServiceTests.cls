@IsTest
private class CurrencyUpdateServiceTests {

    @IsTest
    private static void testCorrectNBPCallout() {
        Test.setMock(HttpCalloutMock.class, new NBPSuccessHttpMock());

        List<String> currencyCodes = new List<String>{
                'USD'
        };

        List<Double> currencyRates = CurrencyUpdateService.getExchangeRate(currencyCodes);
        Assert.isTrue(currencyRates.size() == 1);
        Assert.isNotNull(currencyRates.get(0));
    }

    @IsTest
    private static void testNoCodeNBPCallout() {
        Test.setMock(HttpCalloutMock.class, new NBPNotFoundHttpMock());

        List<String> currencyCodes = new List<String>();

        List<Double> currencyRates = CurrencyUpdateService.getExchangeRate(currencyCodes);
        Assert.isTrue(currencyRates.size() == 0);
    }
}