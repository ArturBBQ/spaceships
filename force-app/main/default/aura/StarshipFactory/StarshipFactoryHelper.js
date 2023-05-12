({
    msgInsertStarship: function(component, event, helper) {
        var recievedMessage = event.getParam("message");
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Success!",
            "message": recievedMessage,
            "type": "success"
        });
        toastEvent.fire();
    }
})

