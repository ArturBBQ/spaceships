public class CloneFactory {
    
    public Integer cloneBatchSize = 9;

    public void cloneProductionForStation(Id stationId, String cloneType) {
        List<Contact> clonesToInsert = new List<Contact>();

        if(cloneType == 'Storm Trooper' || cloneType == 'Force Trooper' ||  cloneType == 'Scout Trooper') {
            for(Integer i = 1; i <= cloneBatchSize; i++) {
                Contact clone = new Contact();
                clone.LastName = cloneType + ' ' + i;
                clone.Mercenary_Rate__c	= 200;
                clone.Title = 'Clone';
                clone.Mercenary_Status__c = 'Available';
                clone.AccountId = stationId;
                clonesToInsert.add(clone);
            }
        }
        
        insert clonesToInsert;
    }

    public void crewMemberProduction(Id starshipId) {
        Starship__c currentStarship = [SELECT Current_Station__c, Crew_Size__c, Crew_Members__c 
                                       FROM Starship__c 
                                       WHERE Id =:starshipId];

        List<Contact> cloneList = [SELECT Name, Mercenary_Status__c 
                                   FROM Contact 
                                   WHERE Title = 'Clone' AND Mercenary_Status__c = 'Available' AND AccountId = :currentStarship.Current_Station__c];

        List<Crew_Member__c> crewMembersToInsert = new List<Crew_Member__c>();
        List<Contact> cloneListToUpdate = new List<Contact>();

        for(Contact clone : cloneList) {
            if(crewMembersToInsert.size() < (currentStarship.Crew_Size__c - currentStarship.Crew_Members__c)) {
                Crew_Member__c crewMember = new Crew_Member__c();
                crewMember.Mercenary_Id__c = clone.Id;
                crewMember.Starship_Id__c = starshipId;
                crewMember.Contract_Start_Date__c = Date.today();
                crewMember.Contract_End_Date__c = Date.today() + 7;       
                crewMembersToInsert.add(crewMember);  

                clone.Mercenary_Status__c = 'Busy';
                cloneListToUpdate.add(clone);
            }
        }
        insert crewMembersToInsert;
        update cloneListToUpdate;
    }
    
}