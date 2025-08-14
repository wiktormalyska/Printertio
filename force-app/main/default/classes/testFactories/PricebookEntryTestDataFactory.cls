public virtual class PricebookEntryTestDataFactory implements TestDataFactory {
    private final Product2 product;

    public PricebookEntryTestDataFactory(Product2 product) {
        this.product = product;
    }

    public SObject prepare() {
        return PricebookEntryBuilder.create()
                .withPricebook2Id(Test.getStandardPricebookId())
                .withProduct2Id(this.product.Id)
                .withUnitPrice(100.0)
                .withIsActive(true)
                .build();
    }

    public virtual SObject create() {
        return prepare();
    }

    public void save() {
        SObject pricebookEntry = create();
        insert pricebookEntry;
    }
}