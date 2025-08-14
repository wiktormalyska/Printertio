public virtual class DiscountTestDataFactory implements TestDataFactory {

    public SObject prepare() {
        return DiscountBuilder.create()
                .withName('Test Discount')
                .withIsActive(true)
                .withDiscountType(ConstUtil.DISCOUNT.TYPE.TIME_BOUND)
                .withValueType(ConstUtil.DISCOUNT.VALUE.TYPE.PERCENTAGE)
                .withDiscountValue(10.0)
                .withStartDate(Date.today())
                .withEndDate(Date.today().addDays(30))
                .build();
    }

    public virtual SObject create() {
        return prepare();
    }

    public void save() {
        SObject discount = create();
        insert discount;
    }
}