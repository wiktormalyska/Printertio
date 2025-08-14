public with sharing class DiscountCalculatorHandler {

    //Triggered after insert to apply discounts
    public static void applyDiscountsWhenOrderTriggered(List<Order> orders) {
        DiscountSettings settings = new DiscountSettings();
        List<Discount__c> activeDiscounts = [
                SELECT Id, Name, Discount_Type__c, Value_Type__c, Discount_Value__c,
                        Start_Date__c, End_Date__c,
                        Condition_Logic__c,
                        Recurring_Date_Start__c, Recurring_Date_End__c, Recurring_Date_Repeat_By__c
                FROM Discount__c
                WHERE Is_Active__c = TRUE
        ];

        for (Order order : orders) {
            order.Discount__c = null;
        }

        for (Order currentOrder : orders) {
            List<Discount__c> filteredDiscounts = DiscountFilter.filterDiscounts(activeDiscounts, settings, currentOrder);
            if (filteredDiscounts.isEmpty()) {
                continue;
            }

            Decimal bestDiscountValue = 0;
            Discount__c bestDiscount = BestDiscountCounter.getMatchingDiscount(filteredDiscounts, settings, currentOrder);
            if (bestDiscount != null) {
                if (bestDiscount.Value_Type__c == ConstUtil.DISCOUNT.VALUE.TYPE.PERCENTAGE) {
                    bestDiscountValue = (currentOrder.TotalAmount * bestDiscount.Discount_Value__c / 100);
                } else if (bestDiscount.Value_Type__c == ConstUtil.DISCOUNT.VALUE.TYPE.FIXED_AMOUNT) {
                    bestDiscountValue = bestDiscount.Discount_Value__c;
                }

                currentOrder.Discount__c = bestDiscount.Id;
                currentOrder.DiscountedAmount__c = bestDiscountValue;
            }
        }
    }

    public static void applyDiscountsWhenDiscountTriggered() {
        List<Discount__c> activeDiscounts = [
                SELECT Id, Name, Discount_Type__c, Value_Type__c, Discount_Value__c,
                        Start_Date__c, End_Date__c,
                        Condition_Logic__c,
                        Recurring_Date_Start__c, Recurring_Date_End__c, Recurring_Date_Repeat_By__c,
                        Is_Active__c
                FROM Discount__c
                WHERE Is_Active__c = TRUE
        ];

        List<Order> ordersToProcess = [
                SELECT Id, TotalAmount, Discount__c, Status
                FROM Order
                WHERE Status = :ConstUtil.ORDER.STATUS.DRAFT
        ];

        DiscountSettings settings = new DiscountSettings();

        if (!ordersToProcess.isEmpty()) {
            for (Order order : ordersToProcess) {
                order.Discount__c = null;
            }

            for (Order currentOrder : ordersToProcess) {
                List<Discount__c> filteredDiscounts = DiscountFilter.filterDiscounts(activeDiscounts, settings, currentOrder);
                if (filteredDiscounts.isEmpty()) {
                    continue;
                }

                Decimal bestDiscountValue = 0;
                Discount__c bestDiscount = BestDiscountCounter.getMatchingDiscount(filteredDiscounts, settings, currentOrder);
                if (bestDiscount != null) {
                    if (bestDiscount.Value_Type__c == ConstUtil.DISCOUNT.VALUE.TYPE.PERCENTAGE) {
                        bestDiscountValue = (currentOrder.TotalAmount * bestDiscount.Discount_Value__c / 100);
                    } else if (bestDiscount.Value_Type__c == ConstUtil.DISCOUNT.VALUE.TYPE.FIXED_AMOUNT) {
                        bestDiscountValue = bestDiscount.Discount_Value__c;
                    }

                    currentOrder.Discount__c = bestDiscount.Id;
                    currentOrder.DiscountedAmount__c = bestDiscountValue;
                }
            }
            update ordersToProcess;
        }
    }
}