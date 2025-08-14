public class TA_Order_CalculateDiscount implements TriggerAction.BeforeInsert, TriggerAction.BeforeUpdate {
    public void beforeInsert(List<SObject> triggerNew) {
        if(!triggerNew.isEmpty()) {
            DiscountCalculatorHandler.applyDiscountsWhenOrderTriggered(triggerNew);
        }
    }

    public void beforeUpdate(List<Order> triggerNew, List<Order> triggerOld) {
        List<Order> ordersToUpdate = new List<Order>();
        Map<Id, Order> oldOrdersMap = new Map<Id, Order>(triggerOld);

        for (Order newOrder : triggerNew) {
            Order oldOrder = oldOrdersMap.get(newOrder.Id);
            if (newOrder.TotalAmount!=oldOrder.TotalAmount || newOrder.Discount__c != oldOrder.Discount__c) {
                ordersToUpdate.add(newOrder);
            }
        }

        if (!ordersToUpdate.isEmpty()) {
            DiscountCalculatorHandler.applyDiscountsWhenOrderTriggered(ordersToUpdate);
        }
    }
}