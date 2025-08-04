@IsTest
public with sharing class BestDiscountCounterTests {
    @TestSetup
    static void setup() {
        List<Discount__c> discounts = new List<Discount__c>();
        discounts.add(new Discount__c(
                Name = 'Test Discount 1',
                Discount_Type__c = 'Time-Bound',
                Value_Type__c = 'Percentage',
                Discount_Value__c = 10,
                Start_Date__c = System.today().addDays(-1),
                End_Date__c = System.today().addDays(1),
                Is_Active__c = true
        ));
        discounts.add(new Discount__c(
                Name = 'Test Discount 2',
                Discount_Type__c = 'Time-Bound',
                Value_Type__c = 'Amount',
                Discount_Value__c = 50,
                Start_Date__c = System.today().addDays(-1),
                End_Date__c = System.today().addDays(1),
                Is_Active__c = true
        ));
        insert discounts;

        Product2 product1 = new Product2(
                Name = 'Test Product 1',
                IsActive = true,
                ProductCode = 'TP1',
                Description = 'Test Product 1 Description'
        );
        insert product1;

        Id priceBookId = Test.getStandardPricebookId();

        PricebookEntry pbe1 = new PricebookEntry(
                Pricebook2Id = priceBookId,
                Product2Id = product1.Id,
                UnitPrice = 100.0,
                IsActive = true
        );
        insert pbe1;
        Account account = new Account(
                Name = 'Test Account'
        );
        insert account;

        Order order = new Order(
                AccountId = account.Id,
                EffectiveDate = System.today(),
                Pricebook2Id = priceBookId,
                Status = 'Draft'
        );
        insert order;

        OrderItem orderItem = new OrderItem(
                OrderId = order.Id,
                PricebookEntryId = pbe1.Id,
                Quantity = 10,
                UnitPrice = 100.0
        );
        insert orderItem;
    }

    @IsTest
    static void testGetMatchingDiscountWithPercentage() {
        List<Discount__c> discounts = [SELECT Id, Name, Discount_Type__c, Value_Type__c, Discount_Value__c FROM Discount__c WHERE Is_Active__c = TRUE];
        Order order = [SELECT Id, TotalAmount FROM Order WHERE Status = 'Draft' LIMIT 1];
        DiscountSettings settings = new DiscountSettings('Highest', 50.0);

        Test.startTest();
        Discount__c bestDiscount = BestDiscountCounter.getMatchingDiscount(discounts, settings, order);
        Test.stopTest();

        System.assertNotEquals(null, bestDiscount, 'Best discount should not be null');
        System.assertEquals('Test Discount 1', bestDiscount.Name, 'Best discount should be the one with the highest percentage');
    }
}