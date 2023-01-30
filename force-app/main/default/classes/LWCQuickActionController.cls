public with sharing class LWCQuickActionController {
    
    @AuraEnabled(cacheable=true)
    public static List<SBQQ__QuoteLine__c> getQuoteLines(Id quoteId){
        System.debug('quoteId: ' + quoteId);
        List<SBQQ__QuoteLine__c> quoteLines = [SELECT Id, SBQQ__Product__r.Name FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c = :quoteId];
        System.debug('quoteLines: ' + quoteLines);
        return quoteLines;
    }
    @AuraEnabled
    public static List<OrderItem> getOrderItems(Id orderId){
        return [SELECT Id, Product2.Name FROM OrderItem WHERE OrderId = :orderId];
    }

}