import { LightningElement, api, wire, track } from 'lwc';
import getBoats from '@salesforce/apex/BoatDataService.getBoats';
import updateBoatList from '@salesforce/apex/BoatDataService.updateBoatList';
import { refreshApex } from '@salesforce/apex';
// LightningMessageChannel publish
// 1. Importing the named imports below
import { publish, MessageContext } from 'lightning/messageService';
import BOATMC from '@salesforce/messageChannel/BoatMessageChannel__c';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
const SUCCESS_TITLE = 'Success';
const MESSAGE_SHIP_IT = 'Ship it!';
const SUCCESS_VARIANT = 'success';
const ERROR_TITLE = 'Error';
const ERROR_VARIANT = 'error';



export default class BoatSearchResults extends LightningElement {
  @api selectedBoatId = '';
  columns = [
    {label: 'Name', fieldName: 'Name', editable: true},
    {label: 'Length', fieldName: 'Length__c', type: 'number'},
    {label: 'Price', fieldName: 'Price__c', type: 'currency'},
    {label: 'Description', fieldName: 'Description__c', editable: true}
  ];
  boatTypeId = '';
  @track boats;
  isLoading = false;
  @track draftValues;
  boatTypeId = '';
  showSomething;
  error = undefined;
  
  // wired message context
  // 2. Wiring the MessageContet to a property
  @wire(MessageContext)
  messageContext;

  // public function that updates the existing boatTypeId property
  // uses notifyLoading
  @api
  searchBoats(boatTypeId) {

    console.log('boatSearchResults event called');
    console.log('boatTypeId: ' + boatTypeId);

    this.isLoading = true;
    this.notifyLoading(this.isLoading);
    this.boatTypeId = boatTypeId;
    //this.wiredBoats(boatTypeId);

  }

  // wired getBoats method
  @wire (getBoats, { boatTypeId: '$boatTypeId' })
  wiredBoats(data, error){    
    if(error){
      this.error = result.error;
      this.boats = undefined;
    } else if(data){
      console.log('data: ' + JSON.stringify(data));
      // this.showSomething = JSON.stringify(this.boats.data);
      this.boats = data;
    }    
  }
  
  // this public function must refresh the boats asynchronously
  // uses notifyLoading
  async refresh() {
    this.isLoading = true;
    this.notifyLoading(this.isLoading);
    await refreshApex(this.boats);
    this.isLoading = false;
    this.notifyLoading(this.isLoading);
  }
  
  // this function must update selectedBoatId and call sendMessageService
  updateSelectedTile(event) {

    console.log('updateSelectedTile called');
    console.log('selectedBoatId: ' + event.detail.boatId);
    this.selectedBoatId = event.detail.boatId;
    // 3. Handling the user input, which in our case comes from previously passed component scoped events carrying selectedBoatId
    this.sendMessageService(this.selectedBoatId);

  }
  
  // Publishes the selected boat Id on the BoatMC.
  sendMessageService(boatId) { 
    console.log('sendMessageService')
    // explicitly pass boatId to the parameter recordId
    // 4. Publishing the message
    publish(this.messageContext, BOATMC, { recordId: boatId });
    // 3 parameters
    // 1. wired message context this.messageContext
    // 2. message channel BOATMC
    // 3. actual message passing parameters, fieldName in messageService xml file
  }
  
  // The handleSave method must save the changes in the Boat Editor
  // passing the updated fields from draftValues to the 
  // Apex method updateBoatList(Object data).
  // Show a toast message with the title
  // clear lightning-datatable draft values
  handleSave(event) {
    // notify loading
    const updatedFields = event.detail.draftValues;
    // Update the records via Apex
    updateBoatList({data: updatedFields})
    .then(result => {
      console.log(`updateBoatList result: ${result}`);
      const toast = new ShowToastEvent({
        title: SUCCESS_TITLE,
        message: MESSAGE_SHIP_IT,
        variant: SUCCESS_VARIANT,
    });
    this.dispatchEvent(toast);
      this.draftValues = [];
      return this.refresh();
    })
    .catch(error => {
      const toast = new ShowToastEvent({
        title: ERROR_TITLE,
        message: error.message,
        variant: ERROR_VARIANT,
    });
    this.dispatchEvent(toast);
    })
    .finally(() => {});
  }
  // Check the current value of isLoading before dispatching the doneloading or loading custom event
  notifyLoading(isLoading) {
    if(isLoading){
      this.dispatchEvent(new CustomEvent('loading'));
    } else {
      this.dispatchEvent(new CustomEvent('doneloading'));
    }
  }

  showToast(title, message, variant){
    this.dispatchEvent(new ShowToastEvent({
        title, message, variant
    }));
  }
}