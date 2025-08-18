public class ProductSyncMassUtil {

    public static void synchronizeMassProducts(List<Id> productIds) {
        if (productIds.isEmpty()) {
            return;
        }
        Database.executeBatch(new ProductSyncMassBatchJob(productIds), 1);
    }
}