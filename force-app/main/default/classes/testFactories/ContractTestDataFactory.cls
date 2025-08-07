public virtual class ContractTestDataFactory implements TestDataFactory{
    private final Account account;

    public ContractTestDataFactory(Account account) {
        this.account = account;
    }

    public SObject prepare() {
        return ContractBuilder.create()
                .withAccountId(account.Id)
                .withStartDate(Date.today())
                .build();
    }

    public virtual SObject create() {
        return prepare();
    }

    public void save() {
        SObject contract = create();
        insert contract;
    }
}