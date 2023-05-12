({
    doInit : function(component, event, helper) {

        var question = component.get("v.question");

        if(question === 'hello') {
            var cmpEvent = component.getEvent("cmpEvent"); // event name
            cmpEvent.setParams({ "message" : question + " young padavan!"});
        } else {
            var cmpEvent = component.getEvent("cmpEvent"); // event name
            cmpEvent.setParams({ "message" : " Going to Base station! "});
        }        
        cmpEvent.fire();
    }
})
