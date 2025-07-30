public with sharing class DiscountCalculatorHandler {

    //Store data about discount settings
    private class DiscountSettings {
        public String strategy;
        public Decimal maxDiscountPercent;

        public DiscountSettings() {
            List<Discount_Settings__mdt> settingsList = [
                    SELECT Discount_Strategy__c, Max_Overall_Discount_Percentage__c
                    FROM Discount_Settings__mdt
                    LIMIT 1
            ];
            if (!settingsList.isEmpty()) {
                Discount_Settings__mdt settings = settingsList[0];
                this.strategy = settings.Discount_Strategy__c;
                this.maxDiscountPercent = settings.Max_Overall_Discount_Percentage__c;
            } else {
                this.strategy = 'Highest';
                this.maxDiscountPercent = 50.0;
            }
        }
    }

    //Triggered after insert to apply discounts
    public static void applyDiscountsAfterInsert(List<Order> insertedOrders) {
        DiscountSettings settings = new DiscountSettings();
        List<Discount__c> activeDiscounts = [
                SELECT Id, Name, Discount_Type__c, Value_Type__c, Discount_Value__c,
                        Start_Date__c, End_Date__c, Cron_Expression__c, Condition_Logic__c
                FROM Discount__c
                WHERE Is_Active__c = TRUE
        ];

        List<Discount__c> filteredDiscounts = filterDiscounts(activeDiscounts, settings);


    }

    private static List<Discount__c> filterDiscounts(List<Discount__c> discounts, DiscountSettings settings) {
        List<Discount__c> filteredDiscounts = new List<Discount__c>();

        for (Discount__c discount : discounts) {
            switch on discount.Discount_Type__c {
                //From date to date
                when 'Time-Bound' {
                    Datetime startDate = Datetime.newInstance(discount.Start_Date__c, Time.newInstance(0, 0, 0, 0));
                    Datetime endDate = Datetime.newInstance(discount.End_Date__c, Time.newInstance(0, 0, 0, 0));
                    if (discount.Start_Date__c == null || discount.End_Date__c == null) {
                        continue;
                    }
                    if (Datetime.now() >= startDate && Datetime.now() <= endDate) {
                        filteredDiscounts.add(discount);
                    }
                }
                //Cron activated
                when 'Recurring' {
                    String cronExpression = discount.Cron_Expression__c;
                    if (String.isBlank(cronExpression)) {
                        continue;
                    }
                    Boolean canRunNow = CronValidator.isDue(discount.Cron_Expression__c, UserInfo.getTimeZone());
                    if (canRunNow) {
                        filteredDiscounts.add(discount);
                    }
                }
                //Only if order is eligible
                when 'Conditional' {
                    //TODO: Implement condition logic evaluation
                }
            }
        }

        return filteredDiscounts;
    }
}