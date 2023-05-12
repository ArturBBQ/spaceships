/* List<Account> stations = [SELECT Id, Name, (SELECT Name FROM Starships__r) 
                        FROM Account 
                        WHERE RecordType.DeveloperName = 'Space_Station' ];
System.debug('stations ----- ' + stations);

List<Starship__c> starshipToInsert = new List<Starship__c>();

for(Account acc :stations) {
    if(acc.Starships__r.size() == 0) {
        Starship__c tieFighter = new Starship__c();
        tieFighter.Name = 'TIE Fighter';
        tieFighter.Crew_Size__c = 8;
        tieFighter.Current_Station__c = acc.Id;
        starshipToInsert.add(tieFighter);
    }
}

insert starshipToInsert; */

/* List<Account> stations = [SELECT Id, Name, (SELECT Name FROM Starships__r) 
                            FROM Account 
                            WHERE RecordType.DeveloperName = 'Space_Station' ];
System.debug('stations ----- ' + stations);

List<Starship__c> starships = [SELECT Id, Name FROM Starship__c]; */

/*   
List<Starship__c> starships = [SELECT Id, Name FROM Starship__c WHERE Name LIKE 'TIE FIGHTER%'];
System.debug('---starships---' + starships);
delete starships;
 */

/* 
Car check = new Car('Yellow', 'TeslaY');
String batteryLevelEX = check.checkBatteryLevel(450);
System.debug('---batteryLevelEX---' + batteryLevelEX); 
*/

 
/* 
StarshipPortal sp = new StarshipPortal();
sp.sendStarships('0016800000OWyMhAAL', 5);
 */

/* 
List<Contact> con = [SELECT Id, Name, Title FROM Contact WHERE Title = 'Clone'];
System.debug('---con---' + con);
delete con;
 */

/*  
 CloneFactory cf = new CloneFactory();
 cf.cloneProductionForStation('0016800000M6DmVAAV', 'Storm Trooper'); // Agamar
 cf.crewMemberProduction('a0268000002asnZAAQ');
 */