public class ProductsTotalPriceValidator implements IFieldValidator {
    public Decimal getFieldValue(Order order) {
        Decimal totalPrice = 0;
        for (OrderItem item : order.OrderItems) {
            totalPrice += item.UnitPrice * item.Quantity;
        }
        return totalPrice;
    }

    public String getApiName() {
        return 'Order.Products_Total_Price';
    }
}