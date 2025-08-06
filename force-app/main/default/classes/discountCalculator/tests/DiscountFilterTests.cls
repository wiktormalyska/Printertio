@IsTest
private class DiscountFilterTests {
    @TestSetup
    static void setup() {
        List<Discount__c> discounts = new List<Discount__c>();
        Discount__c discount1 = (Discount__c) new DiscountTestDataFactory().create();
        discounts.add(discount1);
        Discount__c expiredDiscount = (Discount__c) new ExpiredDiscountDataFactory().create();
        discounts.add(expiredDiscount);
        insert discounts;
    }

    @IsTest
    static void testCalculateDiscounterAmount(){
        DiscountSettings settings = new DiscountSettings();
        List<Discount__c> discounts = [SELECT Id, Name, Value_Type__c, Discount_Value__c, Start_Date__c, End_Date__c, Discount_Type__c FROM Discount__c WHERE Is_Active__c = TRUE];
        Decimal totalAmount = 1000.0;
        Test.startTest();
        Decimal discountedAmount = DiscountFilter.calculateDiscountedAmount(discounts, settings, totalAmount);
        Test.stopTest();

        System.assertEquals(900.0, discountedAmount, 'Discounted amount should be 900.0 based on the active discount');
    }

    private class ExpiredDiscountDataFactory extends DiscountTestDataFactory {
        public override SObject create() {
            Discount__c discount = (Discount__c) super.create();
            discount.Name = 'Expired Discount';
            discount.Start_Date__c = Date.today().addDays(-10);
            discount.End_Date__c = Date.today().addDays(-5);
            return discount;
        }
    }
}