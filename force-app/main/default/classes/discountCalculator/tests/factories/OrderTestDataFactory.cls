public virtual class OrderTestDataFactory extends TestDataFactory {
    private final Account account;

    protected override SObject prepare() {
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

    public virtual override SObject create() {
        return prepare();
    }

    private class AccountDataFactory extends AccountTestDataFactory {
        public override SObject create() {
            Account account = (Account) super.prepare();
            account.Type = 'Customer';
            return account;
        }
    }
}