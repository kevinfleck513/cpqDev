public class ContractTriggerHandler {
    
    public void beforeInsert(){
        for(Contract c : (List<Contract>) Trigger.new){
            c.SBQQ__PreserveBundleStructureUponRenewals__c = true;
            c.SpecialTerms = 'Trigger beforeInsert called';
        }
    }

}