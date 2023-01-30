public with sharing class checkoutController {
    @AuraEnabled(cacheable=true)
    public static List<UDF__c> getUdfs(Id accountId){
        return [SELECT Id, Name, DIMS_Field_Number__c, Account__c, Account__r.Name FROM UDF__c WHERE Account__c = :accountId];
    }
}
