({
    updateContact : function(component, event, helper) {
        var cmpEvent = component.getEvent("updContactEvent"); 
        cmpEvent.setParams({ 
            "contact": component.get("v.contact") 
        });
        
        cmpEvent.fire();  
    }
})
