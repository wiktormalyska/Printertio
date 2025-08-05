public class OrderItemBuilder {
    private OrderItem orderItem;

    private OrderItemBuilder() {
        this.orderItem = new OrderItem();
    }

    public static OrderItemBuilder create() {
        return new OrderItemBuilder();
    }

    public OrderItemBuilder withOrderId(Id orderId) {
        this.orderItem.OrderId = orderId;
        return this;
    }

    public OrderItemBuilder withPricebookEntryId(Id pricebookEntryId) {
        this.orderItem.PricebookEntryId = pricebookEntryId;
        return this;
    }

    public OrderItemBuilder withQuantity(Decimal quantity) {
        this.orderItem.Quantity = quantity;
        return this;
    }

    public OrderItemBuilder withUnitPrice(Decimal unitPrice) {
        this.orderItem.UnitPrice = unitPrice;
        return this;
    }

    public OrderItem build() {
        return this.orderItem;
    }
}