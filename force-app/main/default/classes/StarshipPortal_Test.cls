@isTest
public class StarshipPortal_Test {

    @TestSetup
    static void makeData() {
        Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Space_Station').getRecordTypeId();
        Account station1 = new Account(Name = 'Base Station Test', RecordTypeId = recordTypeId, Starships_Number_Max__c = 5);
        insert station1;
        
        Account station2 = new Account(Name = 'Moon 1 Test', RecordTypeId = recordTypeId, Starships_Number_Max__c = 8);
        insert station2;

        Starship__c starship = new Starship__c(Name = 'Starship Test', Crew_Size__c = 5, Current_Station__c = station1.Id);
        insert starship;
    }

    @isTest 
    static void test_findEmptyStations() {
        
        Test.startTest();
            StarshipPortal ctrl = new StarshipPortal();
            Map<Id, Account> emptyStations = ctrl.findEmptyStations();
        Test.stopTest();

        System.assertEquals(1, emptyStations.size(), 'Expected 1 empty station');
    }

    @isTest 
    static void test_sendStarshipsPositive() {
        Account station = [SELECT Id, Name, Starships_Number_Max__c FROM Account WHERE Name = 'Moon 1 Test'][0];
        Integer numberOfStarships = 5;

        Test.startTest();
            StarshipPortal ctrl = new StarshipPortal();
            ctrl.sendStarships(station.Id, numberOfStarships);
        Test.stopTest();
        
        List<Account> stations = [SELECT Id, Name, Starships_Number_Max__c FROM Account];

        List<Starship__c> starships = [SELECT Id, Name, Crew_Size__c, Current_Station__c
                                       FROM Starship__c 
                                       WHERE Current_Station__c = :station.Id];

        System.assertEquals(numberOfStarships, starships.size());
    }

    @isTest 
    static void test_sendStarshipsNegative() {
        Account station = [SELECT Id, Name, Starships_Number_Max__c FROM Account WHERE Name = 'Base Station Test'][0];
        Integer numberOfStarships = 5;

        Test.startTest();
            StarshipPortal ctrl = new StarshipPortal();
            ctrl.sendStarships(station.Id, numberOfStarships);
        Test.stopTest();

        List<Starship__c> starships = [SELECT Id, Name, Crew_Size__c, Current_Station__c 
                                       FROM Starship__c 
                                       WHERE Current_Station__c = :station.Id];
        System.assertNotEquals(numberOfStarships, starships.size(), 'Because of this station was not Empty');
    }

}