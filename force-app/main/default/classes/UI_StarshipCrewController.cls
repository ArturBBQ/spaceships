public with sharing class UI_StarshipCrewController {

    @AuraEnabled(cacheable=true) // use cacheble=true only when reading data, NOT with a DML!
    public static List<Contact> getMercenariesContacts(String stationId) {
        List<Contact> mercenaries = [
            SELECT Id, FirstName, LastName, AvatarURL__c, Title, Phone, Mercenary_Rate__c 
            FROM Contact 
            WHERE AccountId = :stationId // to query only contacts linked to the Station (Account)
            AND Mercenary_Status__c = 'Available' 
        ];
        return mercenaries;
    }

    @AuraEnabled
    public static String addCandidateToCrew(String starshipId, String contactId) {
        Crew_Member__c crewMember = new Crew_Member__c(
            Mercenary_Id__c = contactId,
            Starship_Id__c = starshipId,
            Contract_Start_Date__c = Date.today()
        );
        Boolean isCrewFull = isCrewCompleted(starshipId);
        if (isCrewFull == true) {
            return 'Ship crew is complete, no need to create new candidates.';
        } else {
            try {
                insert crewMember;
                Contact contactToUpdate = [SELECT Id, Mercenary_Status__c FROM Contact WHERE Id = :contactId][0];
                contactToUpdate.Mercenary_Status__c = 'Busy';
                update contactToUpdate;
            } catch(Exception e) {
                throw new StarshipPageException(e.getMessage());
            }
            return 'Candidate added successfully';
        }
    }
    
    @TestVisible
    private static Boolean isCrewCompleted(String starshipId) {
        Starship__c starship = [SELECT Id, Crew_Size__c, Crew_Members__c FROM Starship__c WHERE Id = :starshipId][0];
        if(starship.Crew_Size__c > starship.Crew_Members__c) {
            return false;
        } else {
            return true;
        }
        
    }        

    public class StarshipPageException extends Exception {}

}