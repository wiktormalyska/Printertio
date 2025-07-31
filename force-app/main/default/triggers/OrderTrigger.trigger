trigger OrderTrigger on Order (after insert) {
    DiscountCalculatorHandler.applyDiscountsAfterInsert(Trigger.new);
}