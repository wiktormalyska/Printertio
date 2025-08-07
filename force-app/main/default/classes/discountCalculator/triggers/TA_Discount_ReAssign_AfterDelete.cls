public class TA_Discount_ReAssign_AfterDelete implements TriggerAction.AfterDelete {
    public void afterDelete(List<SObject> triggerOld) {
        if (!triggerOld.isEmpty()) {
            DiscountCalculatorHandler.applyDiscountsWhenDiscountTriggered();
        }
    }
}