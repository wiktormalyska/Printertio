public class ScheduleProductSyncRetry implements Schedulable {
    public void execute(SchedulableContext sc) {
        ProductSyncRetryBatchJob batchJob = new ProductSyncRetryBatchJob();
        Database.executeBatch(batchJob, ConstUtil.PRODUCT_SYNC.RETRY_SYNCHRONIZATION_BATCH_SIZE);
    }
}