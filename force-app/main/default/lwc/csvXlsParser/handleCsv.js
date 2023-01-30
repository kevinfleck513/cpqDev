const itemStr = 'Item No.';
const partNumberStr = 'Part Number';
const finalQtyStr = 'Final Qty.';
const descriptionStr = 'Description'
const unitListPriceStr = 'Unit List (USD)';
const discountStr = 'Item Discount (%)';
const discountableStr = 'Discountable';
const commissionStr = 'Commission (%)';
const partNumberPrefix = 'N-00004-';
let indexMap = new Map();
let groupKey;
let groupIndex;
let lineNumber;

export function processFileToJSON(file){ // read file and return as JSON.
    console.log(`processFileToJSON()`);
    return new Promise(resolve => {
        let reader = new FileReader();
        reader.onload = event => {
            let data = event.target.result;
            let workbook = XLSX.read(data, { type: 'binary', raw: true, sheetStubs: true });
            let worksheet = workbook.SheetNames[0];
            let json = XLSX.utils.sheet_to_json(workbook.Sheets[worksheet], { header: "A", raw: true, defval: "" });
            resolve(json);
        }
        reader.readAsBinaryString(file);
    });    
}

export function prepDataModel(json, numberOfGroups, startingLineNumber){
    console.log(`prepDataModel()`);
    groupIndex = numberOfGroups;
    lineNumber = startingLineNumber + 1;
    console.log(`starting group number: ${groupIndex}`);
    return new Promise(resolve => {        
        const startingIndex = json.findIndex(row => row.A === itemStr);
        let groups = [];
        let lines = [];
        let dataModel = {};
        let numberOfLines = 0;
        let productCodes = [];
        console.log(`startingIndex find(): ${startingIndex}`); // find starting index to start parsing our data from.
        let trimmedData = json.filter(row => json.indexOf(row) >= startingIndex);
        let trimmedArr = [];
        trimmedData.forEach(row => trimmedArr.push(Object.values(row)));
        trimmedArr[0].forEach((element, index) => indexMap.set(element, index)); // set indexMap with index values of header row.
        // for (const [index, element] of trimmedArr[0].entries()){ 
        //     indexMap.set(element, index);
        // }
        for(let i = 1; i < trimmedArr.length - 1; i++){ // skip first and last rows of sheet.
            numberOfLines++; // keep running count of number of lines.
            // set groups and lines.
            if(groupConditionsMet(trimmedArr[i])){
                // row in sheet is a group
                groupIndex++;
                groups.push({
                    groupKey: trimmedArr[i][indexMap.get(itemStr)],
                    groupIndex: groupIndex
                });
                groupKey = trimmedArr[i][indexMap.get(itemStr)];
                
            } else {
                // row in sheet is a line
                lineNumber++
                productCodes.push(`${partNumberPrefix}${trimmedArr[i][indexMap.get(partNumberStr)]}`); // populate productCodes array to query for product2 records in apex controller.
                lines.push(buildLine(trimmedArr[i]));
            }
        };
        groups.forEach(group => {
            // associate lines to correct groups.
            group.lines = lines.filter(line => line.groupKey === group.groupKey);
            // collect lines that we need to add.
            let linesToSum = group.lines.filter(line => line.addLine);
            // total up the lines in each group and set group total.
            group.total = +linesToSum.reduce((total, line) => total = total + line.unitListPrice, 0).toFixed(2);
        });
        dataModel.groups = groups;
        dataModel.numberOfLines = numberOfLines;
        dataModel.productCodes = productCodes;
        resolve(dataModel);
    });
}

export function prepFile(file, recordId){
    console.log(`prepFile()`);
    return new Promise(resolve => {
        let reader = new FileReader();
        reader.onload = event => {
            let data = event.target.result;
            let fileData = {
                fileName: file.name,
                base64: data.split(',')[1],
                recordId: recordId
            }
            resolve(fileData);
        }
        reader.readAsDataURL(file);
    });
}

function groupConditionsMet(line){
    return !!line[indexMap.get(itemStr)] && !line[indexMap.get(partNumberStr)] && !line[indexMap.get(finalQtyStr)] && !line[indexMap.get(descriptionStr)];
}

function buildLine(line){    
    const itemNo = line[indexMap.get(itemStr)];
    const addLine = !itemNo.includes('.');
    const partNumber = `${partNumberPrefix}${line[indexMap.get(partNumberStr)]}`;
    const finalQty = line[indexMap.get(finalQtyStr)];
    const unitListPrice = line[indexMap.get(unitListPriceStr)];
    const description = line[indexMap.get(descriptionStr)];
    const discount = !line[indexMap.get(discountStr)] ? 0 : line[indexMap.get(discountStr)];
    const discountable = line[indexMap.get(discountableStr)] === 'Yes' ? true : false;
    const unitProposal = +determineUnitProposal(unitListPrice, discount).toFixed(2);
    const totalProposal = +determineTotalProposal(finalQty, unitProposal).toFixed(2);
    const commission = adjustCommission(line[indexMap.get(commissionStr)]);
    const blendedDiscount = +determineBlendedDiscount(discount, commission).toFixed(2);
    const costToNECI = +determineCostToNECI(totalProposal, commission).toFixed(2);
    return {
        groupKey: groupKey,
        groupIndex: groupIndex,
        itemNo: itemNo,
        description: description,
        addLine: addLine,
        partNumber: partNumber,
        lineNumber: lineNumber,
        finalQty: finalQty,
        unitListPrice: unitListPrice,
        totalListPrice: unitListPrice * finalQty,
        discount: discount,
        discountable: discountable,
        unitProposal: unitProposal,
        totalProposal: totalProposal,
        commission: commission,
        blendedDiscount: blendedDiscount,
        costToNECI: costToNECI
    };
}

function adjustCommission(commission){ // account for different commission % based on spreadsheet entries
    let divisor = 1;
    if((commission / 10) > 0){
        if((commission / 100) > 0){
            divisor = 100;
        } else {
            divisor = 10;
        }
    }
    return commission / divisor;
}

function determineBlendedDiscount(discount, commission){
    return 1 - ((1 - discount) * (1 - commission));
}

function determineUnitProposal(price, discount){
    return price * (1 - discount);
}

function determineTotalProposal(quantity, unitProposal){
    return quantity * unitProposal;
}

function determineCostToNECI(total, commission){
    return total * (1 - commission);
}