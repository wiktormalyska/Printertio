public class ContractBuilder {
    private Contract contract;

    private ContractBuilder() {
        this.contract = new Contract();
    }

    public static ContractBuilder create() {
        return new ContractBuilder();
    }

    public ContractBuilder withAccountId(Id accountId) {
        this.contract.AccountId = accountId;
        return this;
    }

    public ContractBuilder withStartDate(Date startDate) {
        this.contract.StartDate = startDate;
        return this;
    }

    public ContractBuilder withStatus(String status) {
        this.contract.Status = status;
        return this;
    }

    public ContractBuilder withContractTerm(Integer contractTerm) {
        this.contract.ContractTerm = contractTerm;
        return this;
    }

    public Contract build() {
        return this.contract;
    }
}