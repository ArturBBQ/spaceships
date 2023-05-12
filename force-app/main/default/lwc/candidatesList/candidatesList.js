import { LightningElement, wire, api} from 'lwc';

import getContacts from '@salesforce/apex/UI_StarshipCrewController.getMercenariesContacts';

export default class CandidatesList extends LightningElement {

    @api stationId; 
    contacts;
    
    @wire(getContacts, { stationId: '$stationId' })
        wiredContacts({ data }) {
            this.contacts = data;
        }
    
}