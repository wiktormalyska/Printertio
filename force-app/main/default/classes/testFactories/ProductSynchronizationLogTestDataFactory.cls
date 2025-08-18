public virtual class ProductSynchronizationLogTestDataFactory implements TestDataFactory {
    public SObject prepare() {
        return ProductSynchronizationLogBuilder.create()
                .withStatus(ProductSynchronizationLogBuilder.LogStatus.success)
                .withRequestBody('{"records":[{"IsSentFromOther__c":true,"IsActive":false,"Description":null,"ProductCode":null,"Name":"bobi3","Id":"01tgK000004iHqrQAE","attributes":{"type":"Product2"}}],"allOrNone":false}')
                .withResponseBody('[{"id":"01tgK000004iHqrQAE","success":true,"errors":[]}]')
                .withTime(System.now())
                .withRetryCount(0)
                .build();
    }

    public virtual SObject create() {
        return prepare();
    }

    public void save() {
        SObject productSyncLog = create();
        insert productSyncLog;
    }
}