public with sharing class UserAssignmentController {    

    @AuraEnabled
    public static List<OrderItem> getOrderItems(Id orderId){
        
        return [SELECT Id, Product2.Name FROM OrderItem WHERE OrderId = :orderId];

    }

}