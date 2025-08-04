public with sharing class TimeBoundValidator {
    public static Boolean isValidTimeBoundDiscount(Discount__c discount) {
        if (discount.Start_Date__c == null || discount.End_Date__c == null) {
            return false;
        }

        Datetime startDate = Datetime.newInstance(discount.Start_Date__c, Time.newInstance(0, 0, 0, 0));
        Datetime endDate = Datetime.newInstance(discount.End_Date__c, Time.newInstance(0, 0, 0, 0));

        if (startDate >= endDate) {
            return false;
        }

        if (Datetime.now() >= startDate && Datetime.now() <= endDate) {
            return true;
        }
        return false;
    }
}