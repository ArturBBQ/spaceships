import { LightningElement, api, wire } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import NAME_FIELD from '@salesforce/schema/Airport__c.Name';
import IATA_FIELD from '@salesforce/schema/Airport__c.IATA__c';

const FIELDS = [NAME_FIELD, IATA_FIELD];

export default class AirportInfo extends LightningElement {

    @api recordId;

    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    currentAirport;

    get currentAirportName() {
        return getFieldValue(this.currentAirport.data, NAME_FIELD);
    }

    get currentAirportCode() {
        return getFieldValue(this.currentAirport.data, IATA_FIELD);
    }
      
}
