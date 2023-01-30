/**
 * Salesforce CPQ Test Utilities (with Billing)
 * This code is provided without warranty and must be used within the guidelines
 * of any signed agreement
 *
 * Assumptions:
 * Salesforce CPQ is installed, Salesforce Billing is installed.
 *
 * This is the helper test utility class to aid CPQ_TestsB in creating, testing, and validating data.
 *
 *
 * @author Kevin Antonioli kevin.antonioli@atginfo.com (credit to Austin Turner for the billing helper methods :-)
 * @updated 02.09.2019 by Kevin Antonioli kevin.antonioli@atginfo.com
 *
 */
@IsTest
public without sharing class CPQ_TestUtils  {

    public static Account createAccount(String name, Boolean doInsert) {
        Account obj = new Account(Name = name);
        if(doInsert) {
            insert obj;
        }

        return obj;
    }

    public static Contact createContact(Account acc, Boolean doInsert) {

        Contact testContact = new Contact(
            FirstName = 'Test',
            LastName = 'Testing',
            AccountId = acc.Id,
            // Active_Account__c = acc.Id,
            // Contact_Score__c = 40,
            // Decision_Role__c = 'Economic Decision Maker',
            Email = 'fullname@domain.com'
        );

        if(doInsert) {
            insert testContact;
        }
        return testContact;
    }

    public static Opportunity createOpportunity(String name, Account anAccount, Boolean doInsert) {
        Opportunity obj = new Opportunity(Name = name, Account = anAccount, StageName = 'Qualification',
            CloseDate = Date.today() + 7, Pricebook2Id = Test.getStandardPricebookId());
        if(doInsert) {
            insert obj;
        }

        return obj;
    }

    public static Opportunity createOpportunity(String name, Account anAccount, Contact aContact, Boolean doInsert) {
        Opportunity obj = new Opportunity(Name = name, Account = anAccount, StageName = 'Qualification',
            CloseDate = Date.today() + 7, Pricebook2Id = Test.getStandardPricebookId(),
            ContactId = aContact.Id);
        if(doInsert) {
            insert obj;
        }

        return obj;
    }

    /** Create product **/
    public static Product2 createProduct(String name, String productType, String productCode, Id billingRuleId, Id taxRuleId, Id revRecRuleId, Boolean populateDefaultValues, Boolean doInsert) {
        Product2 obj = (Product2)Product2.sObjectType.newSObject(
            null, // null will make it the default record type for the user
            true // loadDefaultValues
        );
        obj.Name = name;
        obj.IsActive = true;
        obj.ProductCode = productCode;
        obj.SBQQ__QuantityEditable__c = true;
        obj.SBQQ__DefaultQuantity__c = 1.0;
        obj.SBQQ__AssetConversion__c = 'One per quote line';
        obj.SBQQ__SubscriptionCategory__c = 'Bundle';
        obj.SBQQ__ExcludeFromOpportunity__c = true;

        if(productType == 'Subscription') {
            obj.SBQQ__SubscriptionTerm__c = 1;
            obj.SBQQ__SubscriptionType__c = 'Renewable';
            obj.SBQQ__SubscriptionPricing__c = 'Fixed Price';
            obj.SBQQ__PricingMethod__c = 'List';
            obj.SBQQ__SubscriptionBase__c = 'Regular';
        } else if(productType == 'Non-Subscription') {
            obj.SBQQ__SubscriptionBase__c = 'List';
        }

        // Required to Order a quote when Billing is installed:
        obj.SBQQ__ChargeType__c = 'Recurring';
        obj.SBQQ__BillingType__c = 'Advance';
        obj.SBQQ__BillingFrequency__c = 'Monthly';
        obj.blng__BillingRule__c = billingRuleId == null ? null : billingRuleId; //#SFBILLING
        obj.blng__TaxRule__c = taxRuleId == null ? null : taxRuleId; //#SFBILLING
        obj.blng__RevenueRecognitionRule__c = revRecRuleId == null ? null : revRecRuleId; //#SFBILLING

        if(doInsert) {
            insert obj;
        }

        return obj;
    }

    /** Create pricebook **/
    public static PriceBook2 createPriceBook(String name, Boolean isActive, String currencyIsoCode, Boolean populateDefaultValues, Boolean doInsert){
        PriceBook2 obj = (PriceBook2)PriceBook2.sObjectType.newSObject(
            null, // null will make it the default record type for the user
            true // loadDefaultValues
        );
        obj.Name = name;
        obj.IsActive = isActive;

        // Note: decomment if multicurrency is enabled:
        //obj.CurrencyIsoCode = currencyIsoCode;

        if(doInsert) {
            insert obj;
        }
        return obj;
    }

    /** Create pricebook entry **/
    public static PricebookEntry createPriceBookEntry(Product2 product, Pricebook2 priceBook, Boolean populateDefaultValues, Boolean doInsert) {
        PricebookEntry obj = (PricebookEntry)PricebookEntry.sObjectType.newSObject(
            null, // null will make it the default record type for the user
            populateDefaultValues // loadDefaultValues
        );
        obj.UnitPrice = 100;
        obj.Pricebook2Id = priceBook == null ? Test.getStandardPricebookId() : priceBook.Id;
        obj.Product2Id = product.Id;
        obj.isActive = true;

        if(doInsert) {
            insert obj;
        }
        return obj;
    }

    /** Create quote **/
    public static SBQQ__Quote__c createQuote(Account acct, Opportunity opp, Boolean isPrimary, Boolean populateDefaultValues, Boolean doInsert) {
        SBQQ__Quote__c obj = (SBQQ__Quote__c)SBQQ__Quote__c.sObjectType.newSObject(
            null, // null will make it the default record type for the user
            true // loadDefaultValues
        );
        obj.SBQQ__Primary__c = isPrimary;
        obj.SBQQ__StartDate__c = Date.today();
        //obj.SBQQ__EndDate__c = Date.today().addMonths(1);
        obj.SBQQ__Opportunity2__c = opp == null ? null : opp.Id;
        obj.SBQQ__SubscriptionTerm__c = 12;
        obj.SBQQ__ExpirationDate__c = Date.today() + 30;
        obj.SBQQ__Account__c = acct == null ? null : acct.Id;
        obj.SBQQ__Type__c = 'Quote';
        // obj.SG_ScheduleName__c = 'TEST';
        // obj.SG_ScheduleNumber__c = '2.0';
        // obj.SG_ScheduleNumber__c = 2343;

        if(doInsert) {
            insert obj;
        }
        return obj;
    }

    public static SBQQ__QuoteLineGroup__c createQuoteLineGroup(String name, Account anAccount, SBQQ__Quote__c quote, Boolean doInsert) {
        SBQQ__QuoteLineGroup__c obj = new SBQQ__QuoteLineGroup__c();
        obj.Name = name;
        obj.SBQQ__Quote__c = quote.Id;
        if(doInsert) {
            insert obj;
        }
        return obj;
    }

    /** Create quote line **/
    public static SBQQ__QuoteLine__c createQuoteLine(Product2 product, PriceBookEntry pbe, SBQQ__Quote__c quote, Boolean populateDefaultValues, Boolean doInsert) {
        SBQQ__QuoteLine__c obj = (SBQQ__QuoteLine__c)SBQQ__QuoteLine__c.sObjectType.newSObject(
            null, // null will make it the default record type for the user
            populateDefaultValues // loadDefaultValues
        );
        obj.SBQQ__Product__c = product.Id;
        obj.SBQQ__Quote__c = quote.Id;
        obj.SBQQ__PricebookEntryId__c = pbe == null ? null : pbe.Id;
        obj.SBQQ__PricingMethod__c = 'List';
        obj.SBQQ__StartDate__c = Date.today();
        obj.SBQQ__ListPrice__c = 100;
        obj.SBQQ__Quantity__c = 1;
        obj.SBQQ__PriorQuantity__c = 0;
        obj.SBQQ__RegularPrice__c = 100;
        obj.SBQQ__NetPrice__c = 100;
        obj.SBQQ__Number__c = 1;
        obj.SBQQ__ProrateMultiplier__c = 1;
        obj.SBQQ__SubscriptionPricing__c = 'Fixed Price';
        obj.SBQQ__SubscriptionScope__c = 'Quote';
        obj.SBQQ__DefaultSubscriptionTerm__c = 1;
        obj.SBQQ__ChargeType__c = product.SBQQ__ChargeType__c;
        obj.SBQQ__BillingType__c = product.SBQQ__BillingType__c;
        obj.SBQQ__BillingFrequency__c = product.SBQQ__BillingFrequency__c;

        if(doInsert) {
            insert obj;
        }
        return obj;
    }

    /** Create Asset */
    public static Asset createAsset(Account acct, Product2 aProduct, Boolean populateDefaultValues, Boolean doInsert) {
        Asset obj = (Asset)Asset.sObjectType.newSObject(
            null, // null will make it the default record type for the user
            populateDefaultValues // loadDefaultValues
        );
        obj.Name = 'Test Asset';
        obj.AccountId = acct.Id;
        obj.Product2Id = aProduct.Id;
        // Decomment if multicurrency is enabled:
        //obj.CurrencyIsoCode = 'USD';
        obj.Status = 'Registered';
        obj.PurchaseDate = System.Today();
        //obj.SBQQ__QuoteLine__c = quoteLine.Id;
        obj.SerialNumber = '1234567890';

        if(doInsert) {
            insert obj;
        }
        return obj;
    }

    public static Contract createContract(Account acct, Id pricebookId, Opportunity opp, Order order, SBQQ__Quote__c quote, Boolean doInsert) {
        Contract obj = (Contract)Contract.sObjectType.newSObject(
            null, // null will make it the default record type for the user
            true // loadDefaultValues
        );
        obj.AccountId = acct.Id;
        obj.ContractTerm = 12;
        obj.SBQQ__Quote__c = quote == null ? null : quote.Id;
        obj.SBQQ__Opportunity__c = opp == null ? null : opp.Id;
        obj.SBQQ__Order__c = order == null ? null : order.Id;
        obj.SBQQ__RenewalTerm__c = 12;
        obj.StartDate = System.Today();

        if(doInsert) {
            insert obj;
        }
        return obj;
    }

    /** Create Subscription **/
    public static SBQQ__Subscription__c createSubscription(Account acct, Contract con, SBQQ__QuoteLine__c quoteLine, Boolean populateDefaultValues, Boolean doInsert) {
        SBQQ__Subscription__c obj = (SBQQ__Subscription__c)SBQQ__Subscription__c.sObjectType.newSObject(
            null, // null will make it the default record type for the user
            true // loadDefaultValues
        );
        obj.SBQQ__Account__c = acct.Id;
        obj.SBQQ__Contract__c = con.Id;
        obj.SBQQ__QuoteLine__c = quoteLine.Id;
        obj.SBQQ__OriginalQuoteLine__c = quoteLine.Id;
        obj.SBQQ__Quantity__c = 1.00;
        obj.SBQQ__RenewalQuantity__c = 1.00;
        obj.SBQQ__Product__c = quoteLine.SBQQ__Product__c;
        obj.SBQQ__Number__c = 1;
        obj.SBQQ__ProrateMultiplier__c = 1.0000;

        if(doInsert) {
            insert obj;
        }
        return obj;
    }

    /************************************/
    /***** ORDER automation RELATED *****/
    /************************************/

    /** Create Order from Quote **/
    public static Order createAutomatedOrderFromQuote(Id quoteId) {
        SBQQ__Quote__c q = new SBQQ__Quote__c(Id = quoteId, SBQQ__Ordered__c= true);
        update q;

        /** Query order from quote id */
        List<Order> orderList = queryRecordsFromIdsAndObjectName(
            new Set<Id>{quoteId},              // Set<Id> idSet (to bind to in where clause)
            'Order',                            // String objectName
            'WHERE SBQQ__Quote__c IN :idSet'    // String whereClause
        );
        return orderList[0];
    }

    /** Create Order from Opportunity **/
    public static Order createAutomatedOrderFromOpportunity(Id oppId) {
        Opportunity obj = new Opportunity(Id = oppId, SBQQ__Ordered__c= true);
        update obj;

        /** Query order from opp id */
        List<Order> orderList = queryRecordsFromIdsAndObjectName(
            new Set<Id>{oppId},                // Set<Id> idSet (to bind to in where clause)
            'Order',                            // String objectName
            'WHERE OpportunityId IN :idSet'     // String whereClause
        );
        return orderList[0];
    }

    /**
     * Activate order - status and status code are both updated
     * This should update all lines as well. Order lines are queried and returned
     */
    public static List<OrderItem> activateOrder(Order order) {
        order.Status = 'Activated';
        //order.StatusCode = 'A';

        //order.blng__BillingDayOfMonth__c = '1'; //#SFBILLING

        // Update Order:
        update order;

        /** Query order items by order id */
        return queryRecordsFromIdsAndObjectName(
            new Set<Id>{order.Id},     // Set<Id> idSet (to bind to in where clause)
            'OrderItem',                // String objectName
            'WHERE OrderId IN :idSet'   // String whereClause
        );
    }

    /** Contract an Order **/
    public static List<Contract> contractOrder(Order order, Boolean startTests, Boolean stopTests) {
        // Update status and status code
        order.SBQQ__Contracted__c = true;

        if(startTests) { Test.startTest(); }
        // Update Order:
        update order;
        if(stopTests) { Test.stopTest(); }

        /** Query contract with lines (subscriptions) by order **/
        return queryRecordsAndChildrenFromIdsAndObjectNames(
            new Set<Id>{order.Id},              // Set<Id> idSet (to bind to in where clause)
            'Contract',                         // String parentObjName
            'SBQQ__Subscription__c',            // String childObjName
            'SBQQ__Subscriptions__r',           // String childObjRelationshipName
            'WHERE SBQQ__Order__c IN :idSet'    // String whereClause
        );
    }

    /** Contract an Opportunity **/
    public static List<Contract> contractOpportunity(Opportunity opp, Boolean startTests, Boolean stopTests) {
        opp.SBQQ__Contracted__c = true;

        if(startTests) { Test.startTest(); }
        // Update Opportunity:
        update opp;
        if(stopTests) { Test.stopTest(); }

        /** Query contract with lines (subscriptions) by Opportunity **/
        return queryRecordsAndChildrenFromIdsAndObjectNames(
            new Set<Id>{opp.Id},                    // Set<Id> idSet (to bind to in where clause)
            'Contract',                             // String parentObjName
            'SBQQ__Subscription__c',                // String childObjName
            'SBQQ__Subscriptions__r',               // String childObjRelationshipName
            'WHERE SBQQ__Opportunity__c IN :idSet'  // String whereClause
        );

    }

    public static Integer queryCount = 0;
    public static void printQueries(String message) {
        System.debug(Logginglevel.ERROR, message + ' used ' + (Limits.getQueries() - queryCount) + ' queries. The total queries used is ' + Limits.getQueries() + ' CPU TIME: ' + Limits.getCpuTime() + ' ' + Limits.getLimitCpuTime());
        queryCount = Limits.getQueries();
    }

    /**
     * ********************** Query Helpers ********************
     */

    /** Query sobject without subquery */
    public static List<sObject> queryRecordsFromIdsAndObjectName(Set<Id> idSet, String objectName, String whereClause) {
        return (queryRecordsFromIdsAndObjectName(idSet, objectName, null, whereClause));
    }
    public static List<sObject> queryRecordsFromIdsAndObjectName(Set<Id> idSet, String objectName, String additionalReferences, String whereClause) {
        String additionalRef = additionalReferences == null ? '' : additionalReferences;
        String soql = 'SELECT ' + getAllFieldsForSObjAsStr(objectName) + ' ' + additionalRef + ' FROM ' + objectName + ' ' + whereClause;
        return Database.query(soql);
    }

    /** Query sobject with subquery */
    public static List<sObject> queryRecordsAndChildrenFromIdsAndObjectNames(Set<Id> idSet, String parentObjName, String childObjName, String childObjRelationshipName, String whereClause) {
        String soql = 'SELECT ' + getAllFieldsForSObjAsStr(parentObjName) + ', (SELECT ' + getAllFieldsForSObjAsStr(childObjName) + ' FROM ' + childObjRelationshipName + ') FROM ' + parentObjName + ' ' + whereClause;
        return Database.query(soql);
    }

    /** Get all fields for an sobject as a list - helpful for dynamic SOQL */
    public static List<String> getAllFieldsForSobj(String sobjectName) {
        List<String> allFields = new List<String>(Schema.getGlobalDescribe().get(sobjectName).getDescribe().fields.getMap().keySet());
        return allFields;
    }

    /** Get comma delimited string list of all sobject fields */
    public static String getAllFieldsForSObjAsStr(String sobjectName) {
        return String.join(getAllFieldsForSobj(sobjectName), ', ');
    }

    /** Create subscription product */
    public static Product2 createProduct(Id billingRuleId, Id taxRuleId, Id revRecRuleId, Boolean doInsert) {
        Product2 obj = new Product2();
        obj.Name = 'Test Product' + Math.roundToLong(Math.random()*10000000);
        obj.IsActive = true;
        obj.ProductCode = 'CL01';
        obj.Description = 'Product of Clip Licensing';
        obj.Family = 'Analytics';
        obj.ProductCode = 'TestProduct';
        obj.SBQQ__OptionSelectionMethod__c = 'Click';
        obj.SBQQ__ConfigurationType__c = null;
        obj.SBQQ__QuantityEditable__c = true;
        obj.SBQQ__SubscriptionBase__c = 'List';
        obj.SBQQ__Taxable__c = false;
        obj.SBQQ__BlockPricingField__c = 'Quantity';
        obj.SBQQ__Component__c = false;
        obj.SBQQ__DefaultQuantity__c = 1;
        obj.SBQQ__ExcludeFromOpportunity__c = false;
        obj.SBQQ__PriceEditable__c = true;
        obj.SBQQ__PricingMethod__c = 'List';
        obj.SBQQ__SubscriptionPricing__c = 'Fixed Price';
        obj.SBQQ__SubscriptionType__c = 'Renewable';
        obj.SBQQ__SubscriptionTerm__c = 12;
        obj.SBQQ__ChargeType__c = 'Recurring';
        obj.SBQQ__BillingType__c = 'Advance';
        obj.SBQQ__BillingFrequency__c = 'Monthly';
        obj.blng__BillingRule__c = billingRuleId == null ? null : billingRuleId; //#SFBILLING
        obj.blng__TaxRule__c = taxRuleId == null ? null : taxRuleId; //#SFBILLING
        obj.blng__RevenueRecognitionRule__c = revRecRuleId == null ? null : revRecRuleId; //#SFBILLING
        system.debug(obj);
        if (doInsert) { insert obj; }
        system.debug(obj);
        return obj;
    }

    public static Product2 createSubscriptionBundleProduct(String productName, String productCode, Boolean doInsert) {
        Product2 obj = new Product2();
        // decomment for multi currency orgs:
        //obj.CurrencyIsoCode = 'USD';
        obj.Family = 'DDI (NS1, NS1GD)';
        obj.IsActive = true;
        obj.Name = productName;
        obj.ProductCode = productCode;
        obj.SBQQ__AssetConversion__c='One per quote line';
        obj.SBQQ__PricingMethod__c='List';
        obj.SBQQ__SubscriptionBase__c='List';
        obj.SBQQ__SubscriptionPricing__c='Fixed Price';
        obj.SBQQ__SubscriptionType__c='Renewable';

        if (doInsert) {
            insert obj;
        }
        return obj;
    }

    /** Create Contract */
    public static Contract createContract(Account a, Boolean doInsert) {
        return createContract(a, null, doInsert);
    }
    public static Contract createContract(Account a, Opportunity o, Boolean doInsert) {
        Contract obj = new Contract();
        obj.AccountId = a.Id;
        obj.SBQQ__Opportunity__c = o == null ? null : o.Id;
        obj.Status = 'Draft';
        obj.StartDate = Date.Today();
        obj.ContractTerm = 12;

        if (doInsert) {
            insert obj;
        }

        return obj;
    }

    /** Create Subscription */
    public static SBQQ__Subscription__c createSubscription(Account a, Product2 p, Contract contract, Boolean doInsert) {
        SBQQ__Subscription__c obj = new SBQQ__Subscription__c();
        obj.SBQQ__Account__c = a.Id;
        obj.SBQQ__Product__c = p.Id;
        obj.SBQQ__Contract__c = contract.Id;
        obj.SBQQ__Quantity__c = 10.00;
        obj.SBQQ__RevisedSubscription__c = obj.Id;

        if (doInsert) {
            insert obj;
        }

        return obj;
    }

    /**
     * @description this method sets up a contract or series of contracts for renewal, equivalent of getting a contract in a
     *   state where Renewal Quoted can be checked.
     *
     * @param Integer numOfSubscriptionProducts -> number of asset products to create
     * @param Integer numOfAssetProducts -> number of products to create
     * @param Integer numOfContracts -> number of contracts to create
     * @param Integer numOfSubsPerContract -> number of subscriptions to create on each contract
     */
    public static Account account_contractRenewalRelated;
    public static List<Contract> contractsToInsertRenewalRelated;
    public static void setupTestData_contractRenewalRelated(Integer numOfSubscriptionProducts, Integer numOfAssetProducts, Integer numOfContracts, Integer numOfSubsPerContract) {
        account_contractRenewalRelated = new Account(Name = 'Test Account');
        insert account_contractRenewalRelated;

        List<Product2> productsToInsert = new List<Product2>();
        for(Integer i = 0; i < numOfSubscriptionProducts; i++) {
            Product2 p = createSubscriptionBundleProduct(
                'Subscription Bundle Product XYZ' + i,
                'SBP-XYZ-111' + i,
                false
            );
            productsToInsert.add(p);
        }

        /*for(Integer i = 0; i < numOfAssetProducts; i++) {
            Product2 p = createProduct(
                'Asset Bundle Product XYZ' + i,
                'Non-Subscription',
                'SBP-XYZ-111' + i,
                null,
                null,
                null,
                true,
                false
            );
            productsToInsert.add(p);
        }*/

        insert productsToInsert;

        contractsToInsertRenewalRelated = new List<Contract>();
        for(Integer i = 0; i < numOfContracts; i++) {
            Contract c = createContract(account_contractRenewalRelated, false);
            c.AccountId = account_contractRenewalRelated.Id;
            c.Status = 'Draft';
            //c.EndDate = System.today() + 30;
            contractsToInsertRenewalRelated.add(c);
        }
        insert contractsToInsertRenewalRelated;

        List<SObject> subsToInsert = new List<SObject>();
        for(Integer i = 0; i < numOfContracts; i++) {
            for(Integer j = 0; j < numOfSubsPerContract; j++) {
                SBQQ__Subscription__c s = createSubscription(account_contractRenewalRelated, productsToInsert[j], contractsToInsertRenewalRelated[i], false);
                s.SBQQ__Quantity__c = 1;
                s.SBQQ__RenewalQuantity__c = 1;
                s.SBQQ__SubscriptionStartDate__c = System.today();
                subsToInsert.add(s);
            }
        }

        /*for(Integer i = 0; i < numOfContracts; i++) {
            for(Integer j = 0; j < numOfAssetProducts; j++) {
                Asset s = createAsset(account_contractRenewalRelated, productsToInsert[numOfSubscriptionProducts + j], contractsToInsertRenewalRelated[i], false);
                s.SBQQ__Quantity__c = 1;
                s.SBQQ__RenewalQuantity__c = 1;
                s.SBQQ__SubscriptionStartDate__c = System.today();
                subsToInsert.add(s);
            }
        }*/

        TriggerHandler.bypass('SubscriptionTriggerHandler');
        insert subsToInsert;
    }

    /**
     * ************  SALESFORCE BILLING CONFIGURATIONS ********************
     */

    public static Order createOrder(blng__PaymentMethod__c paymentMethod, Opportunity opp, SBQQ__Quote__c quote, Boolean doInsert) {
        Order order = new Order();
        order.AccountId = opp.AccountId;
        order.BillingCity = 'Abilene';
        order.BillingCountry = 'USA';
        order.BillingPostalCode = '79606';
        order.BillingState = 'TX';
        order.BillingStreet = '4602 Marlboro Dr.';
        order.EffectiveDate = Date.today();
        order.OpportunityId = opp.Id;
        order.Pricebook2Id = opp.Pricebook2Id;
        order.SBQQ__ContractingMethod__c = 'Single Contract';
        order.SBQQ__PaymentTerm__c = 'Net 30';
        order.SBQQ__PriceCalcStatus__c = 'Completed';
        order.SBQQ__Quote__c = quote.Id;
        order.ShippingCity = 'Abilene';
        order.ShippingCountry = 'USA';
        order.ShippingPostalCode = '79606';
        order.ShippingState = 'TX';
        order.ShippingStreet = '4602 Marlboro Dr.';
        order.Status = 'Draft';
        order.Type = 'New';

        order.blng__BillingDayOfMonth__c = String.valueOf(Date.today().day());

        if (doInsert) { insert order; }
        return order;
    }

    public static blng__BillingRule__c createBillingRule(Boolean doInsert) {
        blng__BillingRule__c obj = new blng__BillingRule__c();
        obj.Name ='Generate Invoice - Separate Partial Period';
        obj.blng__Active__c = true;
        obj.blng__GenerateInvoices__c = 'Yes';
        obj.blng__InitialBillingTrigger__c = 'Order Product Activation Date';
        obj.blng__PartialPeriodTreatment__c = 'Separate';
        //obj.CurrencyIsoCode = 'USD'; // Uncomment for multi-currency orgs
        if (doInsert) { insert obj; }
        return obj;
    }

    public static blng__BillingRule__c createBillingRuleDoNotInvoice(Boolean doInsert) {
        blng__BillingRule__c obj = new blng__BillingRule__c();
        obj.Name = 'Don\'t Generate Invoice - Separate Partial Period';
        obj.blng__Active__c = true;
        obj.blng__GenerateInvoices__c = 'No';
        obj.blng__InitialBillingTrigger__c = 'Order Product Activation Date';
        obj.blng__PartialPeriodTreatment__c = 'Separate';
        if (doInsert) { insert obj; }
        return obj;
    }

    public static blng__GLAccount__c createGLAccount(Boolean doInsert) {
        blng__GLAccount__c obj = new blng__GLAccount__c();
        obj.Name = 'GL Account 1';
        obj.blng__Active__c = true;
        obj.blng__GLAccountDescription__c = 'Generic GL Account.';
        obj.blng__GLAccountNumber__c = '0001';
        System.debug('GL ACCOUNT: ' + obj);
        if (doInsert) { insert obj; }
        return obj;
    }

    public static blng__GLTreatment__c createGLTreatment(blng__GLAccount__c glAccount, blng__GLRule__c glRule, blng__LegalEntity__c legalEntity, Boolean doInsert) {
        blng__GLTreatment__c obj = new blng__GLTreatment__c();
        obj.Name = 'Standard GL Treatment';
        obj.blng__GLLegalEntity__c = legalEntity.Id;
        obj.blng__Active__c = true;
        obj.blng__CreditGLAccount__c = glAccount.Id;
        obj.blng__DebitGLAccount__c = glAccount.Id;
        obj.blng__GLRule__c = glRule.Id;
        obj.blng__UniqueId__c = 'TEST';//String.valueOf(glRule.Id).toLowerCase() + String.valueOf(legalEntity.Id).toLowerCase();
        System.debug('GL TREATMENT: ' + obj);
        if (doInsert) { insert obj; }
        return obj;
    }

    public static blng__RevenueRecognitionTreatment__c createRevRecTreatment(blng__RevenueRecognitionRule__c revRecRule,
        blng__GLRule__c glRule,
        blng__FinanceBook__c finBook,
        blng__RevenueDistributionMethod__c revDistMethod,
        blng__LegalEntity__c legalEntity,
        Boolean doInsert) {
        blng__RevenueRecognitionTreatment__c obj = new blng__RevenueRecognitionTreatment__c();
        obj.Name ='Standard Revenue Recognition Treatment - Order Activation';
        obj.blng__Active__c = true;
        obj.blng__RevenueLegalEntity__c = legalEntity.Id;
        obj.blng__ProcessingOrder__c = 1.0;
        obj.blng__Type__c = 'Percentage';
        obj.blng__Percentage__c = 100.0;
        obj.blng__RevenueRecognitionRule__c = revRecRule.Id;
        obj.blng__RevenueGLRule__c = glRule.Id;
        obj.blng__RevenueFinanceBook__c = finBook.Id;
        obj.blng__RevenueScheduleCreationAction__c = 'Order Activation';
        obj.blng__RevenueDistributionMethod__c = revDistMethod.Id;
        if (doInsert) { insert obj; }
        return obj;
    }

    /** Finance periods - this is optional in most use-cases */
    public static List<blng__FinancePeriod__c> createFinancePeriods(Id legalEntityId, Id finBookId, Date startDate, Integer numPeriods) {
        List<blng__FinancePeriod__c> periods = new List<blng__FinancePeriod__c>();
        for(Integer i = 0; i < numPeriods; i++) {
            periods.add(new blng__FinancePeriod__c(
                Name = String.valueOf(startDate.year()) + '-' + String.valueOf(startDate.month()),
                blng__LegalEntity__c = legalEntityId,
                blng__FinanceBook__c = finBookId,
                blng__PeriodEndDate__c = startDate.addMonths(1).addDays(-1),
                blng__PeriodStartDate__c = startDate,
                blng__PeriodStatus__c = 'Open'
            ));
            startDate = startDate.addMonths(1);
        }
        insert periods;
        return periods;
    }

    private static List<blng__FinancePeriod__c> createFinancePeriods(blng__FinanceBook__c finBook, Integer numYears, blng__LegalEntity__c legalEntity) {
        List<blng__FinancePeriod__c> periods = new List<blng__FinancePeriod__c>();
        Date today = Date.today();
        Integer currDay = today.day();
        Integer currMonth = today.month();
        Integer currYear = today.year();
        for(Integer year = 0; year < numYears; year++) {
            for(Integer month = 0; month < 12; month++) {
                Date currDate = today.addYears(year).addMonths(month);
                Date startDate = Date.newInstance(currDate.year(), currDate.month(), 1);
                Date endDate = Date.newInstance(currDate.year(), currDate.month(), 1).addMonths(1).addDays(-1);
                String uniqueIdDate = String.valueOf(startDate.year())+String.valueOf(startDate.month())+String.valueOf(startDate.day())+String.valueOf(endDate.year())+String.valueOf(endDate.month())+String.valueOf(endDate.day());

                blng__FinancePeriod__c financePeriod = new blng__FinancePeriod__c();
                financePeriod.blng__FinanceBook__c = finBook.Id;
                financePeriod.blng__LegalEntity__c = legalEntity.Id;
                financePeriod.blng__PeriodStartDate__c = startDate;
                financePeriod.blng__PeriodEndDate__c = endDate;
                financePeriod.blng__PeriodStatus__c = 'Open';
                //financePeriod.blng__UniqueId__c = finBook.Id+uniqueIdDate+'usd';
                periods.add(financePeriod);
            }
        }
        return periods;
    }

    public static blng__TaxRule__c createTaxRule(Boolean doInsert) {
        blng__TaxRule__c obj = new blng__TaxRule__c();
        obj.Name ='No Tax Calculation';
        obj.blng__Active__c = true;
        obj.blng__TaxableYesNo__c = 'Yes';
        //obj.CurrencyIsoCode = 'USD'; // Uncomment for multi-currency orgs
        if (doInsert) { insert obj; }
        return obj;
    }

    public static blng__RevenueRecognitionRule__c createRevRecRule(Boolean doInsert) {
        blng__RevenueRecognitionRule__c obj = new blng__RevenueRecognitionRule__c();
        obj.Name ='Standard Revenue Recognition Rule';
        obj.blng__Active__c = true;
        obj.blng__CreateRevenueSchedule__c = 'Yes';
        //obj.CurrencyIsoCode = 'USD'; // Uncomment for multi-currency orgs
        if (doInsert) { insert obj; }
        return obj;
    }

    public static blng__GLRule__c createGlRule(Boolean doInsert) {
        blng__GLRule__c obj = new blng__GLRule__c();
        obj.Name ='Standard GL Rule';
        obj.blng__Active__c = true;
        //obj.CurrencyIsoCode = 'USD'; // Uncomment for multi-currency orgs
        if (doInsert) { insert obj; }
        return obj;
    }

    public static blng__FinanceBook__c createFinanceBookRevenue(Boolean doInsert) {
        blng__FinanceBook__c obj = new blng__FinanceBook__c();
        obj.Name ='Accounting Book';
        obj.blng__Active__c = true;
        obj.blng__PeriodType__c = 'Accounting';
        //obj.CurrencyIsoCode = 'USD'; // Uncomment for multi-currency orgs
        if (doInsert) { insert obj; }
        return obj;
    }

    public static blng__FinanceBook__c createFinanceBookAccounting(Boolean doInsert) {
        blng__FinanceBook__c obj = new blng__FinanceBook__c();
        obj.Name ='Revenue Book';
        obj.blng__Active__c = true;
        obj.blng__PeriodType__c = 'Revenue';
        //obj.CurrencyIsoCode = 'USD'; // Uncomment for multi-currency orgs
        if (doInsert) { insert obj; }
        return obj;
    }

    public static blng__BillingTreatment__c createBillingTreatment(blng__BillingRule__c billingRule,
        blng__GLRule__c glRule,
        blng__FinanceBook__c finBook,
        Boolean doInsert) {
        blng__BillingTreatment__c obj = new blng__BillingTreatment__c();
        obj.Name ='Standard Billing Treatment';
        obj.blng__Active__c = true;
        //obj.blng__BillingLegalEntity__c = 'Revenue';
        obj.blng__BillingGLRule__c = glRule.Id;
        obj.blng__BillingFinanceBook__c = finBook.Id;
        obj.blng__BillingRule__c = billingRule.Id;
        //obj.CurrencyIsoCode = 'USD'; // Uncomment for multi-currency orgs
        if (doInsert) { insert obj; }
        return obj;
    }
    public static blng__BillingTreatment__c createBillingTreatment(blng__BillingRule__c billingRule,
        blng__GLRule__c glRule,
        blng__FinanceBook__c finBook,
        blng__LegalEntity__c legalEntity,
        Boolean doInsert) {
        blng__BillingTreatment__c obj = createBillingTreatment(billingRule, glRule, finBook, false);
        obj.blng__BillingLegalEntity__c = legalEntity.Id;
        if (doInsert) { insert obj; }
        return obj;
    }

    public static blng__RevenueDistributionMethod__c createRevenueDistMethod(Boolean doInsert) {
        blng__RevenueDistributionMethod__c obj = new blng__RevenueDistributionMethod__c();
        obj.Name ='Standard Revenue Distribution Method - Order';
        obj.blng__Active__c = true;
        obj.blng__RevenueTransactionCreationProcess__c = 'Automatic';
        obj.blng__MonthlyRecognitionProration__c = 'Number of Days';
        obj.blng__Type__c = 'Order';
        obj.blng__DistributionMethod__c = 'Monthly';
        obj.blng__RevenueScheduleTermStartDate__c = 'Order Product Start Date';
        obj.blng__RevenueScheduleTermEndDate__c = 'Order Product End Date';
        //obj.CurrencyIsoCode = 'USD'; // Uncomment for multi-currency orgs
        if (doInsert) { insert obj; }
        return obj;
    }

    public class FinanceTestObjects {
        public blng__LegalEntity__c legalEntity {get; set;}
        public blng__BillingRule__c billingRule {get; set;}
        public blng__BillingRule__c billingRuleDoNotInvoice {get; set;}
        public blng__RevenueRecognitionRule__c revRecRule {get; set;}
        public blng__TaxRule__c taxRule {get; set;}
        public blng__GLRule__c glRule {get; set;}
        public blng__FinanceBook__c financeBookRevenue {get; set;}
        public blng__FinanceBook__c financeBookAccounting {get; set;}
        public blng__BillingTreatment__c billingTreatment {get; set;}
        public blng__RevenueDistributionMethod__c revenueDistMethod {get; set;}
        public blng__RevenueRecognitionTreatment__c revRecTreatment {get; set;}
        public blng__GLAccount__c gLAccount {get; set;}
        public blng__GLTreatment__c gLTreatment {get; set;}
        public List<blng__FinancePeriod__c> revenueFinancePeriod {get; set;}
        public List<blng__FinancePeriod__c> acconutingFinancePeriod {get; set;}
    }

    public static blng__BillingPrefix__c createBillingPrefix() {

        blng__BillingPrefix__c billingPrefix = new blng__BillingPrefix__c();
        billingPrefix.blng__BarPrefix__c = 'blng__';
        billingPrefix.blng__DotPrefix__c = 'blng.';
        billingPrefix.blng__RawPrefix__c = 'blng';

        insert billingPrefix;
        return billingPrefix;
    }

    /** Create default legal entity */
    public static blng__LegalEntity__c createLegalEntity(Boolean doInsert) {
        blng__LegalEntity__c obj = new blng__LegalEntity__c();
        obj.Name = 'AvalaraForPrimePay';
        obj.blng__Active__c = true;
        obj.blng__City__c = 'West chester';
        obj.blng__Country__c = 'USA';
        obj.blng__State__c = 'PA';
        obj.blng__Street1__c = '1487 Dunwoody Drive';
        obj.blng__ZipPostalCode__c = '19380';
        if (doInsert) { insert obj; }
        return obj;
    }

    public static List<blng__BillingConfig__c> createBillingConfigs() {
        List<blng__BillingConfig__c> billingConfigs = new List<blng__BillingConfig__c>();

        billingConfigs.add(new blng__BillingConfig__c(
            Name = 'INSERT_SAMPLE_DATA',
            blng__BooleanValue__c = false,
            blng__Description__c = 'Insert Sample Data',
            blng__FieldType__c = 'Boolean'));

        billingConfigs.add(new blng__BillingConfig__c(
            Name = 'USAGE_RATING_PROCESS',
            blng__BooleanValue__c = false,
            blng__Category__c = 'General',
            blng__Description__c = 'Usage Rating Process based on',
            blng__FieldType__c = 'Picklist',
            blng__PicklistIndicator__c = 'UsageRatingProcessList',
            blng__Sequence__c = 9,
            blng__StringValue__c = 'On Trigger'));

        billingConfigs.add(new blng__BillingConfig__c(
            Name = 'BILLING_REMAINDER_PROCESS',
            blng__BooleanValue__c = false,
            blng__Category__c = 'Invoice',
            blng__Description__c = 'Billing Remainder Process',
            blng__FieldType__c = 'Picklist',
            blng__PicklistIndicator__c = 'billingRemainderProcessList',
            blng__Sequence__c = 5,
            blng__StringValue__c = 'Last Period'));

        billingConfigs.add(new blng__BillingConfig__c(
            Name = 'PARTIAL_PERIOD_BILLING_PRORATION',
            blng__BooleanValue__c = false,
            blng__Category__c = 'Invoice',
            blng__Description__c = 'Partial Proration Type',
            blng__FieldType__c = 'Picklist',
            blng__PicklistIndicator__c = 'PartialProrationTypeList',
            blng__Sequence__c = 3,
            blng__StringValue__c = 'Month + Daily'));

        billingConfigs.add(new blng__BillingConfig__c(
            Name = 'PERIOD_PRICE_ROUNDING',
            blng__BooleanValue__c = false,
            blng__Category__c = 'General',
            blng__Description__c = 'Billable Unit Price Rounding',
            blng__FieldType__c = 'Picklist',
            blng__PicklistIndicator__c = 'PeriodPriceRoundingList',
            blng__Sequence__c = 8,
            blng__StringValue__c = 'HALF_UP'));

        billingConfigs.add(new blng__BillingConfig__c(
            Name = 'REVENUE_REMAINDER_PROCESS',
            blng__BooleanValue__c = false,
            blng__Category__c = 'Invoice',
            blng__Description__c = 'Revenue Remainder Process',
            blng__FieldType__c = 'Picklist',
            blng__PicklistIndicator__c = 'RevenueRemainderProcessList',
            blng__Sequence__c = 6,
            blng__StringValue__c = 'Last Period'));

        billingConfigs.add(new blng__BillingConfig__c(
            Name = 'SAVE_CREDIT_CARD_ON_PAYMENT_PAGE',
            blng__BooleanValue__c = false,
            blng__Category__c = 'General',
            blng__Description__c = 'Save credit card details',
            blng__FieldType__c = 'Boolean',
            blng__Sequence__c = 6));

        billingConfigs.add(new blng__BillingConfig__c(
            Name = 'ENABLE_STATE_AND_COUNTRY_PICKLIST',
            blng__BooleanValue__c = false,
            blng__Category__c = 'General',
            blng__Description__c = 'Enable state and country picklist in Site Page and Virtual Terminal(works when state and country feature is enabled in Salesforce)',
            blng__FieldType__c = 'Boolean',
            blng__Sequence__c = 6));

        billingConfigs.add(new blng__BillingConfig__c(
            Name = 'ACCOUNT_LEGAL_ENTITY_FIELD_NAME',
            blng__BooleanValue__c = false,
            blng__Category__c = 'General',
            blng__Description__c = 'Select Account field that holds the legal entity information',
            blng__FieldType__c = 'String',
            blng__PicklistIndicator__c = 'Account',
            blng__Sequence__c = 1,
            blng__StringValue__c = 'AccountNumber'));

        billingConfigs.add(new blng__BillingConfig__c(
            Name = 'ADVANCED_AR_APPLICATION',
            blng__BooleanValue__c = true,
            blng__Category__c = 'Invoice',
            blng__Description__c = 'Advanced AR application',
            blng__FieldType__c = 'Boolean',
            blng__Sequence__c = 2));

        billingConfigs.add(new blng__BillingConfig__c(
            Name = 'ORDER_LEGAL_ENTITY_FIELD_NAME',
            blng__BooleanValue__c = false,
            blng__Category__c = 'General',
            blng__Description__c = 'Select Order field that holds the Legal Entity (This will override the Account Legal Entity field)',
            blng__FieldType__c = 'String',
            blng__PicklistIndicator__c = 'ORDER_FIELD_NAME',
            blng__Sequence__c = 3,
            blng__StringValue__c = 'Order Number'));

        billingConfigs.add(new blng__BillingConfig__c(
            Name = 'ALIGN_BILLDAYOFMONTH_TO_ORDERSTARTDATE',
            blng__BooleanValue__c = true,
            blng__Category__c = 'General',
            blng__Description__c = 'Align Billing day of month to Order start date.',
            blng__FieldType__c = 'Boolean',
            blng__Sequence__c = 3));

        billingConfigs.add(new blng__BillingConfig__c(
            Name = 'PRORATION_TYPE',
            blng__BooleanValue__c = false,
            blng__Category__c = 'Invoice',
            blng__Description__c = 'Proration type.',
            blng__FieldType__c = 'String',
            blng__Sequence__c = 3,
            blng__StringValue__c = 'Calendar Days'));

        billingConfigs.add(new blng__BillingConfig__c(
            Name = 'INVOICE_TO_BE_CHARGED_ON',
            blng__BooleanValue__c = false,
            blng__Category__c = 'Invoice',
            blng__Description__c = 'Payment Scheduler to pickup unpaid invoices on OR after',
            blng__FieldType__c = 'String',
            blng__Sequence__c = 2,
            blng__StringValue__c = 'Due Date'));

        billingConfigs.add(new blng__BillingConfig__c(
            Name = 'AVALARA_AVATAX',
            blng__BooleanValue__c = false,
            blng__Category__c = 'Tax',
            blng__StringValue__c = 'Avalara AvaTax'));

        billingConfigs.add(new blng__BillingConfig__c(
            Name = 'DISABLE_TRIGGERS',
            blng__BooleanValue__c = false,
            blng__Category__c = 'General',
            blng__Description__c = 'Disable triggers',
            blng__FieldType__c = 'Boolean'));

        billingConfigs.add(new blng__BillingConfig__c(
            Name = 'PAYMENT_METHOD_DISPLAY',
            blng__BooleanValue__c = false,
            blng__Category__c = 'Payment',
            blng__Description__c = 'Payment Method Display',
            blng__FieldType__c = 'Picklist',
            blng__PicklistIndicator__c = 'PaymentMethodDisplayList',
            blng__Sequence__c = 1,
            blng__StringValue__c = 'Nickname'));

        billingConfigs.add(new blng__BillingConfig__c(
            Name = 'CARD_MAPPING',
            blng__BooleanValue__c = false,
            blng__Category__c = 'Payment',
            blng__Description__c = 'Card Mapping',
            blng__FieldType__c = 'String',
            blng__Sequence__c = 2));

        billingConfigs.add(new blng__BillingConfig__c(
            Name = 'TAX_CALCULATION_BASED_ON',
            blng__BooleanValue__c = false,
            blng__Category__c = 'General',
            blng__Description__c = 'Tax calculation is based on?',
            blng__FieldType__c = 'Picklist',
            blng__PicklistIndicator__c = 'TaxcCalculationList',
            blng__Sequence__c = 3,
            blng__StringValue__c = 'Order: Account Shipping Address'));

        billingConfigs.add(new blng__BillingConfig__c(
            Name = 'TAX_EXEMPT',
            blng__BooleanValue__c = false,
            blng__Sequence__c = 9));

        insert billingConfigs;
        return billingConfigs;
    }

    public static blng__PaymentMethod__c createPaymentMethod(Account acct, Boolean doInsert) {
        blng__PaymentMethod__c paymentMethod = new blng__PaymentMethod__c();
        paymentMethod.blng__Account__c = acct.Id;
        paymentMethod.blng__Active__c = true;
        paymentMethod.blng__BankAccountType__c = 'Checking';
        paymentMethod.blng__PaymentType__c = 'ACH';
        paymentMethod.blng__BankRoutingCode__c = '123456789';
        paymentMethod.blng__BankName__c = 'Test Bank Name';
        paymentMethod.blng__BankAccountNumber__c = '12345678910';
        paymentMethod.blng__BankAccountName__c = 'Test Bank Account Name';

        if (doInsert) { insert paymentMethod; }
        return paymentMethod;
    }

    public static blng__Invoice__c createInvoice(Account account, Order order, Boolean doInsert) {
        return createInvoice(account, order, doInsert, '14973936196600017A00000OqeglQABNet 30');
    }

    public static blng__Invoice__c createInvoice(Account account, Order order, Boolean doInsert, String uniqeId) {
        blng__Invoice__c invoice = new blng__Invoice__c();
        invoice.blng__InvoiceStatus__c = 'Posted';
        invoice.blng__Account__c = account.Id;
        invoice.blng__DueDate__c = Date.today();
        invoice.blng__InvoiceDate__c = Date.today();
        invoice.blng__Order__c = order.Id;
        invoice.blng__TargetDate__c = Date.today();
        invoice.blng__UniqueId__c = uniqeId;
        if (doInsert) { insert invoice; }
        return invoice;
    }

    public static blng__InvoiceLine__c createInvoiceLine(blng__Invoice__c invoice, OrderItem op, Product2 p, Boolean doInsert) {
        return createInvoiceLine(invoice, op, p, doInsert, '8027A000000PUXOQA4_2017-6-13_2019-6-12___a1z7A000000Hn6iQAC__01t7A000001jG2aQAE');
    }

    public static blng__InvoiceLine__c createInvoiceLine(blng__Invoice__c invoice, OrderItem op, Product2 p, Boolean doInsert, String uniqeId) {
        blng__InvoiceLine__c invoiceLine = new blng__InvoiceLine__c();
        invoiceLine.Name = 'Branded Content';
        //invoiceLine.CurrencyIsoCode = 'USD'; //uncomment if multicurrency is enabled
        invoiceLine.blng__BillingFinanceBook__c = op.blng__FinanceBookAccounting__c;
        invoiceLine.blng__BillingRule__c = op.blng__BillingRule__c;
        invoiceLine.blng__BillingTreatment__c = op.blng__BillingTreatment__c;
        invoiceLine.blng__CalculatedQuantity__c = 1;
        invoiceLine.blng__ChargeDate__c = Date.today();
        invoiceLine.blng__ChargeType__c = 'One-Time';
        invoiceLine.blng__EndDate__c = Date.today().addMonths(1);
        invoiceLine.blng__InvoiceLineState__c = 'Regular';
        invoiceLine.blng__InvoiceLineStatus__c = 'Posted';
        invoiceLine.blng__Invoice__c = invoice.Id;
        invoiceLine.blng__LegalEntityReference__c = op.blng__LegalEntityReference__c;
        invoiceLine.blng__NegativeLineConversion__c = 0;
        invoiceLine.blng__OrderProduct__c = op.Id;
        invoiceLine.blng__Product__c = p.Id;
        invoiceLine.blng__Quantity__c = 1;
        invoiceLine.blng__StartDate__c = Date.today();
        invoiceLine.blng__Subtotal__c = 100;
        invoiceLine.blng__TaxErrorMessage__c = 'This line is not taxable';
        invoiceLine.blng__TaxRule__c = op.blng__TaxRule__c;
        invoiceLine.blng__TaxStatus__c = 'Warning';
        //invoiceLine.blng__TaxTreatment__c = 'a2g7A000000DKFLQA4';
        invoiceLine.blng__TotalAmount__c = 100;
        invoiceLine.blng__UniqueId__c = uniqeId;
        invoiceLine.blng__UnitPrice__c = 100;
        if (doInsert) { insert invoiceLine; }
        return invoiceLine;
    }

    public static FinanceTestObjects createFinanceObjects() {
        // CREATE GLOBAL SETTINGS
        createBillingPrefix();
        createBillingConfigs();
        FinanceTestObjects fin = new FinanceTestObjects();
        fin.legalEntity = createLegalEntity(true);
        fin.billingRule = createBillingRule(true);
        fin.billingRuleDoNotInvoice = createBillingRuleDoNotInvoice(true);
        fin.revRecRule = createRevRecRule(true);
        fin.taxRule = createTaxRule(true);
        fin.glRule = createGlRule(true);
        fin.financeBookRevenue = createFinanceBookRevenue(true);
        fin.financeBookAccounting = createFinanceBookAccounting(true);
        fin.billingTreatment = createBillingTreatment(fin.billingRule, fin.glRule, fin.financeBookRevenue, fin.legalEntity, true);

        fin.gLAccount = createGLAccount(true);
        fin.gLTreatment = createGLTreatment(fin.gLAccount, fin.glRule, fin.legalEntity, true);

        fin.revenueDistMethod = createRevenueDistMethod(true);
        fin.revRecTreatment = createRevRecTreatment(fin.revRecRule, fin.glRule, fin.financeBookAccounting, fin.revenueDistMethod, fin.legalEntity, true);
        fin.revenueFinancePeriod = createFinancePeriods(fin.financeBookRevenue, 3, fin.legalEntity);
        fin.acconutingFinancePeriod = createFinancePeriods(fin.financeBookAccounting, 3, fin.legalEntity);

        List<blng__FinancePeriod__c> periods = new List<blng__FinancePeriod__c>();
        periods.addAll(fin.revenueFinancePeriod);
        periods.addAll(fin.acconutingFinancePeriod);

        insert periods;

        System.debug(LoggingLevel.WARN, fin);

        return fin;

    }

    public static OrderItem createOrderLine(
        Order order, SBQQ__QuoteLine__c quoteLine, Product2 product, PricebookEntry pbe, blng__LegalEntity__c legalEntity, Boolean doInsert
    ) {
        OrderItem orderItem = new OrderItem();
        orderItem.EndDate = Date.today().addMonths(1).addDays(-1);
        orderItem.OrderId = order.Id;
        orderItem.PricebookEntryId = pbe.Id;
        orderItem.Product2Id = product.Id;
        orderItem.Quantity = 1;
        orderItem.SBQQ__BillingFrequency__c = 'Annual';
        orderItem.SBQQ__ChargeType__c = 'Usage';
        orderItem.SBQQ__DefaultSubscriptionTerm__c = 364;
        orderItem.SBQQ__OrderedQuantity__c = 1;
        orderItem.SBQQ__QuoteLine__c = quoteLine.Id;
        orderItem.SBQQ__QuotedQuantity__c = 1;
        orderItem.SBQQ__SubscriptionPricing__c = 'Fixed Price';
        orderItem.SBQQ__SubscriptionTerm__c = 364;
        //orderItem.SBQQ__TotalAmount__c = 650;
        orderItem.SBQQ__UnproratedNetPrice__c = 650;
        orderItem.ServiceDate = Date.today();
        orderItem.UnitPrice = 650;
        orderItem.blng__BillableUnitPrice__c = 650;
        orderItem.blng__BillingRule__c = product.blng__BillingRule__c;
        //orderItem.blng__InvoiceRunStatus__c = 'Queued for Invoice';
        orderItem.blng__RevenueRecognitionRule__c = product.blng__RevenueRecognitionRule__c;
        orderItem.blng__TaxRule__c = product.blng__TaxRule__c;
        orderItem.blng__LegalEntity__c = legalEntity.Id;
        orderItem.blng__UniqueId__c = '8016C000000HRNaQAO-01u6C000000mQQtQAM-a5I6C00000055MxUAI';

        if (doInsert) { insert orderItem; }
        return orderItem;
    }

    public static SBQQ__PriceSchedule__c createPriceSchedule(Order o, OrderItem op, Product2 p, SBQQ__Quote__c q, SBQQ__QuoteLine__c ql, Boolean doInsert) {
        SBQQ__PriceSchedule__c priceSchedule = new SBQQ__PriceSchedule__c();
        //priceSchedule.Name = 'IoT SGW Volume Discount Schedule';
        priceSchedule.SBQQ__DiscountUnit__c = 'Percent';
        priceSchedule.SBQQ__OrderProduct__c = op.Id;
        priceSchedule.SBQQ__Order__c = O.Id;
        priceSchedule.SBQQ__PriceScale__c = 2;
        priceSchedule.SBQQ__PriceType__c = 'Volume';
        priceSchedule.SBQQ__Pricebook__c = Test.getStandardPricebookId();
        priceSchedule.SBQQ__Product__c = p.Id;
        priceSchedule.SBQQ__QuoteLineQuantityField__c = 'Quantity';
        priceSchedule.SBQQ__QuoteLine__c = ql.Id;
        priceSchedule.SBQQ__Quote__c = q.Id;
        System.debug(LoggingLevel.WARN, 'createPriceSchedule() ' + priceSchedule);

        if (doInsert) { insert priceSchedule; }
        return priceSchedule;
    }

    public static SBQQ__PriceTier__c createPriceTier(SBQQ__PriceSchedule__c sc, String name, Integer num, Decimal price, Integer lower, Integer upper, Boolean doInsert) {
        SBQQ__PriceTier__c priceTier = new SBQQ__PriceTier__c();
        priceTier.Name = name;
        priceTier.SBQQ__LowerBound__c = lower;
        priceTier.SBQQ__UpperBound__c = upper;
        priceTier.SBQQ__Number__c = num;
        priceTier.SBQQ__PriceModel__c = 'Per Unit';
        priceTier.SBQQ__PriceSchedule__c = sc.Id;
        priceTier.SBQQ__Price__c = price;
        System.debug(LoggingLevel.WARN, 'createPriceTier() ' + priceTier);

        if (doInsert) { insert priceTier; }
        return priceTier;
    }

    /**
     * Create invoice for order.
     * Returns Invoice with invoice line subquery for easy reference
     */
    public static List<blng__Invoice__c> billOrderNow(Order order) {
        // Update status and status code
        order.blng__BillNow__c = true;
        update order;
        // order line: SBQQ__Status__c
        return queryRecordsAndChildrenFromIdsAndObjectNames(
            new Set<Id>{order.Id},              // Set<Id> recordIds (to bind to in where clause)
            'blng__Invoice__c',                 // String parentObjName
            'blng__InvoiceLine__c',             // String childObjName
            'blng__InvoiceInvoiceLines__r',     // String childObjRelationshipName
            'WHERE blng__Order__c IN :idSet'    // String whereClause
        );
    }

    /** Create Asset */
    public static Asset createAsset(Account acct, Product2 product, SBQQ__QuoteLine__c quoteLine, Boolean populateDefaultValues, Boolean doInsert) {
        Asset obj = (Asset)Asset.sObjectType.newSObject(
            null, // null will make it the default record type for the user
            populateDefaultValues // loadDefaultValues
        );
        obj.Name = 'Test Asset';
        obj.AccountId = acct.Id;
        obj.Product2Id = product.Id;
        // Decomment if multicurrency is enabled:
        //obj.CurrencyIsoCode = 'USD';
        obj.Status = 'Registered';
        obj.PurchaseDate = System.Today();
        obj.SBQQ__QuoteLine__c = quoteLine == null ? null : quoteLine.Id;
        obj.SerialNumber = '1234567890';

        if(doInsert) {
            insert obj;
        }
        return obj;
    }
}