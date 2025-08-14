public class OrderItemsCondition implements ICondition {
    public Boolean isApplicable(SObject record) {
        Order order = (Order) record;
        if (order == null || order.OrderItems == null || order.OrderItems.isEmpty()) {
            return false;
        }

        Integer itemCount = 0;
        for (OrderItem item : order.OrderItems) {
            if (item.Quantity != null && item.Quantity > 0) {
                itemCount += (Integer) item.Quantity;
            }
        }
        return itemCount >= ConstUtil.DISCOUNT.CONDITION_TYPE.MINIMUM_ORDER_ITEM_COUNT;
    }

    public String getName() {
        return 'Order have more than ' + ConstUtil.DISCOUNT.CONDITION_TYPE.MINIMUM_ORDER_ITEM_COUNT + ' items';
    }
}