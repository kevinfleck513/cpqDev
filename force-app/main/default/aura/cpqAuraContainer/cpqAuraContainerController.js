({
	doInit : function(component, event, helper) {
        // set out id attribute to the incoming quoteId from the page reference
		component.set('v.id', component.get('v.pageReference').state.c__id);
	},
    
    onPageReferenceChange: function(component, event, helper) {
        // workaround to make sure we aren't cached and are working with the correct Id.
        component.set('v.id', component.get('v.pageReference').state.c__id);
        $A.get('e.force:refreshView').fire();
    },
    
    navigateToCpq : function(component, event, helper){
        // fire an event to the container to handle navigation on finish.
        let quoteId = component.get('v.id');
        let qleLink = '/apex/sbqq__sb?scontrolCaching=1&id='+quoteId+'#quote/le?qId='+quoteId;
        component.find("navService").navigate({
            type: "standard__webPage",
                attributes: {
                    url: qleLink
                } 
        });
    }
})