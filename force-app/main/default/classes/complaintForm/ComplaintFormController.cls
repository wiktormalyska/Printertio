public with sharing class ComplaintFormController {
    @AuraEnabled(Cacheable=true)
    public static List<OrderItem> getOrderItemsFromOrderId(Id orderId){
        return ComplaintFormService.getOrderItemsFromOrderId(orderId);
    }

    @AuraEnabled
    public static ComplaintSubmissionResult submitComplaintForApproval(List<Id> orderItemIds){
        return ComplaintFormService.submitComplaintForApproval(orderItemIds);
    }
}