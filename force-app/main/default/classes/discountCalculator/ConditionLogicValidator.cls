public with sharing class ConditionLogicValidator {
    public static Boolean filterDiscountsByConditionLogic(Discount__c discount, Order order) {
        String selectedApiName = discount.Condition_Logic__c;

        ICondition condition;
        try {
            Type conditionType = Type.forName(selectedApiName);

            Object conditionInstance = conditionType.newInstance();
            condition = (ICondition) conditionInstance;
        } catch (Exception e) {
            return false;
        }

        if (condition == null) {
            return false;
        }

        return condition.isApplicable(order);
    }
}