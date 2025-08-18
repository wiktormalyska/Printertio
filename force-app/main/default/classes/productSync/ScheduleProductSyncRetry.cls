public class ScheduleProductSyncRetry implements Schedulable {
    public void execute(SchedulableContext sc) {
        ProductSyncRetryBatchJob batchJob = new ProductSyncRetryBatchJob();
        Database.executeBatch(batchJob, 20);
    }
}