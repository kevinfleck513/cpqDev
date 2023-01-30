export function onBeforeCloneLine(quote, clonedLines) {
    console.log(`onBeforeCloneLine`);
    // clonedLines.forEach(line => {
    //     console.log(`line:`);
    //     console.log(line);
    // });
    return Promise.resolve();
 }

export function onAfterCloneLine(quote, clonedLines) {
    let productcodes = [1234, 12357, 12347];
    console.log(`onAfterCloneLine`);
    console.log(clonedLines);
    clonedLines.clonedLines.standard.forEach(line => {
        console.log(`line.SBQQ__Source__c: ${line.SBQQ__Source__c}`);
        // if productcodes.includes(line.ProductCode){
        //     // clone logic for travel time
        // } else {
        //     // do normal cloning things
        // }
    })
    // clonedLines.clonedLines.forEach(line => {
    //     console.log(`line:`);
    //     console.log(line);
    // });
    return Promise.resolve();
 }