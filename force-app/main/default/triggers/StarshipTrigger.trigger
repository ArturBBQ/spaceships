trigger StarshipTrigger on Starship__c (before insert, before update, after insert, after update) {
    if(Trigger.isBefore) {
        if(Trigger.isInsert) {

            StarshipTriggerHandler.updateStarshipFields(Trigger.new);

        } else if(Trigger.isUpdate) {

            StarshipTriggerHandler.departureError(Trigger.new, Trigger.oldMap);
            StarshipTriggerHandler.updateStarshipCrewStatus(Trigger.new, Trigger.oldMap);       
            StarshipTriggerHandler.starshipDeparture(Trigger.new, Trigger.oldMap);
            StarshipTriggerHandler.checkDamageLevel(Trigger.new, Trigger.oldMap);
            StarshipTriggerHandler.landingIfDamageEssential(Trigger.new);
            StarshipTriggerHandler.starshipOnRepair(Trigger.new, Trigger.oldMap);

        }

    } else if(Trigger.isAfter) {
        if(Trigger.isInsert) {

            StarshipTriggerHandler.createTaskForStarship(Trigger.new);

        } else if(Trigger.isUpdate) {

            StarshipTriggerHandler.createTaskAfterDamage(Trigger.new);
            StarshipTriggerHandler.closeTaskAfterRepair(Trigger.new, Trigger.oldMap, Trigger.newMap);
            
        }
    }
}