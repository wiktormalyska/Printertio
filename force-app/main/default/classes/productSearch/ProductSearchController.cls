public with sharing class ProductSearchController {

    @AuraEnabled(Cacheable=true)
    public static List<Product2> getProducts(String searchTerm, String family) {
        try {
            return ProductSearchService.getProducts(searchTerm, family);
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving products: ' + e.getMessage());
        }
    }

    @AuraEnabled(Cacheable=true)
    public static List<String> getProductFamilies() {
        try {
            return ProductSearchService.getProductFamilies();
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving product families: ' + e.getMessage());
        }
    }

    @AuraEnabled(Cacheable=false)
    public static Decimal getProductsTotalAmount(List<ProductSearchService.ProductWrapper> products) {
        try {
            return ProductSearchService.getProductsTotalAmount(products);
        } catch (Exception e) {
            throw new AuraHandledException('Error calculating total amount: ' + e.getMessage());
        }
    }

    @AuraEnabled(Cacheable=false)
    public static Decimal getProductsTotalAmountAfterDiscount(List<ProductSearchService.ProductWrapper> products) {
        try {
            return ProductSearchService.getProductsTotalAmountAfterDiscount(products);
        } catch (Exception e) {
            throw new AuraHandledException('Error calculating total amount after discount: ' + e.getMessage());
        }
    }


    @AuraEnabled(Cacheable=false)
    public static String createOrderForOpportunity(Id opportunityId, List<ProductSearchService.ProductWrapper> products) {
        try {
            return ProductSearchService.createOrderForOpportunity(opportunityId, products);
        } catch (Exception e) {
            throw new AuraHandledException('Error creating order for opportunity: ' + e.getMessage());
        }
    }
}