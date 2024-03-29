public with sharing class JoobleCallout {
    public static Integer resultsPerPage = 500;
    public static List<String> keywordList = new List<String>();
    public static Set<Id> newAppIds = new Set<Id>();
    public static Integer pageNumber = 1;
    public static Integer maxPage = 1;
    public static Boolean maxPageSet = false;
    public static List<Application__c> newApplications = new List<Application__c>();

    @AuraEnabled
    public static List<Application__c> getJoobleListings(String keywords, String location, String fromSearchDate) {
        System.debug('keywords: ' + keywords);
        System.debug('location: ' + location);
        System.debug('fromSearchDate: ' + fromSearchDate);
        // Capture all keywords in a list to check against listings later
        keywordList = keywords.split(' ');
        // Update keywords to just 'Salesforce' if keywords contains 'Salesforce' to minimize API calls
        // Later, keywordList will be used to check if all keywords are present in the title
        if (keywordList.contains('Salesforce')) {
            keywords = 'Salesforce';
        }
        System.debug('keywordList: ' + keywordList);
        System.debug('keywords: ' + keywords);

        // The while loop handles multiple pages of results
        while (pageNumber <= maxPage) {
            System.debug('pageNumber: ' + pageNumber);
            System.debug('maxPage: ' + maxPage);
            HttpRequest req = new HttpRequest();
            req.setEndpoint('callout:JoobleAPI');
            req.setMethod('POST');
            req.setHeader('Content-Type', 'application/json');
            req.setBody('{"keywords":"'+ keywords + '","location":"' + location + '","resultonpage":' + resultsPerPage + ',"datecreatedfrom":"' + fromSearchDate + '","page":"' + String.valueOf(pageNumber) + '"}');
            Http http = new Http();
            HttpResponse res = http.send(req);
            String jsonBody = res.getBody();
            if (!maxPageSet) {
                calcMaxPage(jsonBody);
            }
            String cleanJson = jsonBody.replaceAll('\\\\r\\\\n', '').replaceAll('<b>', '').replaceAll('</b>', '').replaceAll('&nbsp', '');
            Integer statusCode = res.getStatusCode();
            if (statusCode >= 200 && statusCode < 300 && !String.isBlank(cleanJson)) {
                System.debug('statusCode: ' + statusCode);
                processJSON(cleanJson, keywords, fromSearchDate);
            } else {
                System.debug('Jooble callout failed. Status Code: ' + statusCode);
                System.debug('jsonBody: ' + jsonBody);
            }
            pageNumber++;
        }
        System.debug('Exited while loop');
        System.debug('About to call insertApplications()');
        insertApplications();
        return [SELECT Company_Name__c, Position_Title__c, Listing_Date__c FROM Application__c WHERE Id IN :newAppIds];
    }

    public static void processJSON(String jsonBody, String keywords, String fromSearchDate) {
        Boolean containsAllKeywords = false;
        JoobleListingWrapper result = JoobleListingWrapper.parse(jsonBody);
        List<JoobleListingWrapper.Job> listings = result.jobs;
        List<JoobleListingWrapper.Job> salesforceListings = new List<JoobleListingWrapper.Job>();
        for(JoobleListingWrapper.Job listing : listings) {
            for (String keyword : keywordList) {
                if ((listing.title).contains(keyword)) {
                    containsAllKeywords = true;
                } else {
                    containsAllKeywords = false;
                    break;
                }
            }
            // Confirms that all keywords are present in the title and the listing date meets the searchFromDate criteria
            if (containsAllKeywords && (Date.valueOf(listing.updated) >= Date.valueOf(fromSearchDate))){
                salesforceListings.add(listing);
            }
        }
        if (salesforceListings.isEmpty()) {
            System.debug('No Salesforce listings found with exact keyword match.');
        } else {
            System.debug('Number of qualified listings: ' + salesforceListings.size());
            Set<String> matchingIds = checkListingIds(salesforceListings);
            //Create Applications based off of salesforceListings and matchingIds
            createApplications(salesforceListings, matchingIds);
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
        for (JoobleListingWrapper.Job listing : salesforceListings) {
            if (!matchingIds.contains(listing.id)) {
                // Create Application object
                Application__c newApp = new Application__c();
                newApp.Listing_ID__c     = listing.id;
                newApp.Position_Title__c = listing.title.left(40);
                newApp.Company__c        = companyMap.get(listing.company);
                newApp.Location__c       = listing.location;
                newApp.Description__c    = listing.snippet;
                newApp.Listing_URL__c    = listing.link;
                newApp.Listing_Date__c   = Date.valueOf(listing.updated);

                newApplications.add(newApp);
            }
        }
        System.debug('Number of new Applications to insert from page ' + pageNumber + ': ' + newApplications.size());
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
        System.debug('Number of matching Accounts found: ' + matchingAccounts.size());
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

    public static void calcMaxPage(String jsonBody) {
        JoobleListingWrapper result = JoobleListingWrapper.parse(jsonBody);
        System.debug('result.totalCount: ' + result.totalCount);
        maxPage = (Integer) Math.ceil(result.totalCount * 1.0 / resultsPerPage);
        maxPageSet = true;
        System.debug('maxPage: ' + maxPage);
        System.debug('maxPageSet: ' + maxPageSet);
    }

    public static void insertApplications() {
        System.debug('Entered insertApplications');
        System.debug('newApplications.size(): ' + newApplications.size());
        if (!newApplications.isEmpty()) {
            insert newApplications;
            for (Application__c newApp : newApplications) {
                newAppIds.add(newApp.Id);
            }
        }
    }
}