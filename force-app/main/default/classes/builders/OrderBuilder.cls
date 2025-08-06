public class OrderBuilder {
    private Order order;

    private OrderBuilder() {
        this.order = new Order();
    }

    public static OrderBuilder create() {
        return new OrderBuilder();
    }
    public OrderBuilder withName(String name) {
        this.order.Name = name;
        return this;
    }

    public OrderBuilder withAccountId(Id accountId) {
        this.order.AccountId = accountId;
        return this;
    }

    public OrderBuilder withEffectiveDate(Date effectiveDate) {
        this.order.EffectiveDate = effectiveDate;
        return this;
    }

    public OrderBuilder withPricebook2Id(Id pricebook2Id) {
        this.order.Pricebook2Id = pricebook2Id;
        return this;
    }

    public OrderBuilder withStatus(String status) {
        this.order.Status = status;
        return this;
    }

    public OrderBuilder withContractId(Id contractId) {
        this.order.ContractId = contractId;
        return this;
    }

    public Order build() {
        return this.order;
    }
}