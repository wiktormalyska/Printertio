public virtual class PricebookEntryTestDataFactory extends TestDataFactory {
    protected override SObject prepare() {
        Product2 product = (Product2) new ProductDataFactory().create();
        return PricebookEntryBuilder.create()
                .withPricebook2Id(Test.getStandardPricebookId())
                .withProduct2Id(product.Id)
                .withUnitPrice(100.0)
                .withIsActive(true)
                .build();
    }

    public override SObject create() {
        return (PricebookEntry) prepare();
    }

    private class ProductDataFactory extends ProductTestDataFactory {
        public override SObject create() {
            Product2 product = (Product2) super.prepare();
            product.IsActive = true;
            return product;
        }
    }

}