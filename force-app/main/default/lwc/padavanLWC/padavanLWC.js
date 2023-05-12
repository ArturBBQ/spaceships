import { LightningElement } from 'lwc';

export default class PadavanLWC extends LightningElement {

    saberColor = 'Blue';

    padavanName = 'Paste Name';
    padavanSkill;

    changeHandler(event) {
        this.padavanName = event.target.value;
    }

    handleClickReWrite(event) {
        if (this.padavanSkill == null ){
            this.padavanSkill = 'noob';
        } else if (this.padavanSkill == 'noob') {
            this.padavanSkill = 'trainee';
        } else if (this.padavanSkill == 'trainee') {
            this.padavanSkill = 'master';
        }
    }

    handleResetSkill(event) {
        this.padavanSkill = 'noob';
    }

    droneAnswerHandler(event) {
        let droneAnswer = event.detail;
        console.log('droneAnswer --->' + droneAnswer);
    }

}