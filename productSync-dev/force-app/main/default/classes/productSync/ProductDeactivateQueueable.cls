public class ProductDeactivateQueueable implements Queueable, Database.AllowsCallouts {

    private List<Id> productIds;

    public ProductDeactivateQueueable(List<Id> productIds) {
        this.productIds = productIds;
    }

    public void execute(QueueableContext context) {
        System.debug('Executing ProductDeactivateQueueable for productIds: ' + productIds);
        List<Product2> productsToDeactivate = [SELECT Id, Name, ProductCode, Description, IsActive, ExternalId FROM Product2 WHERE Id IN :productIds];

        for (Product2 product : productsToDeactivate) {
            product.IsActive = false;
        }

        update productsToDeactivate;
        System.debug('Products deactivated: ' + productsToDeactivate.size());

        SynchronizeService.synchronizeProducts(productsToDeactivate);
    }
}