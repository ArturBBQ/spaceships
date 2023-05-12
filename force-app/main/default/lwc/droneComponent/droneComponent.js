import { LightningElement } from 'lwc';

export default class DroneComponent extends LightningElement {

    isShowDrone = false;

    handleShowDrone(event){
        this.isShowDrone = true;
    }

    value = '';

    get options() {
        return [
            { label: 'What is your name?', value: 'Name' },
            { label: 'What is your mission?', value: 'Mission' },
            { label: 'What`s up?', value: 'WhatsUp' },
        ];
    }

    handleQuestion(event) {
        let question = event.detail.value;

        if(question == 'Name') {
            this.value = 'Padavan';
        } else if(question == 'Mission') {
            this.value = 'Space Station' ;
        } else if(question == 'WhatsUp') {
            this.value = 'I`m ok';
        }  

        this.answerMessage(this.value);
    }

    answerMessage(answer){
        let componentEvent = new CustomEvent('droneanswer', {
            detail: answer
        });

        this.dispatchEvent(componentEvent);
    }

}