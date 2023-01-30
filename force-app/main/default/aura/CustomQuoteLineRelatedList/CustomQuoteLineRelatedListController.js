({
	doInit : function(component, event, helper) {
		let quoteId = component.get('v.recordId');
        let action = component.get('c.getQuoteLines');
        action.setParams({
            quoteId: quoteId
        });
        action.setCallback(this,function(response){
            let state = response.getState();
            console.log("getReturnValue normal table: " + JSON.stringify(response.getReturnValue()));
            if(state==='SUCCESS'){
                let quotelines = response.getReturnValue();
                // console.log('quoteLines : ' + JSON.stringify(quoteLines));
                component.set("v.QuoteLines", quotelines);
            } else {
                console.log("error getting data");
            }
        });
        $A.enqueueAction(action);
	}
})