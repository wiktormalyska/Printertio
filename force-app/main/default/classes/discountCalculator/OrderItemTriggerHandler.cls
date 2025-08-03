public with sharing class OrderItemTriggerHandler {

    public void run() {
        List<OrderItem> itemsToProcess = new List<OrderItem>();

        if (Trigger.isInsert || Trigger.isUpdate || Trigger.isUndelete) {
            itemsToProcess.addAll((List<OrderItem>) Trigger.new);
        } else if (Trigger.isDelete) {
            itemsToProcess.addAll((List<OrderItem>) Trigger.old);
        }

        if (!itemsToProcess.isEmpty()) {
            DiscountCalculatorHandler.applyDiscounts(itemsToProcess);
        }
    }
}