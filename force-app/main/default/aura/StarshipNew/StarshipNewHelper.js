({
    
    createStarshipByApex : function(component, event, helper) {
        
        var newStarship = component.get("v.newStarship");
        newStarship.Current_Station__c = component.get("v.recordId");

        var action = component.get("c.createNewStarship");
        action.setParams({
            "starship": newStarship
        });

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var newStarship = response.getReturnValue();

                var createEvent = component.getEvent("cmpEvent");
                createEvent.setParams({ 
                    "message": "Starship '"+ newStarship.Name +"' created successfully." 
                });
                createEvent.fire();

                component.set("v.newStarship", {'sobjectType': 'Starship__c'});
                $A.get('e.force:refreshView').fire();
            }
        });

        $A.enqueueAction(action);

    }

})
