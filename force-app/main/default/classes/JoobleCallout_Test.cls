@isTest
private class JoobleCallout_Test {
    @TestSetup
    static void makeData(){
        //Create Accounts
        List<Account> acctsToInsert = new List<Account>();
        for (Integer i=1; i<=3; i++){
            Account acct = new Account(
                Name = 'Test Account ' + i
            );
            acctsToInsert.add(acct);
        }
        insert acctsToInsert;

        //Create Existing Appllications
        List<Application__c> appsToInsert = new List<Application__c>();
        for (Integer i = 1; i <= 3; i++){
            Application__c app = new Application__c(
                Position_Title__c = 'Salesforce Developer',
                Company__c = acctsToInsert[i-1].Id,
                Location__c = 'Remote',
                Listing_ID__c = String.valueOf(i),
                Listing_Date__c = Date.today() - i
            );
            appsToInsert.add(app);
        }
        insert appsToInsert;
    }

    @isTest
    static void testJoobleCallout(){
        Test.setMock(HttpCalloutMock.class, new JoobleCalloutMock());
        Test.startTest();
        JoobleCallout.getJoobleListings();
        Test.stopTest();

        List<Application__c> apps = [SELECT Id FROM Application__c];
        System.assertEquals(2, apps.size(), 'The number of Application records created does not match the expected number.');
    }
}