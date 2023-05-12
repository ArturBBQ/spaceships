import { LightningElement, api, track } from 'lwc';
import getAirportsByCode from '@salesforce/apex/BookingFlightsController.getAirportsByCode';
import saveFlight from '@salesforce/apex/BookingFlightsController.saveFlight';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import flightDetailsModal from "c/flightDetailsModal";

export default class SearchDestinationAirport extends NavigationMixin(LightningElement) {

    @api currentAirportId;
    @api currentAirportCode;
    isAirportFound = false;
    searchedAirportCode;
    searchResults;
    selectSearchedAirport;
    arrivalAirport = {};
    arrivalAirportName;
    @track arrivalAirportLocation;

    handleSearchChange(event) {
        this.isAirportFound = false;
        this.searchedAirportCode = event.target.value.toUpperCase();
        this.searchAirport();
    }

    searchAirport() {
        getAirportsByCode({
            airportCode: this.searchedAirportCode, 
            currentAirportCode: this.currentAirportCode 
        })
        .then((result) => {
            if(result !== null) {
                this.searchResults = result.map(element => ({
                    label: element.Name + ' (' + element.IATA__c + ')',
                    value: element.IATA__c
                })).sort((a, b) => a.label.localeCompare(b.label)); //case-insensitive sort by labels
                

                if(result.length === 1 && this.searchedAirportCode.length === 3) {
                    this.clearSearchResults();
                    this.isAirportFound = true;
                    this.arrivalAirport = result[0];
                    this.arrivalAirportName = result[0].Name;
                    this.arrivalAirportLocation = {
                        latitude: result[0].Location__Latitude__s,
                        longitude: result[0].Location__Longitude__s
                    }
                }

            } else {
                this.clearSearchResults();
            }
        })
        .catch(error => {
            console.error(error);
        });
    }

    renderedCallback() {
        if (this.arrivalAirportLocation) {
            this.template.querySelector('c-show-location-on-map').pinPointOnMap(
                this.arrivalAirportLocation.latitude, 
                this.arrivalAirportLocation.longitude
            );
            this.arrivalAirportLocation = null;
        }
    }

    clearSearchResults() {
        this.searchResults = null;
    }

    selectSearchResult(event) {
        let selectAirport = event.currentTarget.dataset.value;
        this.selectSearchedAirport = this.searchResults.find((element) => element.value === selectAirport);

        if(this.selectSearchedAirport) {
            this.searchedAirportCode = this.selectSearchedAirport.value;
            this.searchAirport();
        }
    }
    handleSave() {
        saveFlight({ 
            departureAirportId: this.currentAirportId,
            arrivalAirport: this.arrivalAirport
        })
        .then((result) => {
            this.handleShowToastEvent(
                'Success', 
                'Distance from your Airport to "' + this.arrivalAirportName + '": ' + Math.round(result.Distance__c) + ' km', 
                'success'
            );
            setTimeout(() => {
                this.handleOpenModal(result.Id);
            }, 1500);
        })
        .catch((error) => {
            console.error(error);
            this.handleShowToastEvent(
                'Error', 
                'Oops! Something went wrong: ' + error.body.message, 
                error
            );
        });
    }

    handleShowToastEvent(title, message, variant){
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: message,
                variant: variant
            })
        );
    }
      
    handleOpenModal(flightId) {
        flightDetailsModal.open({
            size: 'small',
            flightId: flightId
        })
        .then((result) => {
            if(result && result.openDetails){
                this[NavigationMixin.Navigate]({
                    type: 'standard__recordPage',
                    attributes: {
                        recordId: flightId,
                        objectApiName: 'Flight__c',
                        actionName: 'view'
                    },
                });
            }                
        })
    }

}