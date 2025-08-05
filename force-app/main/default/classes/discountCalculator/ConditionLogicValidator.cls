public with sharing class ConditionLogicValidator {
    public static Boolean filterDiscountsByConditionLogic(Discount__c discount, Order order) {
        String operator = discount.Condition_Logic_Operator__c;
        String fieldApiName = discount.Condition_Logic_Field__c;
        Decimal numericValue = discount.Condition_Logic_Numeric_Value__c;

        IFieldValidator validator = FieldValidatorFactory.getValidator(fieldApiName);
        if (validator == null) {
            return false;
        }

        Decimal fieldValue = validator.getFieldValue(order);
        return evaluateCondition(fieldValue, operator, numericValue);
    }

    private static Boolean evaluateCondition(Decimal fieldValue, String operator, Decimal numericValue) {
        switch on operator {
            when '>' { return fieldValue > numericValue; }
            when '==' { return fieldValue == numericValue; }
            when '<' { return fieldValue < numericValue; }
            when '<=' { return fieldValue <= numericValue; }
            when '>=' { return fieldValue >= numericValue; }
            when '!=' { return fieldValue != numericValue; }
            when else { return false; }
        }
    }
}