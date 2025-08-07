public class TA_Discount_ReAssign_AfterInsert implements TriggerAction.AfterInsert {
    public void afterInsert(List<Discount__c> triggerNew) {
        if (!triggerNew.isEmpty()) {
            DiscountCalculatorHandler.applyDiscountsWhenDiscountTriggered();
        }
    }
}