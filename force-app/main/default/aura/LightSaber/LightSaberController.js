({
    doInit : function(component, event, helper) {

        var color = component.get("v.color");

        var cmpEvent = component.getEvent("cmpEvent"); // event name
        cmpEvent.setParams({ "message" : "Lightsaber color: " + color });
        cmpEvent.fire();

    }
})
