@isTest
public with sharing class StarshipNewController_Test {

    @isTest
    static void test_createNewStarship() {

        Account station = new Account(Name = 'Base Station Test', Starships_Number_Max__c = 5);
        insert station;
        
        Starship__c newStarship = new Starship__c(Name = 'Test Starship', Crew_Size__c = 2, Current_Station__c = station.Id);

        Test.startTest();

        Starship__c returnedStarship = StarshipNewController.createNewStarship(newStarship);

        System.assert(returnedStarship.Id != null);
        System.assertEquals(newStarship.Name, returnedStarship.Name);
        System.assertEquals(newStarship.Crew_Size__c, returnedStarship.Crew_Size__c);

        Test.stopTest();
        
    }
}