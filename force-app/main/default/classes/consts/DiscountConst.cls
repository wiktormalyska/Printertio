public class DiscountConst {
    public Value VALUE {
        get {
            return new Value();
        }
    }
    public Strategy STRATEGY {
        get {
            return new Strategy();
        }
    }
    public DiscountType TYPE {
        get {
            return new DiscountType();
        }
    }
    public RecurringTypeConst RECURRING_TYPE {
        get {
            return new RecurringTypeConst();
        }
    }
    public ConditionTypeConst CONDITION_TYPE {
        get {
            return new ConditionTypeConst();
        }
    }


    public class Value {
        public ValueType TYPE {
            get {
                return new ValueType();
            }
        }



        public final Decimal MAXIMUM_PERCENTAGE { get { return 50; } }
    }

    public class Strategy {
        public final String HIGHEST { get { return 'Highest'; } }
        public final String LOWEST { get { return 'Lowest'; } }
    }

    public class DiscountType {
        public final String TIME_BOUND { get { return 'Time-Bound'; } }
        public final String RECURRING { get { return 'Recurring'; } }
        public final String CONDITIONAL { get { return 'Conditional'; } }
    }



    public class RecurringTypeConst {
        public RepeatBy REPEAT {
            get {
                return new RepeatBy();
            }
        }

        public HelpTexts HELP_TEXTS {
            get {
                return new HelpTexts();
            }
        }


    }

    public class ConditionTypeConst {
        public final Integer MINIMUM_ORDER_ITEM_COUNT { get {return 5;} }
    }

    public class HelpTexts {
        public final String DAILY { get { return 'The discount will be active every day within the specified time range. The date in "Start" and "End" fields is ignored, only the time matters.'; } }
        public final String WEEKLY { get { return 'The discount will be active within the selected range of weekdays (e.g., from Monday to Friday). Only the day of the week from the date matters, the rest is ignored.'; } }
        public final String MONTHLY { get { return 'The discount will be active within the selected range of months (e.g., from June to August). Only the month from the date matters, the rest is ignored.'; } }
        public final String YEARLY { get { return 'The discount will be active within the selected range of years. Only the year from the date matters, the rest is ignored.'; } }
    }

    public class RepeatBy {
        public final String DAILY { get { return 'Daily'; } }
        public final String WEEKLY { get { return 'Weekly'; } }
        public final String MONTHLY { get { return 'Monthly'; } }
        public final String YEARLY { get { return 'Yearly'; } }
    }

    public class ValueType {
        public final String PERCENTAGE { get { return 'Percentage'; } }
        public final String FIXED_AMOUNT { get { return 'Amount'; } }
    }
}