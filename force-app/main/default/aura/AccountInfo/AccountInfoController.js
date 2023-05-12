({ 

    handleRecordUpdated: function (component, event, helper) { 
        var eventParams = event.getParams();
        if (eventParams.changeType === "CHANGED") {
            // get the fields that changed for this record
            var changedFields = eventParams.changedFields;  
            helper.showMessage();
        }
    },    
 
 
    handleSaveRecord: function (component, event, helper) {
      
        component.find("recordHandler").saveRecord($A.getCallback(function (saveResult) {
            // use the recordUpdated event handler to handle generic logic when record is changed
            if (saveResult.state === "SUCCESS" || saveResult.state === "DRAFT") {
                // handle component related logic in event handler
                console.log('saveResult.state--->' + saveResult.state);
            }

        }));

    },
  
    doInit: function (component, event, helper) {  

        helper.getChildContacts(component);
  
    },  

    updateContactHandler: function (component, event, helper) {
        
        var contact = event.getParam("contact"); 

        helper.updateContactInApex(component, contact);

    }  
 
 })  