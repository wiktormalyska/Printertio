public virtual class AccountTestDataFactory extends TestDataFactory {
    protected override SObject prepare() {
        return AccountBuilder.create()
                .withName('Test Account')
                .build();
    }

    public virtual override SObject create() {
        return (Account) prepare();
    }
}