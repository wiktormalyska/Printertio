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

        if (repeatByOptions.equals(ConstUtil.DISCOUNT.RECURRING_TYPE.REPEAT.DAILY)) {
            if (today >= startDate && today <= endDate) {
                return true;
            }
        }

        if (repeatByOptions.equals(ConstUtil.DISCOUNT.RECURRING_TYPE.REPEAT.WEEKLY)) {
            Integer todayDayOfWeek = weekdayMap.get(String.valueOf(today.format('EEEE')));
            if (todayDayOfWeek != null && todayDayOfWeek >= 1 && todayDayOfWeek <= 7) {
                Integer startDayOfWeek = weekdayMap.get(String.valueOf(startDate.format('EEEE')));
                Integer endDayOfWeek = weekdayMap.get(String.valueOf(endDate.format('EEEE')));

                if (todayDayOfWeek >= startDayOfWeek && todayDayOfWeek <= endDayOfWeek) {
                    return true;
                }
            }
        }

        if (repeatByOptions.equals(ConstUtil.DISCOUNT.RECURRING_TYPE.REPEAT.MONTHLY)) {
            if (today.day() >= startDate.day() && today.day() <= endDate.day()) {
                return true;
            }
        }

        if (repeatByOptions.equals(ConstUtil.DISCOUNT.RECURRING_TYPE.REPEAT.YEARLY)) {
            if (today.month() >= startDate.month() && today.month() <= endDate.month()) {
                return true;
            }
        }

        return false;
    }
}