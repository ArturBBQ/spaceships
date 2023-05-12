public with sharing class StarshipNewController {

    @AuraEnabled
    public static Starship__c createNewStarship(Starship__c starship) {
        insert starship;
        return starship;
    }

}
