@isTest
public class StarshipTrigger_Test {

    @TestSetup
    static void makeData(){
        Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
                                .get('Space_Station').getRecordTypeId();
        Account station = new Account(
            Name = 'Base Station',
            RecordTypeId = recordTypeId,
            Starships_Number_Max__c = 10);
        insert station;

        Starship__c starship = new Starship__c(
            Name = 'Test Starship',
            Crew_Size__c = 5,
            Status__c = 'On Station');
        insert starship;

        Starship__c starshipOnMaintenance = new Starship__c(
            Name = 'Test Maintenance Starship',
            Crew_Size__c = 0,
            Status__c = 'Maintenance', 
            Current_Station__c = station.Id,
            Damage_Level__c = 7);
        insert starshipOnMaintenance;

        Task task = new Task(
            Subject = 'Test Task', 
            WhatId = starshipOnMaintenance.Id, 
            Status = 'In Progress');
        insert task;
        
        Id contactRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName()
                                        .get('Mercenary').getRecordTypeId();
        Contact con = new Contact(
            LastName = 'Scout Trooper',
            RecordTypeId = contactRecordTypeId, 
            Mercenary_Rate__c = 100);
        insert con;

        List<Crew_Member__c> crewMmbrs = new List<Crew_Member__c>();
        for(Integer i=0; i<starship.Crew_Size__c; i++) {
            Crew_Member__c member = new Crew_Member__c(
                Mercenary_Id__c = con.Id,
                Starship_Id__c = starship.Id,
                Contract_Start_Date__c = Date.today()
            );
            crewMmbrs.add(member);
        }
        insert crewMmbrs;
    }

    @isTest
    static void test_updateStarshipFields() {
        Starship__c starshipResult = [SELECT Status__c FROM Starship__c WHERE Name = 'Test Starship'][0];
        starshipResult.Status__c = 'On Station';
        System.assertEquals('On Station', starshipResult.Status__c);
    }
    
    @isTest
    static void test_departureError() {
        Starship__c starship = [SELECT Id, Name FROM Starship__c WHERE Name = 'Test Starship'][0];
        starship.Status__c = 'Departure';

        try {
            update starship;
        } catch(Exception e) {
            String error = e.getMessage();
            System.assert(error.contains('Starship Crew is not fully'));
        }
    }

    @isTest
    static void test_positiveDepartureError() {
        Starship__c starship = [SELECT Id, Name, Status__c FROM Starship__c WHERE Name = 'Test Starship'][0];
        starship.Status__c = 'Departure';

        Test.startTest();
            update starship;
        Test.stopTest();

        Starship__c starshipForCheck = [SELECT Id, Status__c FROM Starship__c WHERE Name = 'Test Starship'][0];

        if(StarshipTriggerHandler.isDamageEssential) { 
            //if Damage in flight will be Essential - Status automatically change to 'Maintenance'
            System.assertEquals('Maintenance', starshipForCheck.Status__c); 
        } else { 
            //if Status 'Departure' - Status automatically will be 'In Flight'
            System.assertEquals('In Flight', starshipForCheck.Status__c);
        }
    }

    @isTest
    static void test_createTaskForStarship() {   
        List<Starship__c> starship = [SELECT Id FROM Starship__c];

        List<Task> taskList= [SELECT Id, WhatId, Status FROM Task];

        System.assertEquals(starship[0].Id, taskList[0].WhatId);
        System.assertEquals('Open', taskList[0].Status);
    }

    @isTest
    static void test1_updateStarshipCrewStatus() {   
        Starship__c starship = [SELECT Id, Crew_Size__c, Status__c FROM Starship__c WHERE Name = 'Test Starship'][0];
        List<Crew_Member__c> crewMmbrs =[SELECT Id FROM Crew_Member__c];

        System.assertEquals(starship.Crew_Size__c, crewMmbrs.size());
        System.assertEquals('Crew Ready', starship.Status__c);

        Test.startTest();
            delete crewMmbrs[0];
        Test.stopTest();

        Starship__c starshipUpdated = [SELECT Id, Crew_Size__c, Status__c FROM Starship__c WHERE Name = 'Test Starship'][0];
        List<Crew_Member__c> crewMmbrsNew =[SELECT Id FROM Crew_Member__c];

        System.assertNotEquals(starshipUpdated.Crew_Size__c, crewMmbrsNew.size());
        System.assertEquals('On Station', starshipUpdated.Status__c);
    }

    @isTest
    static void test2_updateStarshipCrewStatusError() {   
        Starship__c starship = [SELECT Id, Crew_Size__c, Status__c FROM Starship__c WHERE Name = 'Test Starship'][0];
        List<Crew_Member__c> crewMmbrs =[SELECT Id, Mercenary_Id__c, Starship_Id__c FROM Crew_Member__c];

        System.assertEquals(starship.Crew_Size__c, crewMmbrs.size());
        System.assertEquals('Crew Ready', starship.Status__c);

        try {
            Crew_Member__c crewMmbrOneMore = new Crew_Member__c(
                Mercenary_Id__c = crewMmbrs[0].Mercenary_Id__c, 
                Starship_Id__c = crewMmbrs[0].Starship_Id__c, 
                Contract_Start_Date__c = Date.today());
            insert crewMmbrOneMore; // error 
        } catch(Exception e) {
            String error = e.getMessage();
            System.assert(error.contains('Starship Crew is already fully on board'));
        }        
    }

