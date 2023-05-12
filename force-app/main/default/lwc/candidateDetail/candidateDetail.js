import { LightningElement, api } from 'lwc';

import addCandidateToCrew from '@salesforce/apex/UI_StarshipCrewController.addCandidateToCrew';

import APP_EVENT from '@salesforce/messageChannel/SelectedContactEvent__c';
import {createMessageContext, releaseMessageContext, APPLICATION_SCOPE, subscribe, unsubscribe} from 'lightning/messageService';

export default class CandidateDetail extends LightningElement {

    @api starshipId;
    @api contact;

    addCandidate(event){
        addCandidateToCrew({ starshipId: this.starshipId, contactId: this.contact.Id })
        .then(result => {  
            this.sendComponentEvent(result);
        })
        .catch(error => {
            this.sendComponentEvent(error.body.message);
        });
        
    }

    sendComponentEvent(message){
        const selectMessage = new CustomEvent('message', {
            detail: message
        });
        this.dispatchEvent(selectMessage);
    }

    // ==================== APP EVENTS LOGIC ==================
    
    // нижче декілька функцій для реєстрації канала звʼязку
    context = createMessageContext();
    connectedCallback() {
        this.subscribeToMessageChannel();
    }

    subscribeToMessageChannel() {

        console.log('----subscribe----');

        if (!this.subscription) {
            this.subscription = subscribe(
                this.context,
                APP_EVENT,
                (message) => this.handleMessage(message),
                { scope: APPLICATION_SCOPE }
            );
        }
    }

    // в цій функції ми отримуємо повідомлення з події
    handleMessage(message) {
        this.contact = message.contactMessage;
    }


    // отримати імʼя контакта, який ми отримали з повідомлення
    get contactName(){
        return (this.contact)? 
            this.contact.LastName + ', ' + this.contact.FirstName : '';
    }

}