public class StarshipPortal {

    public StarshipPortal() {
        findEmptyStations();
    }

    public Map<Id, Account> findEmptyStations() {
        List<Account> allStations = [SELECT Id, Name, Starships_Number_Max__c, (SELECT Name FROM Starships__r) 
                                     FROM Account 
                                     WHERE RecordType.DeveloperName = 'Space_Station'];
                                     
        Map<Id, Account> emptyStations = new Map<Id, Account>();

        for (Account station : allStations) {
            if(station.Starships__r.size() == 0){
                emptyStations.put(station.Id, station);
            }
        }
        return emptyStations;
    }

   public void sendStarships(Id stationId, Integer numberOfStarships) {
        Map<Id, Account> emptyStationsMap = findEmptyStations();
        Account curStation = emptyStationsMap.get(stationId);

        List<Starship__c> tieFightersToInsert = new List<Starship__c>();

        if(curStation != null && numberOfStarships <= curStation.Starships_Number_Max__c) {
            for (Integer i = 1; i <= numberOfStarships; i++) {
                tieFightersToInsert.add(new Starship__c(
                    Name = 'TIE FIGHTER ' + i,
                    Crew_Size__c = 8,
                    Current_Station__c = stationId
                ));
            }
        }
        
        if (!tieFightersToInsert.isEmpty()) {
            insert tieFightersToInsert;
        }
    } 

}