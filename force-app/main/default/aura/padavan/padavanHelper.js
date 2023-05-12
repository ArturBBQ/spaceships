({
    callToApex : function(component) {

        var action = component.get("c.getCurrentUser");
        action.setCallback(this, function(response) {
            var user = response.getReturnValue();
            component.set("v.myName", user.Name);
        })
        
        $A.enqueueAction(action);

    }
})
