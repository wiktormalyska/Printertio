public class ProductSyncMassBatchJob implements Database.Batchable<Product2>, Database.AllowsCallouts {

    private List<Id> productIds;

    public ProductSyncMassBatchJob(List<Id> productIds) {
        this.productIds = productIds;
    }

    public Iterable<Product2> start(Database.BatchableContext bc) {
        return [
                SELECT Id, Name, ProductCode, Description, IsActive, ExternalId, IsExternal__c
                FROM Product2
                WHERE Id IN :productIds
                AND IsExternal__c != true
        ];
    }

    public void execute(Database.BatchableContext bc, List<Product2> scope) {
        try {
            SynchronizeService.synchronizeProducts(scope);
        } catch (Exception e) {
            System.debug('ProductSyncMassBatchJob execution error: ' + e.getMessage());
        }
    }

    public void finish(Database.BatchableContext bc) {
        System.debug('ProductSyncMassBatchJob completed successfully');
    }
}