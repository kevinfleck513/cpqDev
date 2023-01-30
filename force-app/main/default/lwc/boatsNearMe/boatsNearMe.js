// imports
import { LightningElement, api, wire, track } from 'lwc';
import getBoatsByLocation from '@salesforce/apex/BoatDataService.getBoatsByLocation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const LABEL_YOU_ARE_HERE = 'You are here!';
const ICON_STANDARD_USER = 'standard:user';
const ERROR_TITLE = 'Error loading Boats Near Me';
const ERROR_VARIANT = 'error';
const BOAT_ICON = 'utility:anchor';

export default class BoatsNearMe extends LightningElement {
  @api boatTypeId;
  mapMarkers = [];
  isLoading = true;
  isRendered;
  latitude;
  longitude;
  
  // Add the wired method from the Apex Class
  // Name it getBoatsByLocation, and use latitude, longitude and boatTypeId
  // Handle the result and calls createMapMarkers
  @wire(getBoatsByLocation, {
                            latitude   : '$latitude',
                            longitude  : '$longitude',
                            boatTypeId : '$boatTypeId'
                            })
  wiredBoatsJSON({error, data}) {
      if(data){
          console.log('boatsNearMe data: ' + JSON.stringify(data));
          console.log('typeOf boatsNearMe data: ' + typeof(data));
          let parsedData = JSON.parse(data);
          console.log('parsed data: ' + JSON.stringify(parsedData));
          console.log('typeof parsed data: ' + typeof(parsedData));
          this.createMapMarkers(parsedData);
      } else if(error){
        this.dispatchEvent(new ShowToastEvent({
                title: ERROR_TITLE,
                message: error.body.message,
                variant: ERROR_VARIANT
            })
        );            
        this.data = undefined;
        this.isLoading = false;
      }
  }
  
  // Controls the isRendered property
  // Calls getLocationFromBrowser()
  renderedCallback() {
    console.log('>>> in rendered callback');
    if(!this.isRendered){
        this.getLocationFromBrowser();
    }
    //sets true once the location is fetched
    this.isRendered = true;
  }
  
  // Gets the location from the Browser
  // position => {latitude and longitude}
  getLocationFromBrowser() {
    //accessing getCurrentPosition method
    navigator.geolocation.getCurrentPosition((position)=> {
        //success callback
        console.log('>>>positions' + position);
        // let currentLocation = {
        //     location : {
        //         Latitude: position.coords.latitude,
        //         Longitude: position.coords.longitude
        //     },
        //     title : 'My location'
        // };
        this.latitude = position.coords.latitude;
        this.longitude = position.coords.longitude;
        console.log('latitude: ' + this.latitude);
        console.log('longitude: ' + this.longitude);
        // this.mapMarkers = [currentLocation];
    }, (error) => {
        //error callback
        // console.log('error: ' + error.body.message);
    }, {
        enableHighAccuracy : true
        }
    );
    // this.isLoading = false;
  }
  
  // Creates the map markers
  createMapMarkers(boatData) {
    console.log('createMapMarkers');
    console.log('typeOf boatdata: ' + typeof(boatData));
    console.log('passed boatData: ' + JSON.stringify(boatData));
    if(boatData){
    this.mapMarkers = boatData.map(boat => {
        return {
            location: {
                Latitude : boat.Geolocation__Latitude__s,
                Longitude : boat.Geolocation__Longitude__s
            },
            title : boat.Name,
            icon : BOAT_ICON,
        };
    });
    this.mapMarkers.unshift({
        location : {
            Latitude  : this.latitude,
            Longitude : this.longitude
        },
        title: LABEL_YOU_ARE_HERE,
        icon: ICON_STANDARD_USER
    });
    console.log('mapMarkers: ' + JSON.stringify(this.mapMarkers));
    this.isLoading = false;
    } else {
        console.log('createMapMarkers error');
    }
   }
}