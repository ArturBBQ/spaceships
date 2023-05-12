public with sharing class StarshipTriggerHandler {

    public static Boolean isDamageEssential = false;

    public static void updateStarshipFields(List<Starship__c> triggerNew) { 
        List<Account> account = [SELECT Id, Name FROM Account WHERE Name = 'Base Station'];

        for (Starship__c starship : triggerNew) {
            if (starship.Current_Station__c == null) {
                starship.Status__c = 'On Station';
                starship.Current_Station__c = account[0].Id;
            }
        }
    }

    public static void departureError(List<Starship__c> triggerNew, Map<Id, Starship__c> triggerOldMap) {

        for (Starship__c starship :triggerNew){
            Starship__c starshipOld = triggerOldMap.get(starship.Id);
            if (starship.Crew_Members__c < starship.Crew_Size__c){
                if (starshipOld.Status__c != 'Departure' && starship.Status__c == 'Departure') {
                    starship.addError('Наберіть команду, перед зміною статусу');
                }
            }
        }
    }

    public static void createTaskForStarship(List<Starship__c> triggerNew) { 
        List<Task> taskList= new List<Task>();

        for (Starship__c starship : triggerNew) {
            Task task = new Task();
            task.Subject = starship.Name;
            task.Status = 'Open';
            task.WhatId = starship.Id;
            task.ActivityDate = Date.today();
            task.Description = 'Знайдіть команду';
            taskList.add(task);
        }

        if (!taskList.isEmpty()) {
            insert taskList;
        }
    }     

    public static void updateStarshipCrewStatus(List<Starship__c> triggerNew, Map<Id, Starship__c> triggerOldMap) {
        
        for (Starship__c starship : triggerNew) {
            Starship__c starshipOld = triggerOldMap.get(starship.Id);
            if (starshipOld.Crew_Members__c != starship.Crew_Members__c || starshipOld.Crew_Size__c != starship.Crew_Size__c) {
                if (starship.Crew_Members__c == starship.Crew_Size__c) {
                    starship.Status__c = 'Crew Ready';
                } else if (starship.Crew_Members__c < starship.Crew_Size__c) {
                    starship.Status__c = 'On Station';
                } else if (starship.Crew_Members__c > starship.Crew_Size__c) {
                    starship.addError('Starship Crew is already fully on board');
                } 
            }
        }
    }

    public static void starshipDeparture(List<Starship__c> triggerNew, Map<Id, Starship__c> triggerOldMap) {

        for (Starship__c starship : triggerNew) {
            Starship__c starshipOld = triggerOldMap.get(starship.Id);
            if (starship.Status__c == 'Departure' && starshipOld.Status__c != 'Departure') {
                if (starship.Crew_Members__c == starship.Crew_Size__c && starshipOld.Status__c != 'Maintenance') {
                    starship.Status__c = 'In Flight';
                    starship.Current_Station__c = null;
                } else {
                    starship.addError('Starship Crew is not fully');
                }
            }
        }
    }


    public static void checkDamageLevel(List<Starship__c> triggerNew, Map<Id, Starship__c> triggerOldMap) {
      
        for (Starship__c starship : triggerNew) {
            Starship__c starshipOld = triggerOldMap.get(starship.Id);
            if (starship.Status__c == 'In Flight' && starshipOld.Status__c != 'In Flight') {
                starship.Damage_Level__c = Integer.valueOf((Math.random()*10));
            } 

            if (starship.Damage_Level__c > 5 && starship.Status__c == 'In Flight') {
                isDamageEssential = true;
            }
        }
    }

    public static void landingIfDamageEssential(List<Starship__c> triggerNew) {
        List<Account> station = [SELECT Id, Name
                                 FROM Account 
                                 WHERE RecordType.DeveloperName = 'Space_Station'];

        for (Starship__c starship : triggerNew) {
            if (isDamageEssential) {
                starship.Current_Station__c = station[0].Id;
                starship.Status__c = 'Maintenance';
                starship.Maintenance_Done__c = false;
            }
        }
    }
        

    public static void starshipOnRepair(List<Starship__c> triggerNew, Map<Id, Starship__c> triggerOldMap) {
        
        for (Starship__c starship : triggerNew) {
            Starship__c starshipOld = triggerOldMap.get(starship.Id);
           if (starship.Maintenance_Done__c == true && starship.Status__c == 'Maintenance') {
                starship.Status__c = 'On Station';
                starship.Damage_Level__c = 0;
            } else if(starshipOld.Status__c == 'Maintenance' && starship.Status__c != 'Maintenance') {
                starship.addError('Starship is currently under repair! Please check Maintenance Done before exploitation.');
            }
        }
    }

    public static void createTaskAfterDamage(List<Starship__c> triggerNew) {
        List<Task> taskListToInsert = new List<Task>();

        for(Starship__c starship : triggerNew) {
            if(isDamageEssential){
                taskListToInsert.add(new Task(
                    Subject = starship.Name + ' Maintenance In Progress',
                    Status = 'In Progress',
                    WhatId = starship.Id,
                    ActivityDate = Date.today(),
                    Description = 'Maintenance of ' + starship.Name + ' because Damage Level was ' + starship.Damage_Level__c
                ));
            }         
        }

        if(!taskListToInsert.isEmpty()) {
            insert taskListToInsert;
        }
    }

    public static void closeTaskAfterRepair(List<Starship__c> triggerNew, Map<Id, Starship__c> triggerOldMap, Map<Id, Starship__c> triggerNewMap) {
        Set<Id> starshipIds = new Set<Id>();
        for (Starship__c starship : triggerNew) {
            Starship__c starshipOld = triggerOldMap.get(starship.Id);
            if (starship.Maintenance_Done__c == true && starshipOld.Maintenance_Done__c != true) {
                starshipIds.add(starship.Id);
            }
        }

        List<Task> tasksToClose = [SELECT Id, Status, WhatId 
                                   FROM Task 
                                   WHERE WhatId IN :starshipIds AND Status = 'In Progress'];

        List<Task> taskListToClose = new List<Task>();
        
        for (Task task : tasksToClose) {
            taskListToClose.add(new Task(
                Id = task.Id,
                Subject = triggerNewMap.get(task.WhatId).Name + ' Maintenance Done',
                Status = 'Completed',
                ActivityDate = Date.today(),
                Description = 'Maintenance of ' + triggerNewMap.get(task.WhatId).Name + ' completed successfully.'                        
            )); 
        }
            
        if(!taskListToClose.isEmpty()) {
            update taskListToClose;
        }
    }

}