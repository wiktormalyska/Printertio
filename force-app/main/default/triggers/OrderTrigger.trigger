trigger OrderTrigger on Order (before insert, before update, before delete, after insert, after update, after delete) {
    if (Trigger.isUpdate && Trigger.isBefore) {
        Set<Id> orderIds = Trigger.newMap.keySet();

        Map<Id, Order> ordersWithDiscountsMap = new Map<Id, Order>([
                SELECT Id, TotalAmount, (SELECT Id, Amount_Discounted__c, Discount__c FROM Applied_Discounts__r)
                FROM Order
                WHERE Id IN :orderIds
        ]);
// TotalAmount rollup is updated before this
        for (Order newOrder : Trigger.new) {
            Order oldOrder = Trigger.oldMap.get(newOrder.Id);
            Order orderFromQuery = ordersWithDiscountsMap.get(newOrder.Id);

            if (oldOrder.TotalAmount != newOrder.TotalAmount &&
                    orderFromQuery.Applied_Discounts__r != null &&
                    !orderFromQuery.Applied_Discounts__r.isEmpty()) {

                System.debug('order val after update: ' + newOrder.TotalAmount);
                Applied_Discount__c appliedDiscount = orderFromQuery.Applied_Discounts__r[0];

                Discount__c discount = [
                        SELECT Id, Value_Type__c, Discount_Value__c
                        FROM Discount__c
                        WHERE Id = :appliedDiscount.Discount__c
                        LIMIT 1
                ];

                Decimal discountValue = 0;

                if (discount.Value_Type__c == 'Percentage') {
                    discountValue = (newOrder.TotalAmount * discount.Discount_Value__c / 100);
                } else if (discount.Value_Type__c == 'Fixed Amount') {
                    discountValue = discount.Discount_Value__c;
                }

                newOrder.Order_Amount_After_Discount__c = newOrder.TotalAmount - discountValue;

                appliedDiscount.Amount_Discounted__c  = discountValue;
                update appliedDiscount;

            } else {
                newOrder.Order_Amount_After_Discount__c = newOrder.TotalAmount;
            }
        }
    } else {
        System.debug('order val before update: ' + Trigger.old.get(0).TotalAmount + ' -> ' + Trigger.new.get(0).TotalAmount);
    }

}