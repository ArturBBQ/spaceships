public class Car {

    public String model; // null 
    private String color = 'Black'; 
    public Boolean isElectricVehicle;
    public Integer batteryLevel = 100; // %
    @testVisible
    private Integer fullBatteryCharge = 500; // km
    
    public Car() { // constructor - визиваємо new Car();
        System.debug('constructor1--init--------' + this.color);
    }

    // method overloading - перезавантаження конструктора з іншими параметрами
    public Car(String carColor, String model, Boolean isElectic) { 
        System.debug('constructor2--init--------');

        this.model = model;
        this.color = carColor;
        this.isElectricVehicle = isElectic;

        this.carInfo();
    }

    private void carInfo(){ // void - пустота
        String carInfo = (this.isElectricVehicle) ? 'EV ' + this.model + ' ' + this.color : this.model + ' ' + this.color;

        System.debug('Car Info : ' + carInfo);
    }


    public static String carStart(){
        String status = 'Let\'s go!';
        return status; // повернення
    }


    public Integer go(Integer distance, Integer speed){

        System.debug('isElectricVehicle---- ' + this.isElectricVehicle);

        if(this.isElectricVehicle){
            String evCharge = this.chargeLevel(distance);
            System.debug('EV Charge Left: ' + evCharge);
        }
   
        Integer roadTime = distance / speed;

        return roadTime;
    }

    @testVisible
    private String chargeLevel(Integer distance){  

        Integer chargeUsage = (distance * 100) / this.fullBatteryCharge; 
        this.batteryLevel = this.batteryLevel - chargeUsage;      

        String chargeMessage;
    
        if(this.batteryLevel < 20 && this.batteryLevel >= 10) {
            chargeMessage = 'BATTERY LOW: ' + this.batteryLevel + '%';
        }else if(this.batteryLevel < 10){
            chargeMessage = 'CAR STOP: ' + this.batteryLevel + '%';
        }else{
            chargeMessage = 'BATTERY LEVEL: ' + this.batteryLevel + '%';
        }
        return chargeMessage;
    }  

}