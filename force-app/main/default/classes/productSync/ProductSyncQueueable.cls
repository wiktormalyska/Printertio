public with sharing class ProductSyncQueueable implements Queueable, Database.AllowsCallouts {
    private List<Id> productIds;

    public ProductSyncQueueable(List<Id> productIds) {
        this.productIds = productIds;
    }

    public void execute(QueueableContext context) {
        List<Product2> products = [SELECT Id, Name, ProductCode, Description, IsActive, ExternalId FROM Product2 WHERE Id IN :productIds];
        SynchronizeService.synchronizeProducts(products);
    }
}