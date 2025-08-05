public virtual class OrderTestDataFactory extends TestDataFactory {
    protected override SObject prepare() {
        Id priceBookId = Test.getStandardPricebookId();
        Account account = (Account) new AccountDataFactory().create();
        return OrderBuilder.create()
                .withAccountId(account.Id)
                .withPricebook2Id(priceBookId)
                .withStatus('Draft')
                .withEffectiveDate(Date.today())
                .build();
    }

    public override SObject create() {
        return (Order) prepare();
    }

    private class AccountDataFactory extends AccountTestDataFactory {
        public override SObject create() {
            Account account = (Account) super.prepare();
            account.Type = 'Customer';
            return account;
        }
    }
}