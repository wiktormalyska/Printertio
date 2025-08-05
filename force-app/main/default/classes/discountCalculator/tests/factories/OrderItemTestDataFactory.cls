public virtual class OrderItemTestDataFactory extends TestDataFactory {
    protected override SObject prepare() {
        Order order = (Order) new OrderDataFactory().create();
        PricebookEntry pricebookEntry = (PricebookEntry) new PricebookEntryDataFactory().create();
        return OrderItemBuilder.create()
                .withOrderId(order.Id)
                .withPricebookEntryId(pricebookEntry.Id)
                .withQuantity(1)
                .withUnitPrice(pricebookEntry.UnitPrice)
                .build();
    }

    public override SObject create() {
        return (OrderItem) prepare();
    }

    private class OrderDataFactory extends OrderTestDataFactory {
        public override SObject create() {
            Order order = (Order) super.prepare();
            order.Status = 'Draft';
            return order;
        }
    }

    private class PricebookEntryDataFactory extends PricebookEntryTestDataFactory {
        public override SObject create() {
            PricebookEntry pricebookEntry = (PricebookEntry) super.prepare();
            pricebookEntry.IsActive = true;
            return pricebookEntry;
        }
    }
}