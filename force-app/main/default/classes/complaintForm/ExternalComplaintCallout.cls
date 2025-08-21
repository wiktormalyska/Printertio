public class ExternalComplaintCallout implements Queueable, Database.AllowsCallouts {
    private List<Product2> products;
    private UUID randomUUID;

    public ExternalComplaintCallout(List<Product2> products, UUID randomUUID) {
        this.products = products;
        this.randomUUID = randomUUID;
    }

    public static void sendComplaintsAsync(List<Product2> products, UUID randomUUID) {
        if (products != null && !products.isEmpty()) {
            System.enqueueJob(new ExternalComplaintCallout(products, randomUUID));
        }
    }

    public void execute(QueueableContext context) {
        if (products != null && !products.isEmpty()) {
            SendProductComplaintsBatchJob batchJob = new SendProductComplaintsBatchJob(this.products, this.randomUUID);
            System.debug(this.products);
            Database.executeBatch(batchJob, 1);
        }
    }
}