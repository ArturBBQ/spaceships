({
    
    showMessage : function( ) {
        var resultsToast = $A.get("e.force:showToast");
        resultsToast.setParams({
             "title": "Saved",
             "message": "Account Name has been updated.",
             "type": "success"
        });

        resultsToast.fire();
    },

    getChildContacts: function(component) {
        // call apex method 
        let action = component.get("c.getContacts");  
        // define parameters for apex method
        action.setParams({ 
            accountId: component.get("v.recordId") 
        });  
    
        action.setCallback(this, function (response) {
            let state = response.getState();
            console.log('state----->' + state);
            if (state === "SUCCESS") {
            // assign contacts returned from apex to component attribute contacts
                let contcts  = response.getReturnValue();
                if (contcts.length > 0){
                    component.set("v.contacts", contcts);
                }
            }
        });
        // Queue a call to an Apex action
        $A.enqueueAction(action);
    }, 

    updateContactInApex: function(component, contact) {
        var action = component.get("c.updateRelatedContact");

        action.setParams({ 
            contact: contact 
        });

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var updatedContact = response.getReturnValue();
                var resultsToast = $A.get('e.force:showToast');
                resultsToast.setParams({
                    "title": "Contact Updated",
                    "message": "Contact " + updatedContact.FirstName +" "+ updatedContact.LastName + " has been updated.",
                    "type": "success"
                });
                resultsToast.fire();
            } 
        });
        $A.enqueueAction(action);
    }

})
