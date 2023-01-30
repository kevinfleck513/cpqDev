import { LightningElement, api, wire, track } from 'lwc';
const TILE_WRAPPER_SELECTED_CLASS = "selected tile-wrapper";
const TILE_WRAPPER_UNSELECTED_CLASS = "tile-wrapper";


export default class BoatTile extends LightningElement {
    @api boat;
    @api selectedBoatId;
    selectedBoat;
    
    // Getter for dynamically setting the background image for the picture
    get backgroundStyle() {
      return `background-image:url(${this.boat.Picture__c})`;
    }
    
    // Getter for dynamically setting the tile class based on whether the
    // current boat is selected
    get tileClass() {
      console.log('tileClass selectedBoatId: ' + this.selectedBoatId);
      console.log('tileClass selectedBoat: ' + this.selectedBoat);
      console.log('tileClass selectedBoat == selectedBoatId: ' + this.selectedBoat == this.selectedBoat ? true : false);
      // if(this.selectedBoatId == this.selectedBoat){
      //   return TILE_WRAPPER_SELECTED_CLASS;
      // } else {
      //   return TILE_WRAPPER_UNSELECTED_CLASS;
      // }
      return this.selectedBoatId == this.selectedBoat ? TILE_WRAPPER_SELECTED_CLASS : TILE_WRAPPER_UNSELECTED_CLASS;
    }
    
    // Fires event with the Id of the boat that has been selected.
    selectBoat(event) { 
      console.log('selectedBoatId: ' + this.selectedBoatId);
      // this.selectedBoatId = !this.selectedBoatId;
      // console.log('!selectedBoatId: ' + this.selectedBoatId);
      console.log('selectBoat called');
      this.selectedBoat = this.boat.Id;
      console.log('this.selectedBoat: ' + this.boat.Id);
      console.log('boat: ' + JSON.stringify(this.boat));
      console.log('event: ' + event.detail);
      // this.selectedBoat = event.detail.this.boat.Id;
      // console.log('selectedBoat: ' + selectedBoat);
      this.dispatchEvent(new CustomEvent("boatselect", {detail: { boatId: this.boat.Id }}));
      console.log('onboatselect called');
    }
  }