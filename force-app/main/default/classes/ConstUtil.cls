public with sharing class ConstUtil {
    public static String RECURRING_HELP_TIME_OF_DAY {
        get {
            return 'The discount will be active every day within the specified time range. The date in "Start" and "End" fields is ignored, only the time matters.';
        }
    }

    public static String RECURRING_HELP_DAY_OF_WEEK {
        get {
            return 'The discount will be active within the selected range of weekdays (e.g., from Monday to Friday). Only the day of the week from the date matters, the rest is ignored.';
        }
    }


    public static String RECURRING_HELP_MONTH {
        get {
            return 'The discount will be active within the selected range of months (e.g., from June to August). Only the month from the date matters, the rest is ignored.';
        }
    }

    public static String RECURRING_HELP_YEAR {
        get {
            return 'The discount will be active within the selected range of years. Only the year from the date matters, the rest is ignored.';
        }
    }
}