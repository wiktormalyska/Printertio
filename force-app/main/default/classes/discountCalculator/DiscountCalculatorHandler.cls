public with sharing class DiscountCalculatorHandler {

    //Triggered after insert to apply discounts
    public static void applyDiscountsWhenOrderTriggered(List<Order> orders) {
        System.debug('Applying discounts for Orders: ' + orders);

        DiscountSettings settings = new DiscountSettings();

        List<Discount__c> activeDiscounts = [
                SELECT Id, Name, Discount_Type__c, Value_Type__c, Discount_Value__c,
                        Start_Date__c, End_Date__c,
                        Condition_Logic_Field__c, Condition_Logic_Operator__c, Condition_Logic_Numeric_Value__c,
                        Recurring_Date_Start__c, Recurring_Date_End__c, Recurring_Date_Repeat_By__c
                FROM Discount__c
                WHERE Is_Active__c = TRUE
        ];
        System.debug('Active Discounts: ' + activeDiscounts);

        for (Order order : orders) {
            order.Discount__c = null;
        }

        for (Order currentOrder : orders) {
            System.debug('Processing Order: ' + currentOrder.Id + ' with Total Amount: ' + currentOrder.TotalAmount);
            List<Discount__c> filteredDiscounts = DiscountFilter.filterDiscounts(activeDiscounts, settings, currentOrder);

            System.debug('Filtered Discounts for Order ' + currentOrder.Id + ': ' + filteredDiscounts);
            if (filteredDiscounts.isEmpty()) {
                continue;
            }

            Decimal bestDiscountValue = 0;
            Discount__c bestDiscount = BestDiscountCounter.getMatchingDiscount(filteredDiscounts, settings, currentOrder);
            if (bestDiscount != null) {
                if (bestDiscount.Value_Type__c == 'Percentage') {
                    bestDiscountValue = (currentOrder.TotalAmount * bestDiscount.Discount_Value__c / 100);
                } else if (bestDiscount.Value_Type__c == 'Fixed Amount') {
                    bestDiscountValue = bestDiscount.Discount_Value__c;
                }

                currentOrder.Discount__c = bestDiscount.Id;
                currentOrder.DiscountedAmount__c = bestDiscountValue;
            }


            System.debug('Best Discount for Order ' + currentOrder.Id + ': ' + bestDiscount);
            System.debug('Best Discount Value: ' + bestDiscountValue);
        }
    }

    public static void applyDiscountsWhenDiscountTriggered() {
        List<Discount__c> activeDiscounts = [
                SELECT Id, Name, Discount_Type__c, Value_Type__c, Discount_Value__c,
                        Start_Date__c, End_Date__c,
                        Condition_Logic_Field__c, Condition_Logic_Operator__c, Condition_Logic_Numeric_Value__c,
                        Recurring_Date_Start__c, Recurring_Date_End__c, Recurring_Date_Repeat_By__c,
                        Is_Active__c
                FROM Discount__c
                WHERE Is_Active__c = TRUE
        ];

        List<Order> ordersToProcess = [
                SELECT Id, TotalAmount, Discount__c, Status
                FROM Order
                WHERE Status = 'Draft'
        ];

        DiscountSettings settings = new DiscountSettings();

        if (!ordersToProcess.isEmpty()) {
            for (Order order : ordersToProcess) {
                order.Discount__c = null;
            }

            for (Order currentOrder : ordersToProcess) {
                System.debug('Processing Order: ' + currentOrder.Id + ' with Total Amount: ' + currentOrder.TotalAmount);
                List<Discount__c> filteredDiscounts = DiscountFilter.filterDiscounts(activeDiscounts, settings, currentOrder);

                System.debug('Filtered Discounts for Order ' + currentOrder.Id + ': ' + filteredDiscounts);
                if (filteredDiscounts.isEmpty()) {
                    continue;
                }

                Decimal bestDiscountValue = 0;
                Discount__c bestDiscount = BestDiscountCounter.getMatchingDiscount(filteredDiscounts, settings, currentOrder);
                if (bestDiscount != null) {
                    if (bestDiscount.Value_Type__c == 'Percentage') {
                        bestDiscountValue = (currentOrder.TotalAmount * bestDiscount.Discount_Value__c / 100);
                    } else if (bestDiscount.Value_Type__c == 'Fixed Amount') {
                        bestDiscountValue = bestDiscount.Discount_Value__c;
                    }

                    currentOrder.Discount__c = bestDiscount.Id;
                    currentOrder.DiscountedAmount__c = bestDiscountValue;
                }

                System.debug('Best Discount for Order ' + currentOrder.Id + ': ' + bestDiscount);
                System.debug('Best Discount Value: ' + bestDiscountValue);
            }
            update ordersToProcess;
        }
    }
}