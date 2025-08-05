public class AccountBuilder {
    private Account account;

    private AccountBuilder() {
        this.account = new Account();
    }

    public static AccountBuilder create() {
        return new AccountBuilder();
    }

    public AccountBuilder withName(String name) {
        this.account.Name = name;
        return this;
    }

    public AccountBuilder withType(String type) {
        this.account.Type = type;
        return this;
    }

    public Account build() {
        return this.account;
    }
}