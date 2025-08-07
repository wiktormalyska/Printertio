public virtual class AccountTestDataFactory implements TestDataFactory {

    public SObject prepare() {
        return AccountBuilder.create()
                .withName('Test Account')
                .build();
    }

    public virtual SObject create() {
        return prepare();
    }

    public void save() {
        SObject account = create();
        insert account;
    }
}