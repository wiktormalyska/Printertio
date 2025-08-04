public with sharing class ProductSearchController {

    @AuraEnabled(Cacheable=true)
    public static List<Product2> getProducts(String searchTerm, String family) {
        if (String.isNotBlank(searchTerm) && String.isNotBlank(family)) {
            return [
                    SELECT Id, Name, Family, ProductCode
                    FROM Product2
                    WHERE (Name LIKE :('%' + searchTerm + '%') OR ProductCode LIKE :('%' + searchTerm + '%'))
                    AND Family = :family
            ];
        } else if (String.isNotBlank(searchTerm)) {
            return [
                    SELECT Id, Name, Family, ProductCode
                    FROM Product2
                    WHERE Name LIKE :('%' + searchTerm + '%') OR ProductCode LIKE :('%' + searchTerm + '%')
            ];
        } else if (String.isNotBlank(family)) {
            return [
                    SELECT Id, Name, Family, ProductCode
                    FROM Product2
                    WHERE Family = :family
            ];
        } else {
            return [
                    SELECT Id, Name, Family, ProductCode
                    FROM Product2
            ];
        }
    }

    @AuraEnabled(Cacheable=true)
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
    public class ProductWrapper {
        @AuraEnabled public Id id {get; set;}
        @AuraEnabled public Integer quantity {get; set;}
    }

    @AuraEnabled(Cacheable=false)
    public static String createOrderForOpportunity(Id opportunityId, List<ProductWrapper> products) {
        System.debug('Creating order for opportunity: ' + opportunityId);
        System.debug('Products: ' + products);
        if (opportunityId == null || products == null || products.isEmpty()) {
            throw new AuraHandledException('Opportunity ID and product list cannot be null or empty.');
        }

        Id accountId = [SELECT AccountId FROM Opportunity WHERE Id = :opportunityId].AccountId;
        System.debug('Account ID: ' + accountId);
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
            System.debug('Contract created: ' + contract.Id);

            Order order = new Order(
                    AccountId = accountId,
                    EffectiveDate = System.today(),
                    Status = 'Draft',
                    ContractId = contract.Id,
                    Pricebook2Id = standardPricebookId
            );
            insert order;
            System.debug('Order created: ' + order.Id);

            Set<Id> productIds = new Set<Id>();
            for (ProductWrapper pw : products) {
                productIds.add(pw.id);
            }
            System.debug('Product IDs: ' + productIds);

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
            System.debug('Pricebook Entries: ' + pricebookEntries);

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
            System.debug('Order Items: ' + orderItems);

            if (!orderItems.isEmpty()) {
                insert orderItems;
            }

            return order.Id;
        } catch (Exception e) {
            Database.rollback(sp);
            throw new AuraHandledException('Error creating order: ' + e.getMessage());
        }
    }
}