public virtual class DiscountTestDataFactory extends TestDataFactory {

    protected override SObject prepare() {
        return DiscountBuilder.create()
                .withName('Test Discount')
                .withIsActive(true)
                .withDiscountType(ConstUtil.DISCOUNT_TYPE_TIME_BOUND)
                .withValueType(ConstUtil.DISCOUNT_VALUE_TYPE_PERCENTAGE)
                .withDiscountValue(10.0)
                .withStartDate(Date.today())
                .withEndDate(Date.today().addDays(30))
                .build();
    }

    public virtual override SObject create() {
        return prepare();
    }
}