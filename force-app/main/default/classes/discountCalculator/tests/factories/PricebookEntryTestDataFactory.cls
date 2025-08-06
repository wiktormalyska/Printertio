public virtual class PricebookEntryTestDataFactory extends TestDataFactory {
    private final Product2 product;

    public PricebookEntryTestDataFactory(Product2 product) {
        this.product = product;
    }

    protected override SObject prepare() {
        return PricebookEntryBuilder.create()
                .withPricebook2Id(Test.getStandardPricebookId())
                .withProduct2Id(this.product.Id)
                .withUnitPrice(100.0)
                .withIsActive(true)
                .build();
    }

    public virtual override SObject create() {
        return prepare();
    }

}