public with sharing class DiscountCalculatorHandler {

    //Triggered after insert to apply discounts
    public static void applyDiscounts(List<OrderItem> orderItems) {
        System.debug('Applying discounts for Order with Items: ' + orderItems);

        Set<Id> orderIds = new Set<Id>();
        for (OrderItem item : orderItems) {
            orderIds.add(item.OrderId);
        }

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

        Map<Id, Order> ordersMap = new Map<Id, Order>([
                SELECT Id, TotalAmount,
                (SELECT Id, UnitPrice, Quantity FROM OrderItems),
                (SELECT Id FROM Applied_Discounts__r)
                FROM Order
                WHERE Id IN :orderIds
                FOR UPDATE
        ]);

        List<Applied_Discount__c> existingDiscounts = new List<Applied_Discount__c>();
        for (Order order : ordersMap.values()) {
            existingDiscounts.addAll(order.Applied_Discounts__r);
        }
        if (!existingDiscounts.isEmpty()) {
            delete existingDiscounts;
        }

//        List<Order> ordersToUpdate = new List<Order>();
        List<Applied_Discount__c> discountsToInsert = new List<Applied_Discount__c>();

        for (Order currentOrder : ordersMap.values()) {
            System.debug('Processing Order: ' + currentOrder.Id + ' with Total Amount: ' + currentOrder.TotalAmount);
            List<Discount__c> filteredDiscounts = DiscountFilter.filterDiscounts(activeDiscounts, settings,currentOrder);

            System.debug('Filtered Discounts for Order ' + currentOrder.Id + ': ' + filteredDiscounts);
            if (filteredDiscounts.isEmpty()) {
                continue;
            }

            Decimal bestDiscountValue = 0;
            Discount__c bestDiscount = null;

            for (Discount__c discount : filteredDiscounts) {
                Decimal discountValue = 0;
                if (discount.Value_Type__c == 'Percentage') {
                    discountValue = (currentOrder.TotalAmount * discount.Discount_Value__c / 100);
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

            System.debug('Best Discount for Order ' + currentOrder.Id + ': ' + bestDiscount);
            System.debug('Best Discount Value: ' + bestDiscountValue);
            if (bestDiscount != null) {
                System.debug('Adding Applied Discount for Order ' + currentOrder.Id + ': ' + bestDiscount.Name);

                discountsToInsert.add(new Applied_Discount__c(
                        Order__c = currentOrder.Id,
                        Discount__c = bestDiscount.Id,
                        Amount_Discounted__c = bestDiscountValue,
                        Name = bestDiscount.Name
                ));
                System.debug('Applied Discount: ' + bestDiscount.Name + ' with Amount: ' + bestDiscountValue);
            }
        }

        if (!discountsToInsert.isEmpty()) {
            System.debug('Inserting Applied Discounts: ' + discountsToInsert);
            insert discountsToInsert;
        }
    }
}