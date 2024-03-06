public with sharing class JoobleCallout {

    public static void getJoobleListings() {
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:JoobleAPI');
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        // Will need to make the body dynamic
        req.setBody('{"keywords":"salesforce","location":"remote","resultonpage":100,"datecreatedfrom":"2024-03-02"}');
        Http http = new Http();
        HttpResponse res = http.send(req);
        String jsonBody = res.getBody();
        String cleanJson = jsonBody.replaceAll('\\\\r\\\\n', '').replaceAll('<b>', '').replaceAll('</b>', '').replaceAll('&nbsp', '');
        Integer statusCode = res.getStatusCode();
        if (statusCode >= 200 && statusCode < 300) {
            System.debug('statusCode: ' + statusCode);
            System.debug('>>> cleanJson: ' + cleanJson);
            processJSON(cleanJson);
        } else {
            System.debug('Jooble callout failed. Status Code: ' + statusCode);
            System.debug('jsonBody: ' + jsonBody);
        }
    }

    public static void processJSON(String jsonBody) {
        JoobleListingWrapper result = JoobleListingWrapper.parse(jsonBody);
        List<JoobleListingWrapper.Job> listings = result.jobs;
        List<JoobleListingWrapper.Job> salesforceListings = new List<JoobleListingWrapper.Job>();
        for(JoobleListingWrapper.Job listing : listings) {
            System.debug('>>' + listing.title + '<< contains both Salesforce & Developer: ' + ((listing.title).contains('Salesforce') && (listing.title).contains('Developer')));
            // The conditional statement below will need to be dynamic based on user, so instead 
            // we may need to have a set of keywords (eg, {'Salesforce', 'developer'}) 
            if ((listing.title).contains('Salesforce') && (listing.title).contains('Developer')) {
                salesforceListings.add(listing);
            }
        }
        if (salesforceListings.isEmpty()) {
            System.debug('No Salesforce listings found');
        } else {
            System.debug('Number of qualified listings: ' + salesforceListings.size());
            Set<String> matchingIds = checkListingIds(salesforceListings);
            System.debug('Matching Ids: ' + matchingIds);
        }
    }


    // Check Jooble IDs on salesforceListings to see if they already exist in Applications
    // If so, ignore these listings (as duplicates).
    public static Set<String> checkListingIds(List<JoobleListingWrapper.Job> salesforceListings) {
        List<String> listingIdsToSearch = new List<String>();
        Set<String> matchingIds = new Set<String>();
        for (JoobleListingWrapper.job listing : salesforceListings) {
            listingIdsToSearch.add(listing.id);
        }
        List<Application__c> matchingApps = [SELECT Id, Listing_ID__c FROM Application__c WHERE Listing_ID__c IN :listingIdsToSearch];
        if (matchingApps.isEmpty()) {
            System.debug('No matching Ids found');
        } else {
            System.debug('Number of duplicate IDs found: ' + matchingApps.size());
            for (Application__c app : matchingApps) {
                matchingIds.add(app.Listing_ID__c);
            }
        }
        return matchingIds;
    }

    //Create Application objects for the listings that are not duplicates
    public static void createApplications(List<JoobleListingWrapper.Job> salesforceListings, Set<String> matchingIds) {
        Map<String,Id> companyMap = checkCompanyNames(salesforceListings);

        List<Application__c> newApplications = new List<Application__c>();
        for (JoobleListingWrapper.Job listing : salesforceListings) {
            if (!matchingIds.contains(listing.id)) {
                // Create Application object
                Application__c newApp = new Application__c();
                newApp.Listing_ID__c = listing.id;
                newApp.Position_Title__c = listing.title;
                newApp.Company__c = companyMap.get(listing.company);
                newApp.Location__c = listing.location;
                newApp.Description__c = listing.snippet;
                newApp.Listing_URL__c = listing.link;
                newApplications.add(newApp);
            }
        }
        insert newApplications;
    }

    // For salesforceListings not found in system, check if any of the Company names already exist. 
    // If so, create a map of name to Id so that it can be used when creating a new Application object. 
    // If not, create a new Company object and add to the map.
    public static Map<String,Id> checkCompanyNames(List<JoobleListingWrapper.Job> salesforceListings) {
        Set<String> companyNames = new Set<String>();
        for (JoobleListingWrapper.Job listing : salesforceListings) {
            companyNames.add(listing.company);
        }
        List<Account> matchingAccounts = [SELECT Id, Name FROM Account WHERE Name IN :companyNames];
        Map<String,Id> companyMap = new Map<String,Id>();
        for (Account account : matchingAccounts) {
            companyMap.put(account.Name, account.Id);
        }
        List<Account> newAccounts = new List<Account>();
        for (JoobleListingWrapper.Job listing : salesforceListings) {
            if (companyMap.get(listing.company) == null) {
                Account newAccount = new Account();
                newAccount.Name = listing.company;
                newAccounts.add(newAccount);
            }
        }
        insert newAccounts;
        for (Account newAccount : newAccounts) {
            companyMap.put(newAccount.Name, newAccount.Id);
        }
        return companyMap;
    }
}