import { api } from 'lwc';
import LightningModal from 'lightning/modal';

export default class FlightDetailsModal extends LightningModal {

    @api flightId;

    closeModal() {
        this.close({openDetails:false});
    }

    handleOpenFlight(){
        this.close({openDetails:true});
    }

}