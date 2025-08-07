public virtual class ProductTestDataFactory implements TestDataFactory {
    public SObject prepare() {
        return ProductBuilder.create()
                .withName('Test Product')
                .withIsActive(true)
                .withProductCode('TP1')
                .withDescription('This is a test product.')
                .build();
    }

    public virtual SObject create() {
        return prepare();
    }

    public void save() {
        SObject product = create();
        insert product;
    }
}