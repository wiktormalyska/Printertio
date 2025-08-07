public virtual class OrderItemTestDataFactory implements TestDataFactory {
    private final Order order;
    private final PricebookEntry pricebookEntry;

    public SObject prepare() {

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

    public virtual SObject create() {
        return prepare();
    }

    public void save() {
        SObject orderItem = create();
        insert orderItem;
    }
}