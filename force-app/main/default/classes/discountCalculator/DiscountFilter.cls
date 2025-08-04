public with sharing class DiscountFilter {
    public static List<Discount__c> filterDiscounts(List<Discount__c> discounts, DiscountSettings settings, Order order) {
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

    public static Decimal calculateDiscountedAmount(List<Discount__c> discounts,DiscountSettings settings, Decimal totalAmount) {
        List<Discount__c> filteredDiscounts = new List<Discount__c>();

        for (Discount__c discount : discounts) {
            System.debug('Applying Discount: ' + discount.Name + ' of type ' + discount.Discount_Type__c);
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
                    //TODO: Swap logiki
                }
            }
        }
        Decimal bestDiscountValue = 0;
        Discount__c bestDiscount = BestDiscountCounter.getMatchingDiscountBasedOnTotalAmount(filteredDiscounts, settings, totalAmount);
        if (bestDiscount != null) {
            if (bestDiscount.Value_Type__c == 'Percentage') {
                bestDiscountValue = (totalAmount * bestDiscount.Discount_Value__c / 100);
            } else if (bestDiscount.Value_Type__c == 'Fixed Amount') {
                bestDiscountValue = bestDiscount.Discount_Value__c;
            }
        }

        return totalAmount - bestDiscountValue;
    }
}