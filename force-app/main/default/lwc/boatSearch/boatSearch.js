import { LightningElement, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

 // imports
 export default class BoatSearch extends NavigationMixin(LightningElement) {
    @track isLoading = false;
    
    // Handles loading event
    handleLoading() {
      console.log('onLoading');
      this.isLoading = true;
    }
    
    // Handles done loading event
    handleDoneLoading() {
      console.log('onDoneLoading');
      this.isLoading = false;
    }
    
    // Handles search boat event
    // This custom event comes from the form
    searchBoats(event) {

      const boatTypeId = event.detail.boatTypeId;
      console.log('event caught: ' + boatTypeId);
      this.template.querySelector("c-boat-search-results").searchBoats(boatTypeId);
      

    }
    
    createNewBoat() {
      this[NavigationMixin.Navigate]({
        type: 'standard__objectPage',
        attributes: {
            objectApiName: 'Boat__c',
            actionName: 'new'
        }
      });
    }

    // newBoat(event){
    //   console.log('event.target.label: ' + event.target.label);
    // }
  }