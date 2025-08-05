public class FieldValidatorFactory {
    private static Map<String, Type> validatorMap = new Map<String, Type>{
            'Order.Products_Amount' => ProductsAmountValidator.class,
            'Order.Products_Total_Price' => ProductsTotalPriceValidator.class
    };

    public static IFieldValidator getValidator(String apiName) {
        Type validatorType = validatorMap.get(apiName);
        if (validatorType != null) {
            return (IFieldValidator) validatorType.newInstance();
        }
        return null;
    }
}