import { LightningElement, api, wire, track } from 'lwc';
import { getRelatedListCount, getRelatedListRecords } from 'lightning/uiRelatedListApi';
import getUDFs from '@salesforce/apex/checkoutController.getUdfs'

const columns = [
    { label: 'Name', fieldName: 'Name' },
    { label: 'DIMS Field number', fieldName: 'DIMS_Field_Number__c', type: 'text', sortable: true },
    // {
    //     label: 'Age',
    //     fieldName: 'age',
    //     type: 'number',
    //     sortable: true,
    //     cellAttributes: { alignment: 'left' },
    // },
    { label: 'Account Name', fieldName: 'Account__r.Name'},
    { label: 'Account Id', fieldName: 'Account__c'}
];

export default class GetUdfs extends LightningElement {

    @api strRecordId;
    displayCount = false;
    displayRecords = false;
    records;
    columns = columns;
    defaultSortDirection = 'asc';
    sortDirection = 'asc';
    sortedBy;

    // @wire(getRelatedListCount, { parentRecordId: '$strRecordId', relatedListId: 'UDFs__r' })
    // relatedRecordsCount({ error, data }){
    //     if(data){
    //         console.log(`recordCount: ${data.count}`);
    //         this.displayCount = data.count > 0;
    //         this.count = data.count;
    //         this.displayRecords = data.count > 0;
    //     } else if(error){
    //         console.error(`error: ${error}`);
    //     }
    // }
    // @wire(getRelatedListRecords, { parentRecordId: '$strRecordId', relatedListId: 'UDFs__r', fields: ['UDF__c.Name','UDF__c.DIMS_Field_Number__c','UDF__c.Account__c','UDF__c.Account__r.Name'] })
    // relatedRecords({ error, data }){
    //     if(data){
    //         // console.log(`relatedRecords:`);
    //         // console.log(JSON.stringify(data));
    //         this.records = data.records.map(record => {
    //             let newObj = {};
    //             newObj.name = record.fields.Name.value;
    //             newObj.dimsNumber = record.fields.DIMS_Field_Number__c.value;
    //             newObj.accountId = record.fields.Account__c.value;
    //             newObj.accountName = record.fields.Account__r.displayValue;
    //             return newObj;
    //         });
    //         console.log(this.records);
    //     } else if(error){
    //         console.error(`error: ${error}`);
    //     }
    // }

    @wire(getUDFs, { accountId: '$strRecordId' })
    accountData({ data, error }){
        if(data){
            console.log(data);
            let count = data.length;
            this.displayCount = count > 0;
            this.displayRecords = count > 0;
            this.records = data;
        } else if(error){
            console.error(error);
        }
    };

    get tableData(){
        // console.log(`getter tableData()`);
        // console.log(JSON.stringify(this.records));

        // const records = this.relatedRecords.data.records;
        
        const relatedRecordsJSON = this.records.map(record => {
            let newObj = {};
            newObj.name = record.fields.Name.value;
            newObj.dimsNumber = record.fields.DIMS_Field_Number__c.value;
            newObj.accountId = record.fields.Account__c.value;
            newObj.accountName = record.fields.Account__r.displayValue;
            return newObj;
        });
        return relatedRecordsJSON;
    }

    // sortBy(field, reverse, primer) {
    //     const key = primer
    //         ? function (x) {
    //               return primer(x[field]);
    //           }
    //         : function (x) {
    //               return x[field];
    //           };

    //     return function (a, b) {
    //         a = key(a);
    //         b = key(b);
    //         return reverse * ((a > b) - (b > a));
    //     };
    // }

    handleSort(event) {
        const { fieldName: sortedBy, sortDirection } = event.detail;
        const cloneData = [...this.records];

        cloneData.sort(this.sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1));
        this.records = cloneData;
        this.sortDirection = sortDirection;
        this.sortedBy = sortedBy;
    }

    sortBy(field, reverse, primer) {
        const key = primer
            ? function (x) {
                  return primer(x[field]);
              }
            : function (x) {
                  return x[field];
              };

        return function (a, b) {
            a = key(a);
            b = key(b);
            return reverse * ((a > b) - (b > a));
        };
    }

    // handleSort(event) {
    //     const { fieldName: sortedBy, sortDirection } = event.detail;
    //     const cloneData = [...this.records];
    //     cloneData.sort(this.sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1));
    //     this.records = cloneData;
    //     // this.sortDirection = sortDirection;
    //     this.sortDirection = this.sortedDirection == 'asc' ? 'desc' : 'asc';
    //     this.sortedBy = sortedBy;
    // }

    // handleSort(event) {
    //     console.log(`event.detail.fieldName: ${event.detail.fieldName} event.detail.sortDirection: ${event.detail.sortDirection}`);
    //     this.sortBy = event.detail.fieldName;
    //     this.sortDirection = event.detail.sortDirection;
    //     console.log(`this.sortBy: ${this.sortBy} this.sortDirection: ${this.sortDirection}`);
    //     this.sortData(this.sortBy, this.sortDirection);
    // }

    // sortData(fieldname, direction) {
    //     let parseData = JSON.parse(JSON.stringify(this.records));
    //     // Return the value stored in the field
    //     let keyValue = (a) => {
    //         return a[fieldname];
    //     };
    //     // cheking reverse direction
    //     let isReverse = direction === 'asc' ? 1: -1;
    //     // sorting data
    //     parseData.sort((x, y) => {
    //         x = keyValue(x) ? keyValue(x) : ''; // handling null values
    //         y = keyValue(y) ? keyValue(y) : '';
    //         // sorting values based on direction
    //         return isReverse * ((x > y) - (y > x));
    //     });
    //     this.records = parseData;
    // }

}