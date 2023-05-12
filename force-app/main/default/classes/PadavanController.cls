public with sharing class PadavanController {

    @AuraEnabled
    public static User getCurrentUser() {
        User myUser = [SELECT Name FROM User WHERE Id = :UserInfo.getUserId()][0];
        return myUser;
    }

    @AuraEnabled
    public static Starship__c getStarshipData(String starshipId){
        System.debug('starshipId----' + starshipId);
        Starship__c st = [SELECT Id, Name FROM Starship__c WHERE ID = :starshipId][0];
        return st;
    }

}