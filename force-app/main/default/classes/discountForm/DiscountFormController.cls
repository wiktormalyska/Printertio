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
        try {
            if (discount == null) {
                throw new AuraHandledException(System.Label.Error_Discount_Null_Text);
            }
            return DiscountFormService.saveDiscount(discount);
        } catch (Exception e) {
            throw new AuraHandledException(System.Label.Error_Unexpected_Text + e.getMessage());
        }
    }
}