public virtual class ProductTestDataFactory extends TestDataFactory {
    protected override SObject prepare() {
        return ProductBuilder.create()
                .withName('Test Product')
                .withIsActive(true)
                .withProductCode('TP1')
                .withDescription('This is a test product.')
                .build();
    }

    public virtual override SObject create() {
        return (Product2) prepare();
    }

}