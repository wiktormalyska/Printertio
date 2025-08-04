public with sharing class DiscountFormController {
    @AuraEnabled
    public static Map<String, String> getRecurringHelpTexts() {
        Map<String, String> helpTexts = new Map<String, String>();

        helpTexts.put('Daily', ConstUtil.RECURRING_HELP_TIME_OF_DAY);
        helpTexts.put('Weekly', ConstUtil.RECURRING_HELP_DAY_OF_WEEK);
        helpTexts.put('Monthly', ConstUtil.RECURRING_HELP_MONTH);
        helpTexts.put('Yearly', ConstUtil.RECURRING_HELP_YEAR);

        return helpTexts;
    }
}