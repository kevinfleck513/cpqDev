import { LightningElement, api } from 'lwc';
import { updateRecord } from 'lightning/uiRecordApi';
import { loadScript } from 'lightning/platformResourceLoader';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';
import { processFileToJSON, prepDataModel, prepFile } from './handleCsv.js';
import ID_FIELD from '@salesforce/schema/SBQQ__Quote__c.Id';
import GROUP_LINES from '@salesforce/schema/SBQQ__Quote__c.SBQQ__LineItemsGrouped__c';
import getQuoteFields from '@salesforce/apex/CsvXlsParserController.getQuoteFields';
import insertQuoteLinesAndGroups from '@salesforce/apex/CsvXlsParserController.insertQuoteLinesAndGroups';
import uploadFile from '@salesforce/apex/CsvXlsParserController.uploadFile';
import SheetJS from '@salesforce/resourceUrl/sheetJs';
// sheetJS.com
// parsing options: https://docs.sheetjs.com/docs/api/parse-options
// utility functions for json output: https://docs.sheetjs.com/docs/api/utilities/#array-output

export default class CsvXlsParser extends NavigationMixin(LightningElement) {

    loading;
    @api recordId;
    accountId;
    numberOfGroups;
    lineItemCount;
    lineItemsGrouped;
    acceptedFormats = ['.csv', '.xls', '.xlsx'];

    async connectedCallback(){
        this.loading = true;
        await loadScript(this, SheetJS) // load SheetJS.
        .then(() => {
            console.log(`SheetJS version ${XLSX.version} loaded.`);
            getQuoteFields({ quoteId: this.recordId }) // query any quote fields needed for Quote line group and Quote line creation.
            .then(result => {
                console.log(result);
                this.accountId = result.accountId;
                this.numberOfGroups = result.numberOfGroups;
                this.lineItemCount = result.lineItemCount;
                this.lineItemsGrouped = result.lineItemsGrouped;
                this.loading = false;
            })
            .catch(error => {
                console.log(error);
                this.showToast(`error`, `error getting quote fields.`, `error`);
                this.loading = false;
            });
        })       
        .catch(error => {
            console.log(error);
            this.showToast(`error`, `error loading scripts.`, `error`);
            this.loading = false;
        });
    }

    async handleUploadFinished(event){
        this.loading = true;
        let file = event.detail.files[0];
        console.log(`file`);
        console.log(file);
        let fileToAttach = await prepFile(file, this.recordId);
        let processedFile = await processFileToJSON(file); // turn uploaded file into JSON.
        console.log(processedFile);
        let dataModel = await prepDataModel(processedFile, this.numberOfGroups, this.lineItemCount); // parse JSON into our dataModel.
        dataModel.recordId = this.recordId;
        dataModel.accountId = this.accountId;
        dataModel.numberOfGroups = this.numberOfGroups;
        console.log(dataModel);

        insertQuoteLinesAndGroups({ dataModel : JSON.stringify(dataModel) })
        .then(result => {
            if(result){
                console.log('success.');
                const fields = {};
                fields[ID_FIELD.fieldApiName] = this.recordId;
                fields[GROUP_LINES.fieldApiName] = true;
                const recordInput = { fields };
                updateRecord(recordInput)
                .then(() => {
                    uploadFile(fileToAttach)
                    .then(result => {
                        if(result){
                            this.loading = false;
                            this.showToast(`success`, `File uploaded successfully.`, `success`);
                            this.closeQuickAction();
                            // this.handleNavigate();
                        } else {
                            this.loading = false;
                            console.error(`error attaching file.`);
                        }
                    })                    
                })
                .catch(error => {
                    this.loading = false;
                    console.error(error);
                    this.showToast(`error`, `error uploading file.`, `error`);
                })
                
            } else {
                this.loading = false;
                console.error('error');
            }
        })
    }

    handleNavigate(){
        let qleLink = '/apex/sbqq__sb?scontrolCaching=1&id='+this.recordId+'#quote/le?qId='+this.recordId;
        this[NavigationMixin.Navigate]({
            type: "standard__webPage",
                attributes: {
                    url: qleLink
                }           
        });
    }

    closeQuickAction(){
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }
}