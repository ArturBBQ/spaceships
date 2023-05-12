@isTest
public class CloneFactory_Test {
    
    @TestSetup
    static void makeData() {
        Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Space_Station').getRecordTypeId();
        Account station = new Account(
            Name = 'Test Station', 
            RecordTypeId = recordTypeId, 
            Starships_Number_Max__c = 5);
        insert station;

        Starship__c starship = new Starship__c(
            Name = 'TIE FIGHTER 1', 
            Crew_Size__c = 5,
            Status__c = 'On Station',
            Current_Station__c = station.Id
        );
        insert starship;

        List<Contact> cloneList = new List<Contact>();
        for(Integer i=0; i<starship.Crew_Size__c+1; i++) {
            Contact clone = new Contact(
                LastName = 'Force Trooper ' + i, 
                Mercenary_Rate__c = 200, 
                Mercenary_Status__c = 'Available', 
                Title = 'Clone', 
                AccountId = station.Id
            );
            cloneList.add(clone);
        }
        insert cloneList;
    }

    @isTest 
    static void test_cloneProductionForStationPositive() { 
        Account station = [SELECT Id, Name FROM Account WHERE Name = 'Test Station'][0];
        
        Test.startTest(); 
            CloneFactory ctrl = new CloneFactory();
            Integer nmbOfClones = ctrl.cloneBatchSize;
            ctrl.cloneProductionForStation(station.Id, 'Scout Trooper');
        Test.stopTest(); 
        
        List<Contact> insertedClones = [SELECT Name, Title, Mercenary_Rate__c, Mercenary_Status__c, AccountId 
                                        FROM Contact 
                                        WHERE AccountId = :station.Id AND Name LIKE 'Scout Trooper%'];     

        System.assertEquals(nmbOfClones, insertedClones.size());
        
        for(Integer i = 1; i <= nmbOfClones; i++) {
            Contact clone = insertedClones[i-1];
            System.assertEquals('Scout Trooper ' + i, clone.Name);
            System.assertEquals('Clone', clone.Title);
            System.assertEquals(200, clone.Mercenary_Rate__c);
            System.assertEquals('Available', clone.Mercenary_Status__c);
            System.assertEquals(station.Id, clone.AccountId);
        }
    }

    @isTest 
    static void test_cloneProductionForStationNegative() { 
        Account station = [SELECT Id, Name FROM Account WHERE Name = 'Test Station'][0];
        
        Test.startTest(); 
            CloneFactory ctrl = new CloneFactory();
            Integer nmbOfClones = ctrl.cloneBatchSize;
            ctrl.cloneProductionForStation(station.Id, 'Invalid Type');
        Test.stopTest(); 
        
        List<Contact> insertedClones = [SELECT Name
                                        FROM Contact 
                                        WHERE AccountId = :station.Id AND Name LIKE 'Invalid%'];

        System.assertNotEquals(nmbOfClones, insertedClones.size(), 'We inserted Invalid Type for clones, so actual size will be 0');
        System.assert(insertedClones.size() == 0);
    }

    @isTest
    static void test_crewMemberProduction() {
        Starship__c starship = [SELECT Id, Name, Current_Station__c, Crew_Size__c, Crew_Members__c FROM Starship__c][0];

        Test.startTest();
            CloneFactory ctrl = new CloneFactory();
            ctrl.crewMemberProduction(starship.Id);
        Test.stopTest();

        List<Crew_Member__c> crewMembers = [SELECT Mercenary_Id__c, Starship_Id__c, Contract_Start_Date__c, Contract_End_Date__c 
                                            FROM Crew_Member__c 
                                            WHERE Starship_Id__c =:starship.Id];

        System.assertEquals(5, crewMembers.size());
        System.assertEquals(starship.Id, crewMembers[0].Starship_Id__c);
        System.assertEquals(Date.today(), crewMembers[0].Contract_Start_Date__c);
        System.assertEquals(Date.today() + 7, crewMembers[0].Contract_End_Date__c);

        List<Contact> updatedClones = [SELECT Mercenary_Status__c FROM Contact WHERE AccountId = :starship.Current_Station__c];

        System.assertEquals('Busy', updatedClones[0].Mercenary_Status__c);
        System.assertEquals('Busy', updatedClones[1].Mercenary_Status__c);
    }   

}