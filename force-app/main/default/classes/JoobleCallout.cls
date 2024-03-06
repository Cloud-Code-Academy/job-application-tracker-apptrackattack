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
        System.debug('Number of qualified listings: ' + salesforceListings.size());
        System.debug('__________________________________________');
        for (JoobleListingWrapper.Job listing : salesforceListings){
            System.debug('__________________________________________');
            System.debug('Title: ' + listing.title);
            System.debug('Company: ' + listing.company);
            System.debug('Date posted: ' + listing.updated);
            System.debug('Position link: ' + listing.link);
            System.debug('Listing ID: ' + listing.id);
            System.debug('__________________________________________');
        }
        System.debug('^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^');
        System.debug('^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^');
        System.debug('^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^');
        System.debug('^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^');
        System.debug('^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^');
        System.debug('^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^');
        System.debug('^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^');
        System.debug('^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^');
        System.debug('^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^');
        System.debug('^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^');
    }

    // Check Jooble IDs on salesforceListings to see if they already exist in Applications
    // If so, ignore these listings (as duplicates).
    public static void checkListingIds(List<JoobleListingWrapper.Job> salesforceListings) {
        List<String> listingIdsToSearch = new List<String>();
        for (JoobleListingWrapper.job listing : salesforceListings) {
            listingIdsToSearch.add(listing.id);
        }
        List<Application> matchingApps = [SELECT Id, Listing_ID__c FROM Application WHERE Listing_ID__c IN :listingIdsToSearch];
        if (matchingApps.isEmpty()) {
            System.debug('No matching Ids found');
        } else {
            System.debug('Number of duplicate IDs found: ' + matchingApps.size());
        }
    }

    // For salesforceListings not found in system, check if any of the Company names already exist. 
    // If so, create a map of name to Id so that it can be used when creating a new Application object.


}