import { LightningElement, api, wire, track } from 'lwc';
import getBoatTypes from '@salesforce/apex/BoatDataService.getBoatTypes';

// imports
// import getBoatTypes from the BoatDataService => getBoatTypes method';
export default class BoatSearchForm extends LightningElement {
    
    @api passedBoat;
    selectedBoatTypeId = '';
    
    // Private
    @api error = undefined;
    
    @track searchOptions;
    label;
    value = '';
    
    // Wire a custom Apex method
    @wire (getBoatTypes)
      boatTypes({ error, data }) {
      if (data) {
        console.log('data.length = ' + data.length);
        if(data.length == 0){
          console.log('no data returned');
        } else {
        console.log('data: ' + JSON.stringify(data));
        console.log('data typeOf: ' + typeof(data));
        }
        this.searchOptions = data.map(type => {
          return{
            label:type.Name,
            value: type.Id
          };
        });
        // this.searchOptions = data.map(function(type) {
        //   return{
        //     label:type.Name,
        //     value: type.Id
        //   };
        // });
        this.searchOptions.unshift({ label: 'All Types', value: '' });
      } else if (error) {
        console.log('error getting data: ' + error);
        this.searchOptions = undefined;
        this.error = error;
      }
    }
    
    // Fires event that the search option has changed.
    // passes boatTypeId (value of this.selectedBoatTypeId) in the detail
    handleSearchOptionChange(event) {

      // Create the const searchEvent
      // searchEvent must be the new custom event search

      this.selectedBoatTypeId = event.detail.value;
      const searchEvent = new CustomEvent('search', {
        detail: {
          boatTypeId: this.selectedBoatTypeId
        }
      });
      console.log('selectedBoatTypeId value: ' + this.selectedBoatTypeId);
      this.dispatchEvent(searchEvent);
    }
  }