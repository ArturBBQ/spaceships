import { LightningElement, wire, api } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import CURRENT_STATION from '@salesforce/schema/Starship__c.Current_Station__c'; 
import CREW_SIZE from '@salesforce/schema/Starship__c.Crew_Size__c'; 
import CREW_MEMBERS from '@salesforce/schema/Starship__c.Crew_Members__c';  

export default class StarshipCrewContainer extends LightningElement {

    @api recordId;
    currentStationId;
    crewSize = 0;
    crewMembers = 0;
    progresBar = 0;
    showCandidates = true;
    errors;

    @wire(getRecord, {recordId: '$recordId', fields: [CURRENT_STATION, CREW_SIZE, CREW_MEMBERS] })
        starshipData({ data, error }) {
            if (data) {
                this.currentStationId = data.fields.Current_Station__c.value;
                this.crewSize = data.fields.Crew_Size__c.value;
                this.crewMembers = data.fields.Crew_Members__c.value;
                this.calculateTeamStatus(this.crewSize, this.crewMembers);
            }
            if (error) {
                this.errors = error;
            }
        }

    calculateTeamStatus(crewSize, crewMembers) {
        this.progresBar = crewMembers / crewSize * 100;
        this.showCandidates = (crewMembers == 0 || crewMembers < crewSize);
    }

    handleMessage(event){
        if(event.detail == 'Candidate added successfully'){
            this.crewMembers++;

            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: event.detail,
                    variant: 'success'
                })
            ); 
        } else {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Some problem',
                    message: event.detail,
                    variant: 'error'
                })
            );
        }

        this.calculateTeamStatus(this.crewSize, this.crewMembers);
    }

}