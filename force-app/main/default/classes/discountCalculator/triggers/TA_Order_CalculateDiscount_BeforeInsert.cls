public with sharing class TA_Order_CalculateDiscount_BeforeInsert implements TriggerAction.BeforeInsert {
    public void beforeInsert(List<SObject> triggerNew) {
        if(!triggerNew.isEmpty()) {
            DiscountCalculatorHandler.applyDiscountsWhenOrderTriggered(triggerNew);
        }
    }
}