public class ProductsAmountValidator implements IFieldValidator {
    public Decimal getFieldValue(Order order) {
        return order.OrderItems.size();
    }

    public String getApiName() {
        return 'Order.Products_Amount';
    }
}