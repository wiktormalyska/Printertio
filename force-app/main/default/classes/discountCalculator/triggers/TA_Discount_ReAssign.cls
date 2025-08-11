public class TA_Discount_ReAssign implements TriggerAction.AfterDelete, TriggerAction.AfterInsert, TriggerAction.AfterUpdate {
    public void afterDelete(List<SObject> triggerOld) {
        if (!triggerOld.isEmpty()) {
            DiscountCalculatorHandler.applyDiscountsWhenDiscountTriggered();
        }
    }

    public void afterInsert(List<Discount__c> triggerNew) {
        if (!triggerNew.isEmpty()) {
            DiscountCalculatorHandler.applyDiscountsWhenDiscountTriggered();
        }
    }

    public void afterUpdate(List<Discount__c> triggerNew, List<Discount__c> triggerOld) {
        if (!triggerNew.isEmpty()) {
            DiscountCalculatorHandler.applyDiscountsWhenDiscountTriggered();
        }
    }
}