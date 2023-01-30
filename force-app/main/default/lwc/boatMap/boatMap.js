import { LightningElement, api, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
// LightningMessageChannel subscribe
// 1. Importing the named imports below
import { APPLICATION_SCOPE, createMessageContext, MessageContext, publish, releaseMessageContext, subscribe, unsubscribe } from 'lightning/messageService';
import BOATMC from '@salesforce/messageChannel/BoatMessageChannel__c';
// import BOATMC from the message channel

// Declare the const LONGITUDE_FIELD for the boat's Longitude__s
// Declare the const LATITUDE_FIELD for the boat's Latitude
// Declare the const BOAT_FIELDS as a list of [LONGITUDE_FIELD, LATITUDE_FIELD];
const LONGITUDE_FIELD = 'Boat__c.Geolocation__Longitude__s';
const LATITUDE_FIELD = 'Boat__c.Geolocation__Latitude__s';
const BOAT_FIELDS = [LONGITUDE_FIELD, LATITUDE_FIELD];
export default class BoatMap extends LightningElement {
  // private
  subscription = null;
  @api boatId;

  // Getter and Setter to allow for logic to run on recordId change
  // this getter must be public
  @api get recordId() {
    return this.boatId;
  }
  set recordId(value) {
    this.setAttribute('boatId', value);
    this.boatId = value;
  }
  

  error = undefined;
  mapMarkers = [];

  // Initialize messageContext for Message Service

  // Getting record's location to construct map markers using recordId
  // Wire the getRecord method using ('$boatId')
  @wire(getRecord, { recordId : '$boatId', fields: BOAT_FIELDS})
  wiredRecord({ error, data }) {
    // Error handling
    if (data) {
      console.log('boatMap data: ' + JSON.stringify(data));
      this.error = undefined;
      const longitude = data.fields.Geolocation__Longitude__s.value;
      const latitude = data.fields.Geolocation__Latitude__s.value;
      console.log('longitude: ' + longitude);
      console.log('latitude: ' + latitude);
      this.updateMap(longitude, latitude);
    } else if (error) {
      this.error = error;
      this.boatId = undefined;
      this.mapMarkers = [];
    }
  }

  // 2. wiring messageContext to a property
  @wire(MessageContext)
  messageContext;

  // Calls subscribeMC()
  connectedCallback() {
    console.log('connectedCallback boatMap');
    if(this.subscription || this.recordId){
      return;
    }
    this.subscribeMC();
  }

  // Subscribes to the message channel
  // 3. handling user input to subscribe
  // three parameters
  // 1. this.messageContext
  // 2. messageChannel BOATMC
  // 3. function to handle business logic
  subscribeMC() {
    // recordId is populated on Record Pages, and this component
    // should not update when this component is on a record page.
    // 4. subscribing to the message channel
    this.subscription = subscribe(this.messageContext, BOATMC, (message) => { this.handleMessage(message) }, { scope: APPLICATION_SCOPE });
    // Subscribe to the message channel to retrieve the recordId and explicitly assign it to boatId.
  }

  handleMessage(message){
    console.log('handleMessage object: ' + JSON.stringify(message));
    this.boatId = message.recordId;
  }

  // Creates the map markers array with the current boat's location for the map.
  updateMap(longitude, latitude) {
    console.log('updateMap');
    this.mapMarkers = [{
        location : {
            Latitude: latitude,
            Longitude: longitude
        }
    }];
    console.log('this.mapMarkers: ' + JSON.stringify(this.mapMarkers));
  }

  // Getter method for displaying the map component, or a helper method.
  get showMap() {
    return this.mapMarkers.length > 0;
  }
}