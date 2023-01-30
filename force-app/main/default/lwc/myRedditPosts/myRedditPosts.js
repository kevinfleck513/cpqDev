import { LightningElement, api, wire } from 'lwc';
import getRedditChannels from '@salesforce/apex/MyRedditPostsController.getRedditChannels';
import getRedditData from '@salesforce/apex/MyRedditPostsController.getRedditData';

export default class MyRedditPosts extends LightningElement {

    @api recordId;
    redditChannels;
    redditResults;
    error;
    title;
    isLoaded = false;

    @wire (getRedditChannels)
        channels({ error, data }){
            if(data){
                console.log('channels: ' + JSON.stringify(data));
                this.redditChannels = data.map(channel => {
                    return{
                        label: channel.Name,
                        value: channel.Name
                    };
                });
                this.isLoaded = true;
                console.log('this.redditChannels: ' + JSON.stringify(this.redditChannels));
            } else if(error){
                console.log('error getting data: ' + JSON.stringify(error));
            }
        }

    connectedCallback(){
        console.log('connectedCallback');
        // getRedditChannels()
        // .then((result)=>{
        //     if(result){
        //         console.log('reddit channels: ' + JSON.stringify(result));
        //         this.redditChannels = result;
        //     }
        // }).catch(error=>{
        //     console.log('error: ' + error);
        // })
    }

    getRedditData(value){
        console.log('getRedditData');
        getRedditData({ channel : value })
        .then((result)=>{
            if(result){
                console.log('reddit results: ' + JSON.stringify(result));
                this.redditResults = result;
                this.isLoaded = true;
                this.error = false;
            } else {
                console.log('no results');
            }
        }).catch(error=>{
            console.log('error: ' + JSON.stringify(error));
            this.isLoaded = true;
            this.error = true;
        });
    }

    handleChannelChange(event){
        this.isLoaded = false;
        console.log('selected channel Id is: ' + event.detail.value);
        let formattedVal = event.detail.value.split(' ').join('');
        this.title = "r/"+formattedVal;
        console.log('formattedVal : ' + formattedVal);
        this.getRedditData(formattedVal);
    }

    makeCallout(){
        console.log('makeCallout()');
        console.log('this.isLoaded = ' + this.isLoaded);
        this.isLoaded = !this.isLoaded;
        console.log('this.isLoaded = ' + this.isLoaded);      
        setTimeout(() => {
            console.log('in setTimeout()');
            this.getRedditData();
        }, 1500);
    }

}