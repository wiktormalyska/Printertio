trigger OrderTrigger on Order (after update) {
    List<Order> ordersWithItems = new List<Order>();
    for (Order ord : Trigger.new) {
        Integer itemCount = [
                SELECT COUNT() FROM OrderItem WHERE OrderId = :ord.Id
        ];
        if (itemCount > 0) {
            ordersWithItems.add(ord);
        }
    }
    System.debug('Orders with items: ' + ordersWithItems);
    if (!ordersWithItems.isEmpty()) {
        DiscountCalculatorHandler.applyDiscountsAfterInsert(ordersWithItems);
    }
}