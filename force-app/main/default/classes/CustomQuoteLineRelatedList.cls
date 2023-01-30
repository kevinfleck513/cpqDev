public with sharing class CustomQuoteLineRelatedList {

    @AuraEnabled
    public static List<SBQQ__QuoteLine__c> getQuoteLines(Id quoteId){
        
        return [SELECT Id, SBQQ__ProductName__c, SBQQ__Quantity__c, SBQQ__Description__c, SBQQ__NetTotal__c, SBQQ__ListTotal__c FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c =: quoteId and SBQQ__Bundle__c = false];
        
}
}