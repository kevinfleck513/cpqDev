import { LightningElement, api, wire } from 'lwc';
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import Id from '@salesforce/user/Id';
import ACCOUNT_ID from '@salesforce/schema/User.Contact.Account.Id';
import CONTACT_ID from '@salesforce/schema/User.Contact.Id';
import COMPUCOM_LOGO from '@salesforce/resourceUrl/Compucom_logo_new';
import ACCOUNT_LOGO from '@salesforce/schema/User.Contact.Account.Logo__c';
import ACCOUNT_NAME from '@salesforce/schema/User.Contact.Account.Name';
import DO_NOT_DISPLAY_LOGO from '@salesforce/schema/User.Contact.Account.Do_not_display_logo__c';

const FIELDS = [
    ACCOUNT_ID, 
    ACCOUNT_LOGO,
    CONTACT_ID,
    ACCOUNT_NAME,
    DO_NOT_DISPLAY_LOGO
];

export default class AccountLogo extends LightningElement {

    userId = Id;
    loading;
    @wire(getRecord, { recordId: '$userId', fields: FIELDS }) user;
    // user({ error, data }){
    //     if(data){
    //         console.log(`user data`);
    //         console.log(data);
    //         // let accountId = (data.fields.hasOwnProperty.call( data.fields, ACCOUNT_ID.fieldApiName ) && data.fields[ ACCOUNT_ID.fieldApiName ].value ) || `no accountId`;  
    //         let accountId = data.fields.Contact.value.fields.AccountId.value || `no accountId`;  
    //         console.log(`accountId: ${accountId}`); 
    //         this.accountLogo = (data.fields.hasOwnProperty.call(data.fields, ACCOUNT_LOGO.fieldApiName) && data.fields[ACCOUNT_LOGO.fieldApiName].value) || COMPUCOM_LOGO;         
    //     } else if(error){
    //         console.error(error);
    //     }
    // };
    
    // accountLogo;
    // @wire(getRecord, { recordId: "$recordId", ACCOUNT_LOGO })
    // account( { error, data }) {
    //     if( data ){
    //         console.log(`data: ${data}`);
    //         let logo = data.fields[ ACCOUNT_LOGO.fieldApiName ].value;
    //         // this.accountLogo = !logo ? COMPUCOM_LOGO : logo;
    //         if(!logo){
    //             console.log(`no logo found on account, using Compucom default logo instead`);
    //             logo = 'resource/Compucom_logo_new';
    //         }
    //         this.accountLogo = `background-image:url(${logo})`;
    //     }
    //     else if( error ){
    //       console.error( "error: ", error );
    //     }
    // };

    // add 3rd option for do not display logo
    // look into doing this with CMS
    
    connectedCallback(){
        console.log(`connectedCallback()`);
        console.log(`userId: ${this.userId}`);
        // this.loading = true;
        // console.log(`loading: ${loading}`);
    }

    renderedCallback() {
        console.log(`renderedCallback()`);
        console.log(`this.user.data:`);
        console.log(this.user.data);
        // this.loading = false;
        // console.log(`loading: ${loading}`);
    }

    get accountId(){
        let accountId = getFieldValue(this.user.data, ACCOUNT_ID);
        console.log(`getter accountId: ${accountId}`);
        return accountId;
    }
    
    get accountLogo(){
        if(getFieldValue(this.user.data, DO_NOT_DISPLAY_LOGO)){
            return;
        } else {
            let logo = getFieldValue(this.user.data, ACCOUNT_LOGO);
            return !!logo ? logo : COMPUCOM_LOGO;
        }        
    }

    get accountName(){
        return getFieldValue(this.user.data, ACCOUNT_NAME);
    }

}