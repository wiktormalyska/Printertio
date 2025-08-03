trigger OrderTrigger on Order (before insert, before update, before delete, after insert, after update, after delete) {
    if (Trigger.isBefore && Trigger.old != null && Trigger.new != null) {
        List<Order> ordersToProcess = new List<Order>();

        for (Integer i = 0; i < Trigger.new.size(); i++) {
            Order newOrder = Trigger.new[i];
            Order oldOrder = Trigger.old[i];
            if (newOrder.TotalAmount != oldOrder.TotalAmount || newOrder.Discount__c != oldOrder.Discount__c) {
                ordersToProcess.add(newOrder);
            }
        }
        if (!ordersToProcess.isEmpty()) {
            System.debug('Processing orders for discount calculation: ' + ordersToProcess);
            DiscountCalculatorHandler.applyDiscountsWhenOrderTriggered(ordersToProcess);
        }
    }
}