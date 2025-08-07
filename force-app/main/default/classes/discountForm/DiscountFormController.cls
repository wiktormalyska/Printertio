public with sharing class DiscountFormController {
    @AuraEnabled
    public static Map<String, String> getRecurringHelpTexts() {
        try {
            return DiscountFormService.getRecurringHelpTexts();
        } catch (Exception e) {
            throw new AuraHandledException(System.Label.Error_Unexpected_Text + e.getMessage());
        }
    }

    @AuraEnabled
    public static Id saveDiscount(Discount__c discount) {
        System.debug('DiscountFormController.saveDiscount called with discount: ' + discount);
        try {
            if (discount == null) {
                throw new AuraHandledException(System.Label.Error_Discount_Null_Text);
            }
            return DiscountFormService.saveDiscount(discount);
        } catch (Exception e) {
            throw new AuraHandledException(System.Label.Error_Unexpected_Text + e.getMessage());
        }
    }

    @AuraEnabled
    public static List<Map<String, String>> getConditionLogicPicklistValues() {
        List<Map<String, String>> options = new List<Map<String, String>>();

        Schema.DescribeFieldResult fieldResult = Discount__c.Condition_Logic__c.getDescribe();
        List<Schema.PicklistEntry> picklistEntries = fieldResult.getPicklistValues();

        for (Schema.PicklistEntry entry : picklistEntries) {
            if (entry.isActive()) {
                Map<String, String> option = new Map<String, String>();
                option.put('label', entry.getLabel());
                option.put('value', entry.getValue());
                options.add(option);
            }
        }

        return options;
    }
}