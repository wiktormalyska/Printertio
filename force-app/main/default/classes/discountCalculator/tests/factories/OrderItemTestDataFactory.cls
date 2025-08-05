public virtual class OrderItemTestDataFactory extends TestDataFactory {
    private final Order order;
    private final PricebookEntry pricebookEntry;

    protected override SObject prepare() {

        return OrderItemBuilder.create()
                .withOrderId(this.order.Id)
                .withPricebookEntryId(pricebookEntry.Id)
                .withQuantity(1)
                .withUnitPrice(pricebookEntry.UnitPrice)
                .build();
    }

    public OrderItemTestDataFactory(Order order, PricebookEntry pricebookEntry) {
        this.order = order;
        this.pricebookEntry = pricebookEntry;
    }

    public virtual override SObject create() {
        return prepare();
    }
}