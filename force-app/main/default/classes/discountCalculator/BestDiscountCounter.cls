public with sharing class BestDiscountCounter {
    public static Discount__c getMatchingDiscount(List<Discount__c> discounts, DiscountSettings settings, Order currentOrder) {
        Decimal bestDiscountValue = 0;
        Discount__c bestDiscount = null;

        for (Discount__c discount : discounts) {
            Decimal discountValue = 0;
            if (discount.Value_Type__c == 'Percentage') {
                discountValue = currentOrder.TotalAmount * discount.Discount_Value__c / 100;
            } else if (discount.Value_Type__c == 'Fixed Amount') {
                discountValue = discount.Discount_Value__c;
            }

            if (settings.strategy == 'Highest' && discountValue > bestDiscountValue) {
                bestDiscountValue = discountValue;
                bestDiscount = discount;
            } else if (settings.strategy == 'Lowest' && (bestDiscount == null || discountValue < bestDiscountValue)) {
                bestDiscountValue = discountValue;
                bestDiscount = discount;
            }
        }

        return bestDiscount;
    }

    public static Discount__c getMatchingDiscountBasedOnTotalAmount(List<Discount__c> discounts, DiscountSettings settings, Decimal totalAmount) {
        Decimal bestDiscountValue = 0;
        Discount__c bestDiscount = null;

        for (Discount__c discount : discounts) {
            Decimal discountValue = 0;
            if (discount.Value_Type__c == 'Percentage') {
                discountValue = totalAmount * discount.Discount_Value__c / 100;
            } else if (discount.Value_Type__c == 'Fixed Amount') {
                discountValue = discount.Discount_Value__c;
            }

            if (settings.strategy == 'Highest' && discountValue > bestDiscountValue) {
                bestDiscountValue = discountValue;
                bestDiscount = discount;
            } else if (settings.strategy == 'Lowest' && (bestDiscount == null || discountValue < bestDiscountValue)) {
                bestDiscountValue = discountValue;
                bestDiscount = discount;
            }
        }

        return bestDiscount;
    }
}