public with sharing class RecurringDateValidator {
    public static Boolean isRecurringDateValidForToday(Discount__c discount) {
        Map<String, Integer> weekdayMap = new Map<String, Integer>{
                'Monday' => 1,
                'Tuesday' => 2,
                'Wednesday' => 3,
                'Thursday' => 4,
                'Friday' => 5,
                'Saturday' => 6,
                'Sunday' => 7
        };

        String repeatByOptions = discount.Recurring_Date_Repeat_By__c;
        if (discount.Recurring_Date_Start__c == null || discount.Recurring_Date_End__c == null) {
            return false;
        }

        Datetime startDate = discount.Recurring_Date_Start__c;
        Datetime endDate = discount.Recurring_Date_End__c;
        Datetime today = Datetime.now();

        if (repeatByOptions.equals('Time of Day')) {
            if (today.time() >= startDate.time() && today.time() <= endDate.time()) {
                return true;
            }
        }

        if (repeatByOptions.equals('Day of the Week')) {
            Integer todayDayOfWeek = weekdayMap.get(String.valueOf(today.format('EEEE')));
            System.debug('Today Day of Week: ' + todayDayOfWeek);
            if (todayDayOfWeek != null && todayDayOfWeek >= 1 && todayDayOfWeek <= 7) {
                Integer startDayOfWeek = weekdayMap.get(String.valueOf(startDate.format('EEEE')));
                Integer endDayOfWeek = weekdayMap.get(String.valueOf(endDate.format('EEEE')));
                System.debug('Start Day of Week: ' + startDayOfWeek);
                System.debug('End Day of Week: ' + endDayOfWeek);

                if (todayDayOfWeek >= startDayOfWeek && todayDayOfWeek <= endDayOfWeek) {
                    System.debug(startDate.format('EEEE') + ' to ' + endDate.format('EEEE') + ' matches today: ' + today.format('EEEE'));
                    return true;
                }
            }
        }

        if (repeatByOptions.equals('Day of the Month')) {
            if (today.day() >= startDate.day() && today.day() <= endDate.day()) {
                return true;
            }
        }

        if (repeatByOptions.equals('Month')) {
            if (today.month() >= startDate.month() && today.month() <= endDate.month()) {
                return true;
            }
        }

        if (repeatByOptions.equals('Year')) {
            if (today.year() >= startDate.year() && today.year() <= endDate.year()) {
                return true;
            }
        }

        return false;
    }
}