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

    public static String DISCOUNT_VALUE_TYPE_PERCENTAGE {
        get {
            return 'Percentage';
        }
    }

    public static String DISCOUNT_VALUE_TYPE_FIXED_AMOUNT {
        get {
            return 'Fixed Amount';
        }
    }

    public static String ORDER_STATUS_DRAFT {
        get {
            return 'Draft';
        }
    }

    public static String DISCOUNT_STRATEGY_HIGHEST {
        get {
            return 'Highest';
        }
    }

    public static String DISCOUNT_STRATEGY_LOWEST {
        get {
            return 'Lowest';
        }
    }

    public static String DISCOUNT_TYPE_TIME_BOUND {
        get {
            return 'Time-Bound';
        }
    }

    public static String DISCOUNT_TYPE_RECURRING {
        get {
            return 'Recurring';
        }
    }

    public static String DISCOUNT_TYPE_CONDITIONAL {
        get {
            return 'Conditional';
        }
    }

    public static Decimal DISCOUNT_MAXIMUM_PERCENTAGE_VALUE {
        get {
            return 50;
        }
    }

    public static String DISCOUNT_RECURRING_DATE_REPEAT_BY_DAILY {
        get {
            return 'Daily';
        }
    }
    public static String DISCOUNT_RECURRING_DATE_REPEAT_BY_WEEKLY {
        get {
            return 'Weekly';
        }
    }
    public static String DISCOUNT_RECURRING_DATE_REPEAT_BY_MONTHLY {
        get {
            return 'Monthly';
        }
    }
    public static String DISCOUNT_RECURRING_DATE_REPEAT_BY_YEARLY {
        get {
            return 'Yearly';
        }
    }

}