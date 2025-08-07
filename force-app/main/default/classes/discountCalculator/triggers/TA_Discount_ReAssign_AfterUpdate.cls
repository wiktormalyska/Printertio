public class TA_Discount_ReAssign_AfterUpdate implements TriggerAction.AfterUpdate {
    public void afterUpdate(List<Discount__c> triggerNew, List<Discount__c> triggerOld) {
        if (!triggerNew.isEmpty()) {
            DiscountCalculatorHandler.applyDiscountsWhenDiscountTriggered();
        }
    }
}