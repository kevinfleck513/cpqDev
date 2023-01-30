trigger ContractTrigger on Contract (before insert) {
    
    if(Trigger.isBefore && Trigger.isInsert){
        ContractTriggerHandler ct = new ContractTriggerHandler();
        ct.beforeInsert();
    }

}