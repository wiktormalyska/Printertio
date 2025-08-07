public with sharing class ProductSearchService {
    public static List<Product2> getProducts(String searchTerm, String family) {
        if (String.isNotBlank(searchTerm) && String.isNotBlank(family)) {
            return [
                    SELECT Id, Name, Family, ProductCode, (SELECT Id, UnitPrice
                        FROM PricebookEntries
                        WHERE IsActive = TRUE
                        AND Pricebook2.IsStandard = TRUE
                    )
                    FROM Product2
                    WHERE (Name LIKE :('%' + searchTerm + '%') OR ProductCode LIKE :('%' + searchTerm + '%'))
                    AND Family = :family
            ];
        } else if (String.isNotBlank(searchTerm)) {
            return [
                    SELECT Id, Name, Family, ProductCode, (SELECT Id, UnitPrice
                    FROM PricebookEntries
                    WHERE IsActive = TRUE
                    AND Pricebook2.IsStandard = TRUE
                    )
                    FROM Product2
                    WHERE Name LIKE :('%' + searchTerm + '%') OR ProductCode LIKE :('%' + searchTerm + '%')
            ];
        } else if (String.isNotBlank(family)) {
            return [
                    SELECT Id, Name, Family, ProductCode, (SELECT Id, UnitPrice
                    FROM PricebookEntries
                    WHERE IsActive = TRUE
                    AND Pricebook2.IsStandard = TRUE
                    )
                    FROM Product2
                    WHERE Family = :family
            ];
        } else {
            return [
                    SELECT Id, Name, Family, ProductCode, (SELECT Id, UnitPrice
                    FROM PricebookEntries
                    WHERE IsActive = TRUE
                    AND Pricebook2.IsStandard = TRUE
                    )
                    FROM Product2
            ];
        }
    }

    public static List<String> getProductFamilies() {
        List<String> families = new List<String>();
        for (AggregateResult result : [
                SELECT Family
                FROM Product2
                WHERE Family != NULL
                GROUP BY Family
                ORDER BY Family
        ]) {
            families.add((String) result.get('Family'));
        }
        return families;
    }

    public static Decimal getProductsTotalAmount(List<ProductWrapper> products) {
        if (products == null || products.isEmpty()) {
            return 0;
        }

        Decimal totalAmount = 0;

        // Get standard pricebook ID
        Id standardPricebookId;
        try {
            standardPricebookId = [SELECT Id FROM Pricebook2 WHERE IsStandard = TRUE LIMIT 1].Id;
        } catch (Exception e) {
            return 0;
        }

        // Collect all product IDs
        Set<Id> productIds = new Set<Id>();
        for (ProductWrapper pw : products) {
            if (pw.id != null) {
                productIds.add(pw.id);
            }
        }

        if (productIds.isEmpty()) {
            return 0;
        }

        // Get all pricebook entries in one query
        Map<Id, PricebookEntry> pricebookEntries = new Map<Id, PricebookEntry>();
        for (PricebookEntry pbe : [
                SELECT Id, Product2Id, UnitPrice
                FROM PricebookEntry
                WHERE Product2Id IN :productIds
                AND Pricebook2Id = :standardPricebookId
                AND IsActive = TRUE
        ]) {
            pricebookEntries.put(pbe.Product2Id, pbe);
        }

        // Calculate total
        for (ProductWrapper pw : products) {
            if (pw.id != null && pw.quantity != null && pw.quantity > 0) {
                PricebookEntry pbe = pricebookEntries.get(pw.id);
                if (pbe != null && pbe.UnitPrice != null) {
                    totalAmount += pbe.UnitPrice * pw.quantity;
                }
            }
        }

        return totalAmount;
    }

    public class ProductWrapper {
        @AuraEnabled public Id id {get; set;}
        @AuraEnabled public Integer quantity {get; set;}
    }

    public static String createOrderForOpportunity(Id opportunityId, List<ProductWrapper> products) {
        if (opportunityId == null || products == null || products.isEmpty()) {
            throw new AuraHandledException('Opportunity ID and product list cannot be null or empty.');
        }

        Id accountId = [SELECT AccountId FROM Opportunity WHERE Id = :opportunityId].AccountId;
        Savepoint sp = Database.setSavepoint();

        try {
            Id standardPricebookId = [SELECT Id FROM Pricebook2 WHERE IsStandard = TRUE LIMIT 1].Id;

            Contract contract = new Contract(
                    AccountId = accountId,
                    Status = 'Draft',
                    StartDate = System.today(),
                    ContractTerm = 3
            );
            insert contract;

            Order order = new Order(
                    AccountId = accountId,
                    EffectiveDate = System.today(),
                    ContractId = contract.Id,
                    Pricebook2Id = standardPricebookId,
                    Status = 'Draft'
            );
            insert order;

            Set<Id> productIds = new Set<Id>();
            for (ProductWrapper pw : products) {
                productIds.add(pw.id);
            }

            Map<Id, PricebookEntry> pricebookEntries = new Map<Id, PricebookEntry>();
            for (PricebookEntry pbe : [
                    SELECT Id, Product2Id, UnitPrice
                    FROM PricebookEntry
                    WHERE Product2Id IN :productIds
                    AND Pricebook2Id = :standardPricebookId
                    AND IsActive = TRUE
            ]) {
                pricebookEntries.put(pbe.Product2Id, pbe);
            }

            List<OrderItem> orderItems = new List<OrderItem>();
            for (ProductWrapper pw : products) {
                PricebookEntry pbe = pricebookEntries.get(pw.id);
                if (pbe != null) {
                    OrderItem item = new OrderItem(
                            OrderId = order.Id,
                            Product2Id = pw.id,
                            PricebookEntryId = pbe.Id,
                            Quantity = pw.quantity != null ? pw.quantity : 1,
                            UnitPrice = pbe.UnitPrice
                    );
                    orderItems.add(item);
                }
            }
            if (!orderItems.isEmpty()) {
                insert orderItems;
            }
            activateOrderAsync(order.Id, contract.Id);

            return order.Id;
        } catch (Exception e) {
            Database.rollback(sp);
            throw new AuraHandledException('Error creating order: ' + e.getMessage());
        }
    }

    @future
    public static void activateOrderAsync(Id orderId, Id contractId) {
        try {
            Contract contractToUpdate = [SELECT Id, Status FROM Contract WHERE Id = :contractId];
            contractToUpdate.Status = 'Activated';
            update contractToUpdate;

            Order orderToUpdate = [SELECT Id, Status FROM Order WHERE Id = :orderId];
            orderToUpdate.Status = 'Activated';
            update orderToUpdate;

        } catch (Exception e) {
        }
    }

    public static Decimal getProductsTotalAmountAfterDiscount(List<ProductWrapper> products) {
        if (products == null || products.isEmpty()) {
            return 0;
        }

        List<Discount__c> activeDiscounts = [
                SELECT Id, Name, Discount_Type__c, Value_Type__c, Discount_Value__c,
                        Start_Date__c, End_Date__c,
                        Condition_Logic__c
                        Recurring_Date_Start__c, Recurring_Date_End__c, Recurring_Date_Repeat_By__c
                FROM Discount__c
                WHERE Is_Active__c = TRUE
        ];
        Decimal totalAmount = getProductsTotalAmount(products);
        DiscountSettings settings = new DiscountSettings();

        return DiscountFilter.calculateDiscountedAmount(activeDiscounts,settings,  totalAmount);
    }
}