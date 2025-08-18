public class ProductSyncSchedulerUtil {

    public static void scheduleRetryJob() {
        String cronExpression = '0 0 0 * * ?';
        String jobName = 'Product Sync Retry Job';

        try {
            System.schedule(jobName, cronExpression, new ScheduleProductSyncRetry());
        } catch (Exception e) {
        }
    }

    public static void abortScheduledJobs() {
        List<CronTrigger> jobs = [
                SELECT Id
                FROM CronTrigger
                WHERE CronJobDetail.Name LIKE 'Product Sync Retry Job%'
        ];

        if (jobs.isEmpty()) {
            return;
        }

        for (CronTrigger job : jobs) {
            System.abortJob(job.Id);
        }
    }
}