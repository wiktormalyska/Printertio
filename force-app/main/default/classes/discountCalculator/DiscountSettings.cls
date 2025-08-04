public with sharing class DiscountSettings {
    public String strategy;
    public Decimal maxDiscountPercent;

    public DiscountSettings() {
        List<Discount_Settings__mdt> settingsList = [
                SELECT Discount_Strategy__c, Max_Overall_Discount_Percentage__c
                FROM Discount_Settings__mdt
                LIMIT 1
        ];
        if (!settingsList.isEmpty()) {
            Discount_Settings__mdt settings = settingsList[0];
            this.strategy = settings.Discount_Strategy__c;
            this.maxDiscountPercent = settings.Max_Overall_Discount_Percentage__c;
        } else {
            this.strategy = 'Highest';
            this.maxDiscountPercent = 50.0;
        }
    }

    public DiscountSettings(String strategy, Decimal maxDiscountPercent) {
        this.strategy = strategy;
        this.maxDiscountPercent = maxDiscountPercent;
    }
}