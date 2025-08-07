@IsTest
private class RecurringDateValidatorTests {

    @IsTest
    static void testRecurringDateInvalidWithNullStartDate() {
        Discount__c discount = DiscountBuilder.create()
                .withName('Test Discount')
                .withRecurringDateStart(null)
                .withRecurringDateEnd(Datetime.now().addDays(1))
                .withRecurringDateRepeatBy(ConstUtil.DISCOUNT_RECURRING_DATE_REPEAT_BY_DAILY)
                .build();

        Test.startTest();
        Boolean isValid = RecurringDateValidator.isRecurringDateValidForToday(discount);
        Test.stopTest();

        System.assertEquals(false, isValid, 'Recurring date should be invalid with null start date');
    }

    @IsTest
    static void testRecurringDateInvalidWithNullEndDate() {
        Discount__c discount = DiscountBuilder.create()
                .withName('Test Discount')
                .withRecurringDateStart(Datetime.now())
                .withRecurringDateEnd(null)
                .withRecurringDateRepeatBy(ConstUtil.DISCOUNT_RECURRING_DATE_REPEAT_BY_DAILY)
                .build();

        Test.startTest();
        Boolean isValid = RecurringDateValidator.isRecurringDateValidForToday(discount);
        Test.stopTest();

        System.assertEquals(false, isValid, 'Recurring date should be invalid with null end date');
    }

    @IsTest
    static void testRecurringDateValidWithDailyTimeRange() {
        // Create discount valid for current time
        Datetime now = Datetime.now();
        Datetime startTime = now.addHours(-1); // 1 hour before now
        Datetime endTime = now.addHours(1);    // 1 hour after now
        
        Discount__c discount = DiscountBuilder.create()
                .withName('Test Discount')
                .withRecurringDateStart(startTime)
                .withRecurringDateEnd(endTime)
                .withRecurringDateRepeatBy(ConstUtil.DISCOUNT_RECURRING_DATE_REPEAT_BY_DAILY)
                .build();

        Test.startTest();
        Boolean isValid = RecurringDateValidator.isRecurringDateValidForToday(discount);
        Test.stopTest();

        System.assertEquals(true, isValid, 'Recurring date should be valid for daily time range containing current time');
    }

    @IsTest
    static void testRecurringDateInvalidWithDailyTimeRangeOutside() {
        // Create discount not valid for current time
        Datetime now = Datetime.now();
        Datetime startTime = now.addHours(-3); // 3 hours before now
        Datetime endTime = now.addHours(-1);   // 1 hour before now
        
        Discount__c discount = DiscountBuilder.create()
                .withName('Test Discount')
                .withRecurringDateStart(startTime)
                .withRecurringDateEnd(endTime)
                .withRecurringDateRepeatBy(ConstUtil.DISCOUNT_RECURRING_DATE_REPEAT_BY_DAILY)
                .build();

        Test.startTest();
        Boolean isValid = RecurringDateValidator.isRecurringDateValidForToday(discount);
        Test.stopTest();

        System.assertEquals(false, isValid, 'Recurring date should be invalid for daily time range not containing current time');
    }

    @IsTest
    static void testRecurringDateValidWithWeeklyCurrentDay() {
        // Create discount valid for current day of week
        Datetime now = Datetime.now();
        String todayName = now.format('EEEE');
        
        // Set start and end to same day of week as today
        Discount__c discount = DiscountBuilder.create()
                .withName('Test Discount')
                .withRecurringDateStart(now)
                .withRecurringDateEnd(now)
                .withRecurringDateRepeatBy(ConstUtil.DISCOUNT_RECURRING_DATE_REPEAT_BY_WEEKLY)
                .build();

        Test.startTest();
        Boolean isValid = RecurringDateValidator.isRecurringDateValidForToday(discount);
        Test.stopTest();

        System.assertEquals(true, isValid, 'Recurring date should be valid for weekly when current day matches');
    }

    @IsTest
    static void testRecurringDateValidWithWeeklyRange() {
        // Create discount valid from Monday to Friday
        Datetime monday = getDateForDayOfWeek('Monday');
        Datetime friday = getDateForDayOfWeek('Friday');
        
        Discount__c discount = DiscountBuilder.create()
                .withName('Test Discount')
                .withRecurringDateStart(monday)
                .withRecurringDateEnd(friday)
                .withRecurringDateRepeatBy(ConstUtil.DISCOUNT_RECURRING_DATE_REPEAT_BY_WEEKLY)
                .build();

        Test.startTest();
        Boolean isValid = RecurringDateValidator.isRecurringDateValidForToday(discount);
        Test.stopTest();

        // This test will pass if today is Monday-Friday
        Datetime now = Datetime.now();
        String todayName = now.format('EEEE');
        Boolean shouldBeValid = (todayName == 'Monday' || todayName == 'Tuesday' ||
                                todayName == 'Wednesday' || todayName == 'Thursday' ||
                                todayName == 'Friday');

        System.assertEquals(shouldBeValid, isValid, 
            'Recurring date validity should match whether current day is in Monday-Friday range');
    }

