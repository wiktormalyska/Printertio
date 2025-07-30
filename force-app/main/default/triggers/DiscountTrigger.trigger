trigger DiscountTrigger on Discount__c (before update) {
    Map<Id, Discount__c> oldDiscountsMap = (Map<Id, Discount__c>) Trigger.oldMap;
    for (Discount__c newDiscount : Trigger.new) {
        Discount__c oldDiscount = oldDiscountsMap.get(newDiscount.Id);

        if (oldDiscount.Times_Used__c != null && oldDiscount.Times_Used__c > 0) {
            Boolean onlyIsActiveChanged = (newDiscount.Is_Active__c != oldDiscount.Is_Active__c);
            if (newDiscount.Name != oldDiscount.Name ||
                    newDiscount.Discount_Type__c != oldDiscount.Discount_Type__c ||
                    newDiscount.Value_Type__c != oldDiscount.Value_Type__c ||
                    newDiscount.Discount_Value__c != oldDiscount.Discount_Value__c) {
                if (onlyIsActiveChanged == false) {
                    newDiscount.addError('Nie można edytować tej zniżki, ponieważ została już użyta. Możesz ją jedynie dezaktywować.');
                }
            }
        }
    }
}