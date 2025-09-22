public class CurrencyUpdateService {
    @InvocableMethod(
            label='Get NBP Exchange Rate for Currency Code'
            description='Fetches the current exchange rate from the National Bank of Poland API.'
    )
    public static List<Double> getExchangeRate(List<String> requests) {

        CurrencyUpdateQueueable queueable = new CurrencyUpdateQueueable(requests);
        System.enqueueJob(queueable);
        return new List<Double>();
    }
}