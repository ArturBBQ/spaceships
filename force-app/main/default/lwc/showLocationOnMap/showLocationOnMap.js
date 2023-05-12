import { LightningElement,api } from 'lwc';

export default class ShowLocationOnMap extends LightningElement {

    mapMarkers = [];
    
    @api 
    pinPointOnMap(latitude, longitude) {
        
        this.mapMarkers = [
            {
                location: {
                    Latitude: latitude,
                    Longitude: longitude,
                },
            },
        ];
    } 

}