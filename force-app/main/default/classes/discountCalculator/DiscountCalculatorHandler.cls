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
                        Start_Date__c, End_Date__c,
                        Condition_Logic_Field__c, Condition_Logic_Operator__c, Condition_Logic_Numeric_Value__c,
                        Recurring_Date_Start__c, Recurring_Date_End__c, Recurring_Date_Repeat_By__c
                FROM Discount__c
                WHERE Is_Active__c = TRUE
        ];
        for (Order order : insertedOrders) {
            List<Applied_Discount__c> existingDiscounts = [
                    SELECT Id FROM Applied_Discount__c WHERE Order__c = :order.Id
            ];
            if (!existingDiscounts.isEmpty()) {
                delete existingDiscounts;
            }

            List<Discount__c> filteredDiscounts = filterDiscounts(activeDiscounts, settings, order);
            System.debug('Filtered Discounts: ' + filteredDiscounts);
            if (filteredDiscounts.isEmpty()) {
                return;
            }
            Decimal bestDiscountValue = 0;
            Discount__c bestDiscount = null;
            for (Discount__c discount : filteredDiscounts) {
                Decimal discountValue = 0;
                if (discount.Value_Type__c == 'Percentage') {
                    discountValue = (order.TotalAmount * discount.Discount_Value__c/100);
                } else if (discount.Value_Type__c == 'Fixed Amount') {
                    discountValue = discount.Discount_Value__c;
                }

                if (settings.strategy == 'Highest' && discountValue > bestDiscountValue) {
                    bestDiscountValue = discountValue;
                    bestDiscount = discount;
                } else if (settings.strategy == 'Lowest' && (bestDiscount == null || discountValue < bestDiscountValue)) {
                    bestDiscountValue = discountValue;
                    bestDiscount = discount;
                }
            }
            System.debug('Best Discount Value: ' + bestDiscountValue);
            System.debug('Best Discount: ' + bestDiscount);

            Applied_Discount__c appliedDiscount = new Applied_Discount__c(
                Order__c = order.Id,
                Discount__c = bestDiscount != null ? bestDiscount.Id : null,
                Amount_Discounted__c = bestDiscountValue,
                Name = bestDiscount != null ? bestDiscount.Name : 'No Discount Applied'
            );
            insert appliedDiscount;
            System.debug('Applied Discount: ' + appliedDiscount);
        }
    }

    private static List<Discount__c> filterDiscounts(List<Discount__c> discounts, DiscountSettings settings, Order order) {
        List<Discount__c> filteredDiscounts = new List<Discount__c>();

        for (Discount__c discount : discounts) {
            System.debug('Evaluating Discount: ' + discount.Name + ' of type ' + discount.Discount_Type__c);
            switch on discount.Discount_Type__c {
                //From date to date
                when 'Time-Bound' {
                    if (TimeBoundValidator.isValidTimeBoundDiscount(discount)) {
                        filteredDiscounts.add(discount);
                    }
                }
                //Cron activated
                when 'Recurring' {
                    if (RecurringDateValidator.isRecurringDateValidForToday(discount)) {
                        filteredDiscounts.add(discount);
                    }
                }
                //Only if order is eligible
                when 'Conditional' {
                    order = [SELECT Id, TotalAmount, (SELECT Id, UnitPrice, Quantity FROM OrderItems) FROM Order WHERE Id = :order.Id];
                    if (ConditionLogicValidator.filterDiscountsByConditionLogic(discount, order)) {
                        filteredDiscounts.add(discount);
                    }
                }
            }
        }

        return filteredDiscounts;
    }
}