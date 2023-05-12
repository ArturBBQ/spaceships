@isTest
private class BookingFlightsController_Test {

    @TestSetup
    static void makeData(){

        Airport__c airport1 = new Airport__c(
            Name = 'Test Airport 1', 
            IATA__c = 'AAA', 
            Location__latitude__s = 37.7749, 
            Location__longitude__s = -122.4194);
        insert airport1;
        Airport__c airport2 = new Airport__c(
            Name = 'Test Airport 2', 
            IATA__c = 'BBB', 
            Location__latitude__s = 34.0522, 
            Location__longitude__s = -118.2437);
        insert airport2; 
    }
    
    @isTest
    static void test_getAirportsByCode() {

        Airport__c airport = [SELECT Name, IATA__c FROM Airport__c WHERE IATA__c = 'BBB'][0];

        Test.startTest();
            List<Airport__c> result1 = BookingFlightsController.getAirportsByCode('AA', airport.IATA__c);
            List<Airport__c> result2 = BookingFlightsController.getAirportsByCode('ZZ', airport.IATA__c);
            List<Airport__c> result3 = BookingFlightsController.getAirportsByCode('BB', airport.IATA__c);
        Test.stopTest();

        System.assertEquals(1, result1.size());
        System.assertEquals('AAA', result1[0].IATA__c);
        System.assertEquals(null, result2);
        System.assertEquals(null, result3);
    }

    @isTest
    static void test_saveFlight() {

        List<Airport__c> airports = [SELECT Id, Location__latitude__s, Location__longitude__s FROM Airport__c ORDER BY IATA__c];

        Test.startTest();
            BookingFlightsController.saveFlight(airports[0].Id, airports[1]);
        Test.stopTest();


        List<Flight__c> flights = [SELECT Departure_Airport__c, Arrival_Airport__c FROM Flight__c];

        System.assertEquals(1, flights.size());
        System.assertEquals(airports[0].Id, flights[0].Departure_Airport__c);
        System.assertEquals(airports[1].Id, flights[0].Arrival_Airport__c);
    }

    @isTest
    static void test_calculateDistance() {

        List<Airport__c> airports = [SELECT Location__latitude__s, Location__longitude__s FROM Airport__c ORDER BY IATA__c];

        Test.startTest();
            Decimal distance = BookingFlightsController.calculateDistance(
                airports[0].Location__latitude__s, 
                airports[0].Location__longitude__s,
                airports[1].Location__latitude__s,
                airports[1].Location__longitude__s
                );
        Test.stopTest();

        System.assert(distance!=0);
        System.assertNotEquals(distance, null);
    }

}
