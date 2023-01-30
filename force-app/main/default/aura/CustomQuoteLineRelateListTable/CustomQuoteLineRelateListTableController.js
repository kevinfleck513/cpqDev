({
    doInit: function (component, event, helper) {
        component.set('v.columns', [
            {label: 'Product', fieldName: 'SBQQ__ProductName__c', type: 'text'},
            {label: 'Quantity', fieldName: 'SBQQ__Quantity__c', type: 'number', cellAttributes:{ alignment: 'left'}},
            {label: 'Description', fieldName: 'SBQQ__Description__c', type: 'text'},
        ]);
            
            // helper.getData(component);
            let quoteId = component.get('v.recordId');
            let action = component.get('c.getQuoteLines');
            action.setParams({
                quoteId: quoteId
            });
            action.setCallback(this,$A.getCallback(function(response){
                let state = response.getState();
                console.log("response.getState: "+ state);
                if(state==='SUCCESS'){
                    let quotelines = response.getReturnValue();
                    console.log("data: "+ JSON.stringify(quotelines));
                    component.set("v.quoteLineData", quotelines);
                    console.log('v.quoteLineData : ' + JSON.stringify(component.get('v.quoteLineData')));
                } else {            
                    console.log("error getting data: "+ response.getState());            
                    let errors = response.getError();
                    console.error(errors);
                }
            }));
            $A.enqueueAction(action);
		
    }
});