public class PricebookEntryBuilder {
    private PricebookEntry pricebookEntry;

    private PricebookEntryBuilder() {
        this.pricebookEntry = new PricebookEntry();
    }

    public static PricebookEntryBuilder create() {
        return new PricebookEntryBuilder();
    }

    public PricebookEntryBuilder withPricebook2Id(Id pricebook2Id) {
        this.pricebookEntry.Pricebook2Id = pricebook2Id;
        return this;
    }

    public PricebookEntryBuilder withProduct2Id(Id product2Id) {
        this.pricebookEntry.Product2Id = product2Id;
        return this;
    }

    public PricebookEntryBuilder withUnitPrice(Decimal unitPrice) {
        this.pricebookEntry.UnitPrice = unitPrice;
        return this;
    }

    public PricebookEntryBuilder withIsActive(Boolean isActive) {
        this.pricebookEntry.IsActive = isActive;
        return this;
    }

    public PricebookEntry build() {
        return this.pricebookEntry;
    }
}