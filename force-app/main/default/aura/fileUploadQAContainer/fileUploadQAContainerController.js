({
    doInit : function(component, event, helper) {
        console.log(`fileUploadQAContainer`);
        console.log(`quoteId = ${component.get('v.recordId')}`);
    },

    closeQuickAction : function(component, event, helper){
        console.log(`{!c.closeAction}`);
        $A.get("e.force:closeQuickAction").fire();
    }
})