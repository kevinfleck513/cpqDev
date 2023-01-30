import { LightningElement, api } from 'lwc';

export default class RedditPost extends LightningElement {

 @api post;
 isVideo;
 image;

 connectedCallback(){
    console.log('connectedCallback() redditPost.js');
    console.log('post: ' + JSON.stringify(this.post));
    console.log('url?: ' + JSON.stringify(this.post.url));
    this.isVideo = this.post.is_video ? true : false;
    this.image = this.post.url;
    console.table(this.post);
 }

 get upOrDownArrow(){
     return this.post.ups >= this.post.downs ? 'utility:arrowup' : 'utility:arrowdown';
 }
 get upsOrDowns(){
     return this.post.ups >= this.post.downs ? this.post.ups : this.post.downs;
 }
//  get image(){
//      return this.post.url != null ? "<img src="+this.post.url+">" : "no image";
//  }

onImgError(){
    console.log('error getting image');
    this.isVideo = true;
}

}