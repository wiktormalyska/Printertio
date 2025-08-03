trigger OrderItemTrigger on OrderItem (after insert, after update, after delete, after undelete) {
    new OrderItemTriggerHandler().run();
}