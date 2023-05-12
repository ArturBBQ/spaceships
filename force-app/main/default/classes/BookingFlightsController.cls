public with sharing class BookingFlightsController {

    @AuraEnabled
    public static List<Airport__c> getAirportsByCode(String airportCode, String currentAirportCode) {
        String query = 'SELECT Name, IATA__c, Location__latitude__s, Location__longitude__s' 
                      +' FROM Airport__c' 
                      +' WHERE IATA__c LIKE \'%' + airportCode + '%\' AND IATA__c != :currentAirportCode';
        List<Airport__c> airports = Database.query(query);
        if (airports.isEmpty()) {
            return null;
        }
        return airports;
    }

    @AuraEnabled
    public static Flight__c saveFlight(String departureAirportId, Airport__c arrivalAirport) {
        
        Airport__c departureAirport = [SELECT Id, Location__latitude__s, Location__longitude__s 
                                       FROM Airport__c 
                                       WHERE Id = :departureAirportId][0];

        Decimal distance = calculateDistance(departureAirport.Location__latitude__s, departureAirport.Location__longitude__s, 
                                             arrivalAirport.Location__latitude__s, arrivalAirport.Location__longitude__s);
        try{
            Flight__c newFlight = new Flight__c(
                Departure_Airport__c = departureAirportId,
                Arrival_Airport__c = arrivalAirport.Id,
                Status__c = 'Scheduled Flight',
                Distance__c = distance
            );
            insert newFlight;
            return newFlight;
        }catch(Exception e){
            System.debug('Error while saving the flight: ' + e.getMessage());
        }
        return null;
    }

    @TestVisible
    private static Decimal calculateDistance(Decimal airport1Latitude, Decimal airport1Longitude, 
                                            Decimal airport2Latitude, Decimal airport2Longitude) {
        Integer earthRadius = 6371;
        // Transform coordinates from degrees to radians Decimal 
        Decimal latitudeRadians1 = airport1Latitude * Math.PI/180; 
        Decimal latitudeRadians2 = airport2Latitude * Math.PI/180;
        // Latitude and longitude differences in radians 
        Decimal latitudeDelta = (airport2Latitude - airport1Latitude) * Math.PI/180; 
        Decimal longitudeDelta = (airport2Longitude - airport1Longitude) * Math.PI/180;

        Decimal a = Math.sin(latitudeDelta / 2) * Math.sin(latitudeDelta / 2) + 
                    Math.cos(latitudeRadians1) * Math.cos(latitudeRadians2) * 
                    Math.sin(longitudeDelta / 2) * Math.sin(longitudeDelta / 2);

        Decimal arc = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));

        Decimal distance = earthRadius * arc;

        return distance;
    }

}