public class ProductSyncQueueable implements Queueable, Database.AllowsCallouts {

    private static final Integer MAX_PRODUCTS_PER_CALL = 10;
    private List<Id> productIds;

    public ProductSyncQueueable(List<Id> productIds) {
        this.productIds = productIds;
    }

    public void execute(QueueableContext context) {
        if (productIds.size() > MAX_PRODUCTS_PER_CALL) {
            Database.executeBatch(new ProductSyncMassBatchJob(productIds), MAX_PRODUCTS_PER_CALL);
            return;
        }

        List<Product2> products = [
                SELECT Id, Name, ProductCode, Description, IsActive, ExternalId, IsExternal__c
                FROM Product2
                WHERE Id IN :productIds
                AND IsExternal__c != true
        ];

        if (!products.isEmpty()) {
            SynchronizeService.synchronizeProducts(products);
        }
    }
}