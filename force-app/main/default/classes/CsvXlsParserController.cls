public with sharing class CsvXlsParserController {
    // public Map<Integer, String> linesToGroupMap = new Map<Integer, String>();

    @AuraEnabled
    public static ResponseWrapper getQuoteFields(String quoteId){
        SBQQ__Quote__c quote = [SELECT Id, SBQQ__Account__c, SBQQ__LineItemCount__c, SBQQ__LineItemsGrouped__c FROM SBQQ__Quote__c WHERE Id =:quoteId];
        Integer numberOfGroups = [SELECT COUNT() FROM SBQQ__QuoteLineGroup__c WHERE SBQQ__Quote__c = :quoteId];

        ResponseWrapper response = new ResponseWrapper();
        response.accountId = quote.SBQQ__Account__c;
        response.numberOfGroups = numberOfGroups;
        response.lineItemCount = quote.SBQQ__LineItemCount__c;
        response.lineItemsGrouped = quote.SBQQ__LineItemsGrouped__c;

        return response;
    }

    @AuraEnabled
    public static Boolean insertQuoteLinesAndGroups(String dataModel){
        // String partNumberPrefix = 'N-00004-';
        Map<Integer, String> linesToGroupMap = new Map<Integer, String>();
        Map<String, Product2> productCodeToProduct2Map = new Map<String, Product2>();
        Map<Integer, Id> quoteLineToNewProductMap = new Map<Integer, Id>();
        List<SBQQ__QuoteLineGroup__c> quoteLineGroupsList = new List<SBQQ__QuoteLineGroup__c>();
        List<SBQQ__QuoteLine__c> quoteLinesList = new List<SBQQ__QuoteLine__c>();
        List<SBQQ__QuoteLine__c> quoteLinesNeedProductList = new List<SBQQ__QuoteLine__c>();
        System.debug('dataModel: ' + dataModel);
        EETWrapper eetWrapper = new EETWrapper();
        eetWrapper = (EETWrapper) JSON.deserialize(dataModel, EETWrapper.class);
        System.debug('eetWrapper: ' + eetWrapper);
        String quoteId = eetWrapper.recordId;
        Integer numberOfLines = eetWrapper.numberOfLines;
        Integer numberOfGroups = eetWrapper.numberOfGroups;
        List<String> productCodes = eetWrapper.productCodes;
        List<Product2> productList = [SELECT Id, ProductCode FROM Product2 WHERE ProductCode IN :productCodes];
        for(Product2 product : productList){
            productCodeToProduct2Map.put(product.ProductCode, product);
        }
        System.debug('productCodeToProduct2Map: ' + productCodeToProduct2Map);    
        for(groups g : eetWrapper.groups){ // insert quote line groups.
            SBQQ__QuoteLineGroup__c quoteLineGroup = new SBQQ__QuoteLineGroup__c(
                SBQQ__Quote__c = quoteId,
                SBQQ__Account__c = eetWrapper.accountId,
                SBQQ__Number__c = g.groupIndex,
                Name = g.groupKey,
                SBQQ__ListTotal__c = g.total
            );
            quoteLineGroupsList.add(quoteLineGroup);            
        }
        runInsert(quoteLineGroupsList, 'SBQQ__QuoteLineGroup__c', linesToGroupMap, numberOfGroups, true);
        for(groups g : eetWrapper.groups){
            for(Lines line : g.lines){
                SBQQ__QuoteLine__c quoteLine = new SBQQ__QuoteLine__c(
                    SBQQ__Quote__c = quoteId,
                    SBQQ__Product__c = productCodeToProduct2Map.get(line.partNumber)?.Id,
                    SBQQ__Description__c = line.description,
                    SBQQ__Optional__c = line.addLine,
                    SBQQ__Number__c = line.lineNumber,
                    SBQQ__Quantity__c = line.finalQty,
                    SBQQ__Group__c = linesToGroupMap.get(line.groupIndex)
                );
                if(productCodeToProduct2Map.containsKey(line.partNumber)){
                    quoteLinesList.add(quoteLine);
                } else {
                    quoteLinesNeedProductList.add(quoteLine);
                }
            }
        }
        System.debug('quoteLinesList: ' + quoteLinesList);
        System.debug('quoteLinesNeedProductList: ' + quoteLinesNeedProductList);
        if(quoteLinesNeedProductList.isEmpty()){
            runInsert(quoteLinesList, 'SBQQ__QuoteLine__c', null, null, true); // all quote lines had product2 records found, insert.
            return true;
        } else {
            List<SBQQ__QuoteLine__c> quoteLinesToInsert = new List<SBQQ__QuoteLine__c>();
            createNewProductsForQuoteLines(quoteLinesNeedProductList, quoteLineToNewProductMap); // not all quote lines had product2 records, create new product2 records.
            System.debug('quoteLinesNeedProductList: ' + quoteLinesNeedProductList);
            System.debug('quoteLinesNeedProductList.size(): ' + quoteLinesNeedProductList.size());
            System.debug('quoteLineToNewProductMap: ' + quoteLineToNewProductMap);
            System.debug('quoteLineToNewProductMap.size(): ' + quoteLineToNewProductMap.size());
            for(Integer i = 0; i <= quoteLinesNeedProductList.size() - 1; i++){
                quoteLinesNeedProductList[i].SBQQ__Product__c = quoteLineToNewProductMap.get(i + 1);
            }
            quoteLinesToInsert.addAll(quoteLinesList);
            quoteLinesToInsert.addAll(quoteLinesNeedProductList);
            runInsert(quoteLinesToInsert, 'SBQQ__QuoteLine__c', null, null, true);
            return true;
        }
    }

    private static void createNewProductsForQuoteLines(List<SBQQ__QuoteLine__c> quoteLineList, Map<Integer, Id> quoteLineToNewProductMap){
        List<Product2> newProductsList = new List<Product2>();
        for(SBQQ__QuoteLine__c quoteLine : quoteLineList){
            Product2 product2 = new Product2(
                Name = quoteLine.SBQQ__Description__c,
                Description = quoteLine.SBQQ__Description__c,
                ProductCode = 'Imported Product',
                // Cost__c = figure out,
                IsActive = true,
                // Company_NEC__c = true, // check field api name
                SBQQ__DefaultPricingTable__c = 'Standard',
                SBQQ__DefaultQuantity__c = 1,
                SBQQ__AssetAmendmentBehavior__c = null,
                SBQQ__AssetConversion__c = null,
                SBQQ__PriceEditable__c = true,
                SBQQ__CostEditable__c = true,
                SBQQ__QuantityEditable__c = true,
                SBQQ__PricingMethod__c = 'List',
                SBQQ__SubscriptionPricing__c = 'Fixed Price',
                SBQQ__SubscriptionTerm__c = 12,
                SBQQ__SubscriptionType__c = 'One-Time',
                QuantityUnitOfMeasure = 'Each'
            );
            newProductsList.add(product2);
        }
        runInsert(newProductsList, 'Product2', quoteLineToNewProductMap, null, true);
    }

    @AuraEnabled
    public static Boolean uploadFile(String base64, String fileName, String recordId) {
        ContentVersion cv = createContentVersion(base64, filename);
        ContentDocumentLink cdl = createContentLink(cv.Id, recordId);
        if (cv == null || cdl == null) {
            return false; 
        } else {
            return true;
        }
    }

    private static ContentVersion createContentVersion(String base64, String filename) {
        ContentVersion cv = new ContentVersion();
        cv.VersionData = EncodingUtil.base64Decode(base64);
        cv.Title = filename;
        cv.PathOnClient = filename;
        try {
            insert cv;
            return cv;
          } catch(DMLException e) {
            System.debug(e);
            return null;
          }
        // runInsert(new List<ContentVersion>{cv}, 'ContentVersion', null, null, true);
    }

    private static ContentDocumentLink createContentLink(String contentVersionId, String recordId) {
        if (contentVersionId == null || recordId == null) { 
            return null; 
        }
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion  WHERE Id =: contentVersionId].ContentDocumentId;
        cdl.LinkedEntityId = recordId;
        // ShareType is either 'V', 'C', or 'I'
        // V = Viewer, C = Collaborator, I = Inferred
        cdl.ShareType = 'V';
        try {
            insert cdl;
            return cdl;
          } catch(DMLException e) {
            System.debug(e);
            return null;
          }
        // runInsert(new List<ContentDocumentLink>{cdl}, 'ContentDocumentLink', null, null, true);
    }

     // ------------------ UTILITY METHODS ------------------ //
     private static void runInsert(List<sObject> listToInsert, String objectType, Map<Integer, String> linesToGroupMap, Integer numberOfGroups, Boolean continueOnError){
        System.debug('runInsert');
        System.debug(objectType + ' listToInsert: ' + listToInsert);
        Database.SaveResult[] srList = Database.insert(listToInsert, continueOnError);
        for (Integer i = 0; i < srList.size(); i++) {            
            if (srList[i].isSuccess()) {
                // Operation was successful, so get the ID of the record that was processed
                System.debug('Successfully inserted ' + objectType + ', ID: ' + srList[i].getId());
                switch on objectType {
                    when 'SBQQ__QuoteLineGroup__c' {
                        linesToGroupMap.put(i + numberOfGroups + 1, srList[i].getId());
                    }
                    when 'Product2' {
                        linesToGroupMap.put(i + 1, srList[i].getId());
                    }
                }
            }
            else {
                // Operation failed, so get all errors
                for(Database.Error err : srList[i].getErrors()) {
                    System.debug('The following error has occurred.');                    
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    System.debug(objectType + ' fields that affected this error: ' + err.getFields());
                    String errorMessage = 'Error inserting ' + objectType + ' ' + err.getMessage() + ' ' + err.getFields();
                }
            }
        }               
    }

    // ------------------ WRAPPER CLASSES ------------------ // 
    public class ResponseWrapper {
        @AuraEnabled
        public String accountId {get;set;}
        @AuraEnabled
        public Integer numberOfGroups {get;set;}
        @AuraEnabled
        public Decimal lineItemCount {get;set;}
        @AuraEnabled
        public Boolean lineItemsGrouped {get;set;}
    }
    public class EETWrapper {
        public List<Groups> groups {get;set;}
        // public List<Lines> lines {get;set;}
        public String recordId {get;set;}      
        public String accountId {get;set;}
        public Integer numberOfLines {get;set;}
        public List<String> productCodes {get;set;}
        public Integer numberOfGroups {get;set;}      
    }

    public class Groups {
        public String groupKey {get;set;}
        public Integer groupIndex {get;set;}  
        public List<Lines> lines {get;set;}
        public Decimal total {get;set;}
    }

    public class Lines {
        public Boolean addLine {get;set;}
        public Decimal blendedDiscount {get;set;}
        public Decimal commission {get;set;}
        public Decimal costToNECI {get;set;}
        public String description {get;set;}
        public Decimal discount {get;set;}
        public Boolean discountable {get;set;}
        public Decimal finalQty {get;set;}
        public String groupKey {get;set;}
        public Integer groupIndex {get;set;}
        public String itemNo {get;set;}
        public Integer lineNumber {get;set;}
        public String partNumber {get;set;}
        public Decimal totalListPrice {get;set;}
        public Decimal totalProposal {get;set;}
        public Decimal unitListPrice {get;set;}
        public Decimal unitProposal {get;set;}
    }
}