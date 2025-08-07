public with sharing class DiscountFilter {
    public static List<Discount__c> filterDiscounts(List<Discount__c> discounts, DiscountSettings settings, Order order) {
        List<Discount__c> filteredDiscounts = new List<Discount__c>();

        for (Discount__c discount : discounts) {
            if (discount.Discount_Type__c == ConstUtil.DISCOUNT_TYPE_TIME_BOUND) {
                //From date to date
                if (TimeBoundValidator.isValidTimeBoundDiscount(discount)) {
                    filteredDiscounts.add(discount);
                }
            }
            if (discount.Discount_Type__c == ConstUtil.DISCOUNT_TYPE_RECURRING) {
                //Cron activated
                if (RecurringDateValidator.isRecurringDateValidForToday(discount)) {
                    filteredDiscounts.add(discount);
                }
            }
            //Only if order is eligible
            if (discount.Discount_Type__c == ConstUtil.DISCOUNT_TYPE_CONDITIONAL) {
                order = [SELECT Id, TotalAmount, (SELECT Id, UnitPrice, Quantity FROM OrderItems) FROM Order WHERE Id = :order.Id];
                if (ConditionLogicValidator.filterDiscountsByConditionLogic(discount, order)) {
                    filteredDiscounts.add(discount);
                }
            }
        }
        return filteredDiscounts;
    }

    public static Decimal calculateDiscountedAmount(List<Discount__c> discounts, DiscountSettings settings, Decimal totalAmount) {
        List<Discount__c> filteredDiscounts = new List<Discount__c>();

        for (Discount__c discount : discounts) {
            if (discount.Discount_Type__c == ConstUtil.DISCOUNT_TYPE_TIME_BOUND) {
                //From date to date
                if (TimeBoundValidator.isValidTimeBoundDiscount(discount)) {
                    filteredDiscounts.add(discount);
                }
            }
            if (discount.Discount_Type__c == ConstUtil.DISCOUNT_TYPE_RECURRING) {
                //Cron activated
                if (RecurringDateValidator.isRecurringDateValidForToday(discount)) {
                    filteredDiscounts.add(discount);
                }
            }
            //Only if order is eligible
            if (discount.Discount_Type__c == ConstUtil.DISCOUNT_TYPE_CONDITIONAL) {

            }
        }
        Decimal bestDiscountValue = 0;
        Discount__c bestDiscount = BestDiscountCounter.getMatchingDiscountBasedOnTotalAmount(filteredDiscounts, settings, totalAmount);
        if (bestDiscount != null) {
            if (bestDiscount.Value_Type__c ==  ConstUtil.DISCOUNT_VALUE_TYPE_PERCENTAGE) {
                bestDiscountValue = (totalAmount * bestDiscount.Discount_Value__c / 100);
            } else if (bestDiscount.Value_Type__c == ConstUtil.DISCOUNT_VALUE_TYPE_FIXED_AMOUNT) {
                bestDiscountValue = bestDiscount.Discount_Value__c;
            }
        }

        return totalAmount - bestDiscountValue;
    }
}