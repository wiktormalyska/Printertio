public class ProductSynchronizationLogBuilder {
    private Product_Synchronization_Log__c log;

    private ProductSynchronizationLogBuilder() {
        this.log = new Product_Synchronization_Log__c();
        this.log.Retry_Count__c = 0;
    }

    public static ProductSynchronizationLogBuilder create() {
        return new ProductSynchronizationLogBuilder();
    }

    public ProductSynchronizationLogBuilder withId(Id id) {
        this.log.Id = id;
        return this;
    }
    public ProductSynchronizationLogBuilder withRequestBody(String requestBody) {
        this.log.request_Body__c = requestBody;
        return this;
    }
    public ProductSynchronizationLogBuilder withResponseBody(String responseBody) {
        this.log.response_Body__c = responseBody;
        return this;
    }
    public ProductSynchronizationLogBuilder withStatus(LogStatus status) {
        this.log.Status__c = status.toString();
        return this;
    }

    public ProductSynchronizationLogBuilder withTime(DateTime timeOfLog) {
        this.log.Time__c = timeOfLog;
        return this;
    }

    public Product_Synchronization_Log__c build() {
        if (this.log.Time__c == null) {
            this.log.Time__c = System.now();
        }
        if (this.log.Status__c == null) {
            this.log.Status__c = LogStatus.SUCCESS.toString();
        }
        return this.log;
    }

    public enum LogStatus {
        SUCCESS,
        ERROR,
        RESOLVED,
        FAILED
    }

    public ProductSynchronizationLogBuilder withRetryCount(Integer retryCount) {
        this.log.Retry_Count__c = retryCount;
        return this;
    }
}