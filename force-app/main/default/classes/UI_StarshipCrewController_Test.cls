@isTest
private class UI_StarshipCrewController_Test {

    @TestSetup
    static void makeData(){
        Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
                                .get('Space_Station').getRecordTypeId();
        Account station = new Account(
            Name = 'Base Station',
            RecordTypeId = recordTypeId,
            Starships_Number_Max__c = 10);
        insert station;
        
        Id contactRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName()
                                        .get('Mercenary').getRecordTypeId();
        Contact contact1 = new Contact(
            LastName = 'Robot Available',
            AccountId=station.Id,
            Mercenary_Status__c='Available',
            RecordTypeId = contactRecordTypeId, 
            Mercenary_Rate__c = 100);
        insert contact1;

        Contact contact2 = new Contact(
            LastName = 'Robot Busy',
            AccountId=station.Id,
            Mercenary_Status__c='Busy',
            RecordTypeId = contactRecordTypeId, 
            Mercenary_Rate__c = 100);
        insert contact2;

        Starship__c starship = new Starship__c(
            Name = 'Test Ship',
            Current_Station__c = station.Id,
            Crew_Size__c = 1,
            Status__c = 'On Station');
        insert starship;
    }
    
    @isTest 
    static void test_getMercenariesContacts() {
        Account station = [SELECT Id,Name FROM Account WHERE Name = 'Base Station'][0];
        
        Test.startTest();
            List<Contact> mercenaries = UI_StarshipCrewController.getMercenariesContacts(station.Id);
        Test.stopTest();
        
        System.assertEquals(1, mercenaries.size());
        System.assertEquals('Robot Available', mercenaries[0].LastName);
    }


    @isTest 
    static void test_addCandidateToCrew() {
        Account station = [SELECT Id, Name FROM Account WHERE Name = 'Base Station'][0];
        Contact contact = [SELECT Id FROM Contact WHERE Mercenary_Status__c = 'Available'][0];
        Starship__c starship = [SELECT Id, Name FROM Starship__c WHERE Name = 'Test Ship'][0];

        String starshipId = starship.Id;
        String contactId = contact.Id;
        
        Test.startTest();
            String result = UI_StarshipCrewController.addCandidateToCrew(starshipId, contactId);
        Test.stopTest();
        
        System.assertEquals('OK', result);
        List<Crew_Member__c> crewMembers = [SELECT Id, Mercenary_Id__c, Starship_Id__c, Contract_Start_Date__c FROM Crew_Member__c];
        System.assertEquals(1, crewMembers.size());
        System.assertEquals(contactId, crewMembers[0].Mercenary_Id__c);
        System.assertEquals(starshipId, crewMembers[0].Starship_Id__c);
        
        Contact updatedContact = [SELECT Id, Mercenary_Status__c FROM Contact WHERE Id = :contactId];
        System.assertEquals('Busy', updatedContact.Mercenary_Status__c);
    }

    @isTest static void test_isCrewCompleted() {

        Account station = [SELECT Id, Name FROM Account WHERE Name = 'Base Station'][0];
        Contact contact1 = [SELECT Id FROM Contact WHERE Mercenary_Status__c = 'Available'][0];
        Starship__c starship = [SELECT Id, Name FROM Starship__c WHERE Name = 'Test Ship'][0];
        
        Boolean isComplete = UI_StarshipCrewController.isCrewCompleted(starship.Id);
        System.assertEquals(false, isComplete);
        
        String starshipId = starship.Id;
        String contactId = contact1.Id;

        Test.startTest();
            UI_StarshipCrewController.addCandidateToCrew(starshipId, contactId);
            isComplete = UI_StarshipCrewController.isCrewCompleted(starshipId);
        Test.stopTest();
        
        System.assertEquals(true, isComplete);
    }

}