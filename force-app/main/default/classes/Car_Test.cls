@isTest
public class Car_Test {

    @isTest
    static void test_CarGo(){
        Car tesla = new Car('Red', 'Tesla Model S', true);
        Integer roadTime = tesla.go(400, 200);
        
        System.assert(roadTime == 2, 'Method should return 2 hours - Integer');
        System.assertEquals(2, roadTime, 'Method should return 2 hours - Integer');

    }

    @isTest
    static void test_ChargeLevel() {
        Car car = new Car('Red', 'Tesla Model S', true);

        String result = car.chargeLevel(200);
        System.assertEquals('BATTERY LEVEL: 60%', result);
        
        car.batteryLevel = 100;
        String result2 = car.chargeLevel(450);
        System.assertEquals('BATTERY LOW: 10%', result2);

        car.batteryLevel = 100;
        String result3 = car.chargeLevel(470);
        System.assertEquals('CAR STOP: 6%', result3);
    }

}
