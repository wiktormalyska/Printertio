@ISTest
private class ProductSyncSchedulerUtilTests {

    @isTest
    static void testScheduleRetryJob() {
        Test.startTest();
        ProductSyncSchedulerUtil.scheduleRetryJob();
        Test.stopTest();

        List<CronTrigger> scheduledJobs = [
                SELECT Id, CronJobDetail.Name
                FROM CronTrigger
                WHERE CronJobDetail.Name = :ConstUtil.PRODUCT_SYNC.LOGS.RETRY.JOB_NAME
        ];

        System.assertEquals(1, scheduledJobs.size());
    }

    @isTest
    static void testAbortScheduledJobsWithExistingJobs() {
        Test.startTest();
        ProductSyncSchedulerUtil.scheduleRetryJob();

        List<CronTrigger> jobsBeforeAbort = [
                SELECT Id
                FROM CronTrigger
                WHERE CronJobDetail.Name LIKE :ConstUtil.PRODUCT_SYNC.LOGS.RETRY.JOB_NAME + '%'
        ];
        System.assertEquals(1, jobsBeforeAbort.size());

        ProductSyncSchedulerUtil.abortScheduledJobs();
        Test.stopTest();

        List<CronTrigger> jobsAfterAbort = [
                SELECT Id
                FROM CronTrigger
                WHERE CronJobDetail.Name LIKE :ConstUtil.PRODUCT_SYNC.LOGS.RETRY.JOB_NAME + '%'
        ];
        System.assertEquals(0, jobsAfterAbort.size());
    }

    @isTest
    static void testAbortScheduledJobsWithNoJobs() {
        Test.startTest();
        ProductSyncSchedulerUtil.abortScheduledJobs();
        Test.stopTest();

        List<CronTrigger> jobs = [
                SELECT Id
                FROM CronTrigger
                WHERE CronJobDetail.Name LIKE :ConstUtil.PRODUCT_SYNC.LOGS.RETRY.JOB_NAME + '%'
        ];
        System.assertEquals(0, jobs.size());
    }

    @isTest
    static void testScheduleRetryJobMultipleTimes() {
        Test.startTest();
        ProductSyncSchedulerUtil.scheduleRetryJob();
        ProductSyncSchedulerUtil.scheduleRetryJob();
        Test.stopTest();

        List<CronTrigger> scheduledJobs = [
                SELECT Id
                FROM CronTrigger
                WHERE CronJobDetail.Name LIKE :ConstUtil.PRODUCT_SYNC.LOGS.RETRY.JOB_NAME + '%'
        ];

        System.assert(scheduledJobs.size() >= 1);
    }

}