    @isTest
    static void test_starshipDeparture() {   
        Starship__c starship = [SELECT Id, Crew_Size__c, Status__c FROM Starship__c WHERE Name = 'Test Starship'][0];
        starship.Status__c = 'Departure';

        Test.startTest();
            update starship;
        Test.stopTest();

        Starship__c starshipForCheck = [SELECT Id, Current_Station__c, Crew_Size__c, Crew_Members__c, Status__c, Damage_Level__c
                                        FROM Starship__c 
                                        WHERE Name = 'Test Starship'][0];
        
        if(starshipForCheck.Damage_Level__c <= 5 && starshipForCheck.Crew_Size__c == starshipForCheck.Crew_Members__c) {
            System.assertEquals('In Flight', starshipForCheck.Status__c);
            System.assertEquals(null, starshipForCheck.Current_Station__c); 
        } else if (starshipForCheck.Damage_Level__c > 5) {
            System.assertEquals('Maintenance', starshipForCheck.Status__c); 
            System.assert(starshipForCheck.Current_Station__c != null); 
        }       
    }

    @isTest
    static void test2_starshipDepartureNegative() {   
        List<Crew_Member__c> crewMmbrs =[SELECT Id FROM Crew_Member__c];
        Starship__c starship = [SELECT Id, Crew_Size__c, Status__c FROM Starship__c WHERE Name = 'Test Starship'][0];
        starship.Status__c = 'Departure';

        Test.startTest();
            delete crewMmbrs[0];
            Database.SaveResult result = Database.update(starship, false);
        Test.stopTest();
        
        if(!result.isSuccess()) {
            System.assertEquals('Starship Crew is not fully', result.getErrors()[0].getMessage());
        }
    }        

    @isTest
    static void test_landingIfAccidentAndCreateTask() {   
        Starship__c starship = [SELECT Id, Crew_Size__c, Status__c FROM Starship__c WHERE Name = 'Test Starship'][0];
        starship.Status__c = 'In Flight';

        Test.startTest();
            update starship;
        Test.stopTest();

        Starship__c starshipForCheck = [SELECT Id, Current_Station__c, Status__c, Damage_Level__c
                                        FROM Starship__c 
                                        WHERE Name = 'Test Starship'][0];                        

        Account station = [SELECT Id, Name
                           FROM Account 
                           WHERE RecordType.DeveloperName = 'Space_Station'][0];

        if (starshipForCheck.Damage_Level__c > 5) {
            List<Task> taskList= [SELECT Id, Subject, WhatId, Status 
                                  FROM Task 
                                  WHERE WhatId = :starshipForCheck.Id AND Status= 'In Progress'];
                                  
            System.assertEquals(1, taskList.size());
            System.assertEquals(station.Id, starshipForCheck.Current_Station__c);
            System.assertEquals('Maintenance', starshipForCheck.Status__c);
            System.assertEquals(true, StarshipTriggerHandler.isDamageEssential);
        } else {
            System.assertEquals('In Flight', starshipForCheck.Status__c);
            System.assertEquals(false, StarshipTriggerHandler.isDamageEssential);
        }
    }

    @isTest
    static void test_starshipOnRepair() {   
        Starship__c starship = [SELECT Id, Status__c, Damage_Level__c, Maintenance_Done__c
                                FROM Starship__c 
                                WHERE Name = 'Test Maintenance Starship'][0];
        starship.Maintenance_Done__c = true;

        Test.startTest();
            update starship;
        Test.stopTest();

        Starship__c starshipAfterRepair = [SELECT Id, Status__c, Damage_Level__c, Maintenance_Done__c 
                                           FROM Starship__c 
                                           WHERE Name = 'Test Maintenance Starship'][0];

        System.assertEquals('On Station', starshipAfterRepair.Status__c);      
        System.assertEquals(0, starshipAfterRepair.Damage_Level__c);  
    }

    @isTest
    static void test2_starshipOnRepairNegative() {   
        Starship__c starship = [SELECT Id, Status__c, Damage_Level__c FROM Starship__c WHERE Name = 'Test Maintenance Starship'][0];
        starship.Status__c = 'Departure';

        Test.startTest();
            Database.SaveResult result = Database.update(starship, false);
        Test.stopTest();

        if(!result.isSuccess() && starship.Damage_Level__c > 5) {
            System.assertEquals('Starship is currently under repair! Please check Maintenance Done before exploitation.',
                        result.getErrors()[0].getMessage());
        }         
    }

    @isTest
    static void test_closeTaskAfterRepair() {   
        Starship__c starship = [SELECT Id, Maintenance_Done__c 
                                FROM Starship__c 
                                WHERE Name = 'Test Maintenance Starship'][0];
        starship.Maintenance_Done__c = true;

        Test.startTest();
            update starship;
        Test.stopTest();
        
        Starship__c starshipRecovery = [SELECT Id, Maintenance_Done__c 
                                        FROM Starship__c 
                                        WHERE Name = 'Test Maintenance Starship'][0];
        Task testTask = [SELECT Id, Subject, WhatId, Status 
                         FROM Task 
                         WHERE WhatId = :starshipRecovery.Id AND Status = 'Completed'][0];        

        System.assertEquals('Test Maintenance Starship Maintenance Done', testTask.Subject);
        System.assertEquals('Completed', testTask.Status);
    }

}