    @IsTest
    static void testRecurringDateValidWithMonthlyCurrentDay() {
        // Create discount valid for current day of month
        Datetime now = Datetime.now();
        
        Discount__c discount = DiscountBuilder.create()
                .withName('Test Discount')
                .withRecurringDateStart(now)
                .withRecurringDateEnd(now)
                .withRecurringDateRepeatBy(ConstUtil.DISCOUNT_RECURRING_DATE_REPEAT_BY_MONTHLY)
                .build();

        Test.startTest();
        Boolean isValid = RecurringDateValidator.isRecurringDateValidForToday(discount);
        Test.stopTest();

        System.assertEquals(true, isValid, 'Recurring date should be valid for monthly when current day matches');
    }

    @IsTest
    static void testRecurringDateValidWithMonthlyRange() {
        // Create discount valid from 1st to 15th of month
        Datetime now = Datetime.now();
        Datetime firstDay = Datetime.newInstance(now.year(), now.month(), 1, 12, 0, 0);
        Datetime fifteenthDay = Datetime.newInstance(now.year(), now.month(), 15, 12, 0, 0);
        
        Discount__c discount = DiscountBuilder.create()
                .withName('Test Discount')
                .withRecurringDateStart(firstDay)
                .withRecurringDateEnd(fifteenthDay)
                .withRecurringDateRepeatBy(ConstUtil.DISCOUNT_RECURRING_DATE_REPEAT_BY_MONTHLY)
                .build();

        Test.startTest();
        Boolean isValid = RecurringDateValidator.isRecurringDateValidForToday(discount);
        Test.stopTest();

        // This test will pass if today is between 1st and 15th
        Boolean shouldBeValid = (now.day() >= 1 && now.day() <= 15);
        
        System.assertEquals(shouldBeValid, isValid, 
            'Recurring date validity should match whether current day is in 1st-15th range');
    }

    @IsTest
    static void testRecurringDateValidWithYearlyCurrentMonth() {
        // Create discount valid for current month
        Datetime now = Datetime.now();
        
        Discount__c discount = DiscountBuilder.create()
                .withName('Test Discount')
                .withRecurringDateStart(now)
                .withRecurringDateEnd(now)
                .withRecurringDateRepeatBy(ConstUtil.DISCOUNT_RECURRING_DATE_REPEAT_BY_YEARLY)
                .build();

        Test.startTest();
        Boolean isValid = RecurringDateValidator.isRecurringDateValidForToday(discount);
        Test.stopTest();

        System.assertEquals(true, isValid, 'Recurring date should be valid for yearly when current month matches');
    }

    @IsTest
    static void testRecurringDateValidWithYearlyRange() {
        // Create discount valid from June to August
        Datetime now = Datetime.now();
        Datetime june = Datetime.newInstance(now.year(), 6, 1, 12, 0, 0);
        Datetime august = Datetime.newInstance(now.year(), 8, 1, 12, 0, 0);
        
        Discount__c discount = DiscountBuilder.create()
                .withName('Test Discount')
                .withRecurringDateStart(june)
                .withRecurringDateEnd(august)
                .withRecurringDateRepeatBy(ConstUtil.DISCOUNT_RECURRING_DATE_REPEAT_BY_YEARLY)
                .build();

        Test.startTest();
        Boolean isValid = RecurringDateValidator.isRecurringDateValidForToday(discount);
        Test.stopTest();

        // This test will pass if current month is June, July, or August
        Boolean shouldBeValid = (now.month() >= 6 && now.month() <= 8);
        
        System.assertEquals(shouldBeValid, isValid, 
            'Recurring date validity should match whether current month is in June-August range');
    }

    @IsTest
    static void testRecurringDateInvalidWithUnknownRepeatBy() {
        Discount__c discount = DiscountBuilder.create()
                .withName('Test Discount')
                .withRecurringDateStart(Datetime.now())
                .withRecurringDateEnd(Datetime.now().addDays(1))
                .withRecurringDateRepeatBy('Invalid Option')
                .build();

        Test.startTest();
        Boolean isValid = RecurringDateValidator.isRecurringDateValidForToday(discount);
        Test.stopTest();

        System.assertEquals(false, isValid, 'Recurring date should be invalid with unknown repeat by option');
    }

    // Helper method to get a datetime for a specific day of the week
    private static Datetime getDateForDayOfWeek(String dayName) {
        Datetime now = Datetime.now();
        Map<String, Integer> weekdayMap = new Map<String, Integer>{
            'Monday' => 1, 'Tuesday' => 2, 'Wednesday' => 3, 'Thursday' => 4,
            'Friday' => 5, 'Saturday' => 6, 'Sunday' => 7
        };
        
        Integer targetDay = weekdayMap.get(dayName);
        String currentDayName = now.format('EEEE');
        Integer currentDay = weekdayMap.get(currentDayName);
        
        // Calculate days to add/subtract to get to target day
        Integer daysToAdd = targetDay - currentDay;
        
        return now.addDays(daysToAdd);
    }
}
