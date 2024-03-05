public with sharing class JoobleCallout {
    public static void processJSON(String jsonBody) {
        JoobleListingWrapper result = JoobleListingWrapper.parse(jsonBody);
        List<JoobleListingWrapper.Job> listings = result.jobs;
        List<JoobleListingWrapper.Job> salesforceListings = new List<JoobleListingWrapper.Job>();
        System.debug('listings: ' + listings);
        for(JoobleListingWrapper.Job listing : listings) {
            System.debug(listing.title + ' contains both Salesforce & Developer: ' + ((listing.title).contains('Salesforce') && (listing.title).contains('Developer')));
            System.debug('listing.snippet: ' + (listing.snippet));
            if ((listing.title).contains('Salesforce') && (listing.title).contains('Developer')) {
                salesforceListings.add(listing);
            }
        }
        System.debug(salesforceListings);
    }
}