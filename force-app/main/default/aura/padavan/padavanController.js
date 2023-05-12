({
    doInit : function(component, event, helper) {

        var title = component.get("v.title");

        console.log('component.get("v.title") -----', title);

        title = 'GOOD PADAVAN';

        component.set("v.title", title);

    },

    buttonClick : function (component, event, helper) {
        
        helper.callToApex(component);

    }, 

    handleComponentEvent : function (cmp, event, helper) {
    
        var message = event.getParam("message");
        console.log ('event message -----' + message);

    },
    
})