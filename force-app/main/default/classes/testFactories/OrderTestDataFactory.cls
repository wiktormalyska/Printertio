public virtual class OrderTestDataFactory implements TestDataFactory {
    private final Account account;

    public SObject prepare() {
        Id priceBookId = Test.getStandardPricebookId();
        Account account = this.account;
        return OrderBuilder.create()
                .withAccountId(account.Id)
                .withPricebook2Id(priceBookId)
                .withStatus('Draft')
                .withEffectiveDate(Date.today())
                .build();
    }

    public OrderTestDataFactory(Account account) {
        this.account = account;
    }

    public virtual SObject create() {
        return prepare();
    }

    private class AccountDataFactory extends AccountTestDataFactory {
        public override SObject create() {
            Account account = (Account) super.prepare();
            account.Type = 'Customer';
            return account;
        }
    }

    public void save() {
        SObject order = create();
        insert order;
    }
}