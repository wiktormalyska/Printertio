public class DiscountBuilder {
    private Discount__c discount;

    private DiscountBuilder() {
        this.discount = new Discount__c();
    }

    public static DiscountBuilder create() {
        return new DiscountBuilder();
    }

    public DiscountBuilder withName(String name) {
        this.discount.Name = name;
        return this;
    }

    public DiscountBuilder withDiscountType(String discountType) {
        this.discount.Discount_Type__c = discountType;
        return this;
    }

    public DiscountBuilder withValueType(String valueType) {
        this.discount.Value_Type__c = valueType;
        return this;
    }

    public DiscountBuilder withDiscountValue(Decimal discountValue) {
        this.discount.Discount_Value__c = discountValue;
        return this;
    }

    public DiscountBuilder withStartDate(Date startDate) {
        this.discount.Start_Date__c = startDate;
        return this;
    }

    public DiscountBuilder withEndDate(Date endDate) {
        this.discount.End_Date__c = endDate;
        return this;
    }

    public DiscountBuilder withIsActive(Boolean isActive) {
        this.discount.Is_Active__c = isActive;
        return this;
    }

    public DiscountBuilder withConditionLogic(String field) {
        this.discount.Condition_Logic__c = field;
        return this;
    }

    public DiscountBuilder withRecurringDateStart(Datetime recurringDateStart) {
        this.discount.Recurring_Date_Start__c = recurringDateStart;
        return this;
    }

    public DiscountBuilder withRecurringDateEnd(Datetime recurringDateEnd) {
        this.discount.Recurring_Date_End__c = recurringDateEnd;
        return this;
    }

    public DiscountBuilder withRecurringDateRepeatBy(String repeatBy) {
        this.discount.Recurring_Date_Repeat_By__c = repeatBy;
        return this;
    }

    public Discount__c build() {
        return this.discount;
    }
}