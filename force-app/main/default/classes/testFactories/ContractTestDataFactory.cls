public virtual class ContractTestDataFactory extends TestDataFactory{
    private final Account account;

    public ContractTestDataFactory(Account account) {
        this.account = account;
    }

    protected override SObject prepare() {
        return ContractBuilder.create()
                .withAccountId(account.Id)
                .withStartDate(Date.today())
                .build();
    }

    public virtual override SObject create() {
        return prepare();
    }
}