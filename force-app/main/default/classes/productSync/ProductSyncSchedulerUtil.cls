public class ProductSyncSchedulerUtil {

    public static void scheduleRetryJob() {
        String cronExpression = '0 0 * * * ?';

        try {
            System.schedule('Product Sync Retry Job', cronExpression, new ProductSyncRetryScheduledJob());
        } catch (Exception e) {
        }
    }

    public static void abortScheduledJobs() {
        List<CronTrigger> jobs = [
                SELECT Id
                FROM CronTrigger
                WHERE CronJobDetail.Name LIKE 'Product Sync Retry Job%'
        ];

        for (CronTrigger job : jobs) {
            System.abortJob(job.Id);
        }
    }
}