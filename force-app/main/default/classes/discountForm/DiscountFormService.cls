public with sharing class DiscountFormService {
    public static Map<String, String> getRecurringHelpTexts() {
        Map<String, String> helpTexts = new Map<String, String>();

        helpTexts.put(ConstUtil.DISCOUNT.RECURRING_TYPE.REPEAT.DAILY, ConstUtil.DISCOUNT.RECURRING_TYPE.HELP_TEXTS.DAILY);
        helpTexts.put(ConstUtil.DISCOUNT.RECURRING_TYPE.REPEAT.WEEKLY, ConstUtil.DISCOUNT.RECURRING_TYPE.HELP_TEXTS.WEEKLY);
        helpTexts.put(ConstUtil.DISCOUNT.RECURRING_TYPE.REPEAT.MONTHLY, ConstUtil.DISCOUNT.RECURRING_TYPE.HELP_TEXTS.MONTHLY);
        helpTexts.put(ConstUtil.DISCOUNT.RECURRING_TYPE.REPEAT.YEARLY, ConstUtil.DISCOUNT.RECURRING_TYPE.HELP_TEXTS.YEARLY);

        return helpTexts;
    }

    public static Id saveDiscount(Discount__c discount) {
        insert discount;
        return discount.Id;
    }
}