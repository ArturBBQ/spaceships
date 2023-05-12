import { LightningElement, api } from 'lwc';

export default class LightSaberLWC extends LightningElement {

    @api swordColor;


    isColorBlue = false;
    isColorGreen = false;
    isColorRed = false;

    switchColor(event) {
        let color = event.target.label;
        console.log('color--->' + color);

        this.swordColor = color;

        if (this.swordColor == 'Blue'){
            this.isColorBlue = true;
            this.isColorGreen = false;
            this.isColorRed = false;
        } else if (this.swordColor == 'Green'){
            this.isColorGreen = true;
            this.isColorBlue = false;
            this.isColorRed = false;
        } else if (this.swordColor == 'Red'){
            this. isColorRed = true;
            this.isColorBlue = false;
            this.isColorGreen = false;
        }
    }

    /* get isColorBlue(){
        return this.isColorBlue == 'Blue';
    } */

}