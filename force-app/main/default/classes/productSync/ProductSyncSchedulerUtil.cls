public class ProductSyncSchedulerUtil {

    public static void scheduleRetryJob() {
        String cronExpression = '0 0 * * * ?'; // Every minute

        try {
            System.schedule('Product Sync Retry Job', cronExpression, new ProductSyncRetryScheduledJob());
            System.debug('Product Sync Retry Job scheduled successfully');
        } catch (Exception e) {
            System.debug('Failed to schedule retry job: ' + e.getMessage());
        }
    }

    public static void abortScheduledJobs() {
        List<CronTrigger> jobs = [
                SELECT Id FROM CronTrigger
                WHERE CronJobDetail.Name LIKE 'Product Sync Retry Job%'
        ];

        for (CronTrigger job : jobs) {
            System.abortJob(job.Id);
        }
    }
}