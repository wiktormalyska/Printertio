public with sharing class ConditionLogicValidator {
    public static Boolean filterDiscountsByConditionLogic(Discount__c discount, Order order){
        String operator = discount.Condition_Logic_Operator__c;
        String objectNameWithFieldName = discount.Condition_Logic_Field__c;
        Decimal numericValue = discount.Condition_Logic_Numeric_Value__c;
        Decimal fieldNameValue = 0;
        System.debug('Condition Logic: '+ objectNameWithFieldName + ' ' + operator + ' ' + numericValue);
        switch on objectNameWithFieldName {
            when 'Order.Products_Amount' {
                fieldNameValue = order.OrderItems.size();
            }
            when 'Order.Products_Total_Price' {
                Decimal totalPrice = 0;
                for (OrderItem item : order.OrderItems) {
                    totalPrice += item.UnitPrice * item.Quantity;
                }
                fieldNameValue = totalPrice;
            }
        }
        System.debug('Field Name Value: ' + fieldNameValue);

        switch on operator {
            when '>' {
                if (fieldNameValue > numericValue) {
                    return true;
                }
            }
            when '==' {
                if (fieldNameValue == numericValue) {
                    return true;
                }
            }
            when '<' {
                if (fieldNameValue < numericValue) {
                    return true;
                }
            }
            when '<=' {
                if (fieldNameValue <= numericValue) {
                    return true;
                }
            }
            when '>=' {
                if (fieldNameValue >= numericValue) {
                    return true;
                }
            }
            when '!=' {
                if (fieldNameValue != numericValue) {
                    return true;
                }
            }
        }
        return false;
    }
}