@ISTest
private class ProductSyncSchedulerUtilTests {
//    @IsTest
//    static void testScheduleRetryJobSuccess() {
//        Test.startTest();
//        ProductSyncSchedulerUtil.scheduleRetryJob();
//        Test.stopTest();
//
//        // Verify job was scheduled
//        List<CronTrigger> scheduledJobs = [
//                SELECT Id, CronJobDetail.Name, CronExpression, State
//                FROM CronTrigger
//                WHERE CronJobDetail.Name = 'Product Sync Retry Job'
//        ];
//
//        System.assertEquals(1, scheduledJobs.size(), 'One job should be scheduled');
//        System.assertEquals('Product Sync Retry Job',
//                scheduledJobs[0].CronJobDetail.Name,
//                'Job name should match');
//        System.assertEquals('0 0 * * * ?',
//                scheduledJobs[0].CronExpression,
//                'Cron expression should match');
//        System.assertEquals('WAITING',
//                scheduledJobs[0].State,
//                'Job should be in WAITING state');
//    }
//
//    @IsTest
//    static void testScheduleRetryJobMultipleCalls() {
//        Test.startTest();
//
//        ProductSyncSchedulerUtil.scheduleRetryJob();
//
//        ProductSyncSchedulerUtil.scheduleRetryJob();
//
//        Test.stopTest();
//
//        List<CronTrigger> scheduledJobs = [
//                SELECT Id, CronJobDetail.Name
//                FROM CronTrigger
//                WHERE CronJobDetail.Name = 'Product Sync Retry Job'
//        ];
//
//        System.assert(scheduledJobs.size() >= 1, 'At least one job should be scheduled');
//    }
//
//    @IsTest
//    static void testAbortScheduledJobsWithExistingJobs() {
//        Test.startTest();
//        String jobId1 = System.schedule('Product Sync Retry Job 1', '0 0 1 * * ?', new ProductSyncRetryScheduledJob());
//        String jobId2 = System.schedule('Product Sync Retry Job 2', '0 0 2 * * ?', new ProductSyncRetryScheduledJob());
//        String jobId3 = System.schedule('Other Job', '0 0 3 * * ?', new ProductSyncRetryScheduledJob());
//
//        List<CronTrigger> allJobs = [
//                SELECT Id, CronJobDetail.Name, State
//                FROM CronTrigger
//                WHERE Id IN (:jobId1, :jobId2, :jobId3)
//        ];
//        System.assertEquals(3, allJobs.size(), 'Three jobs should be created');
//
//        ProductSyncSchedulerUtil.abortScheduledJobs();
//        Test.stopTest();
//
//        List<CronTrigger> remainingJobs = [
//                SELECT Id, CronJobDetail.Name, State
//                FROM CronTrigger
//                WHERE Id IN (:jobId1, :jobId2, :jobId3)
//                AND State != 'DELETED'
//        ];
//
//        List<CronTrigger> productSyncJobs = new List<CronTrigger>();
//        List<CronTrigger> otherJobs = new List<CronTrigger>();
//
//        for (CronTrigger job : remainingJobs) {
//            if (job.CronJobDetail.Name.startsWith('Product Sync Retry Job')) {
//                productSyncJobs.add(job);
//            } else {
//                otherJobs.add(job);
//            }
//        }
//
//        System.assertEquals(0, productSyncJobs.size(),
//                'Product Sync Retry Jobs should be aborted');
//
//        System.assertEquals(1, otherJobs.size(),
//                'Other jobs should not be affected');
//    }
//
//    @IsTest
//    static void testAbortScheduledJobsWithNoExistingJobs() {
//        List<CronTrigger> initialJobs = [
//                SELECT Id
//                FROM CronTrigger
//                WHERE CronJobDetail.Name LIKE 'Product Sync Retry Job%'
//        ];
//        System.assertEquals(0, initialJobs.size(), 'No Product Sync Retry Jobs should exist initially');
//
//        Test.startTest();
//        ProductSyncSchedulerUtil.abortScheduledJobs();
//        Test.stopTest();
//
//        System.assert(true, 'Method should complete without errors when no jobs exist');
//    }
//
//    @IsTest
//    static void testAbortScheduledJobsWithVariousJobNames() {
//        Test.startTest();
//        String jobId1 = System.schedule('Product Sync Retry Job', '0 0 1 * * ?', new ProductSyncRetryScheduledJob());
//        String jobId2 = System.schedule('Product Sync Retry Job - Instance 1', '0 0 2 * * ?', new ProductSyncRetryScheduledJob());
//        String jobId3 = System.schedule('Product Sync Retry Job_Test', '0 0 3 * * ?', new ProductSyncRetryScheduledJob());
//        String jobId4 = System.schedule('Different Job Name', '0 0 4 * * ?', new ProductSyncRetryScheduledJob());
//
//        ProductSyncSchedulerUtil.abortScheduledJobs();
//        Test.stopTest();
//
//        List<CronTrigger> remainingJobs = [
//                SELECT Id, CronJobDetail.Name, State
//                FROM CronTrigger
//                WHERE Id IN (:jobId1, :jobId2, :jobId3, :jobId4)
//                AND State != 'DELETED'
//        ];
//
//        Integer productSyncJobsRemaining = 0;
//        Integer otherJobsRemaining = 0;
//
//        for (CronTrigger job : remainingJobs) {
//            if (job.CronJobDetail.Name.startsWith('Product Sync Retry Job')) {
//                productSyncJobsRemaining++;
//            } else {
//                otherJobsRemaining++;
//            }
//        }
//
//        System.assertEquals(0, productSyncJobsRemaining,
//                'All Product Sync Retry Jobs should be aborted');
//        System.assertEquals(1, otherJobsRemaining,
//                'Jobs not matching pattern should remain');
//    }
//
//    @IsTest
//    static void testScheduleAndAbortCombination() {
//        Test.startTest();
//
//        ProductSyncSchedulerUtil.scheduleRetryJob();
//        List<CronTrigger> scheduledJobs = [
//                SELECT Id
//                FROM CronTrigger
//                WHERE CronJobDetail.Name = 'Product Sync Retry Job'
//        ];
//        System.assertEquals(1, scheduledJobs.size(), 'Job should be scheduled');
//        ProductSyncSchedulerUtil.abortScheduledJobs();
//
//        Test.stopTest();
//        List<CronTrigger> remainingJobs = [
//                SELECT Id, State
//                FROM CronTrigger
//                WHERE CronJobDetail.Name = 'Product Sync Retry Job'
//                AND State != 'DELETED'
//        ];
//        System.assertEquals(0, remainingJobs.size(), 'Job should be aborted');
//    }
//
//    @IsTest
//    static void testCronExpressionValidation() {
//        Test.startTest();
//        ProductSyncSchedulerUtil.scheduleRetryJob();
//        Test.stopTest();
//
//        List<CronTrigger> scheduledJobs = [
//                SELECT CronExpression
//                FROM CronTrigger
//                WHERE CronJobDetail.Name = 'Product Sync Retry Job'
//        ];
//
//        if (!scheduledJobs.isEmpty()) {
//            String cronExpression = scheduledJobs[0].CronExpression;
//
//            List<String> cronParts = cronExpression.split(' ');
//            System.assertEquals(6, cronParts.size(), 'Cron expression should have 6 parts');
//            System.assertEquals('0', cronParts[0], 'Seconds should be 0');
//            System.assertEquals('0', cronParts[1], 'Minutes should be 0');
//            System.assertEquals('*', cronParts[2], 'Hours should be *');
//            System.assertEquals('*', cronParts[3], 'Day should be *');
//            System.assertEquals('*', cronParts[4], 'Month should be *');
//            System.assertEquals('?', cronParts[5], 'Day of week should be ?');
//        }
//    }
}