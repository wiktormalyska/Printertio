public class ProductSyncSchedulerUtil {

    public static void scheduleRetryJob() {
        String cronExpression = ConstUtil.PRODUCT_SYNC.LOGS.RETRY.CRON_EXPRESSION;
        String jobName = ConstUtil.PRODUCT_SYNC.LOGS.RETRY.JOB_NAME;

        try {
            System.schedule(jobName, cronExpression, new ScheduleProductSyncRetry());
        } catch (Exception e) {
        }
    }

    public static void abortScheduledJobs() {
        List<CronTrigger> jobs = [
                SELECT Id
                FROM CronTrigger
                WHERE CronJobDetail.Name LIKE :ConstUtil.PRODUCT_SYNC.LOGS.RETRY.JOB_NAME+'%'
        ];

        if (jobs.isEmpty()) {
            return;
        }

        for (CronTrigger job : jobs) {
            System.abortJob(job.Id);
        }
    }
}