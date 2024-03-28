@isTest
private class JoobleCallout_Test {
    @TestSetup
    static void createTestData(){
        //Create Accounts
        List<Account> acctsToInsert = new List<Account>();
        for (Integer i=1; i<=3; i++){
            Account acct = new Account(
                Name = 'Test Account ' + i
            );
            acctsToInsert.add(acct);
        }
        insert acctsToInsert;

        //Create Existing Applications
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
        JoobleCallout.getJoobleListings('Salesforce Developer', 'Remote', '2024-03-01');
        Test.stopTest();

        List<Application__c> apps = [SELECT Id, Company__c, Position_Title__c, Location__c, Listing_ID__c, Listing_Date__c FROM Application__c];
        System.assertEquals(5, apps.size(), 'The number of Applications (3 old + 2 new) do not match the expected number.');
        for (Application__c app : apps){
            System.debug('app: ' + app);
            System.assertNotEquals(null, app.Listing_ID__c, 'The Listing ID is null.');
            System.assertNotEquals(null, app.Listing_Date__c, 'The Listing Date is null.');
        }
        // Assert that there are not more than 1 Application with the Id of 1
        Integer count = [SELECT COUNT() FROM Application__c WHERE Listing_ID__c = '1'];
        System.assertEquals(1, count, 'There are more than 1 Application with the Listing ID of 1.');

        // Assert that the Company with the name 'Test Account 3' has 2 Applications
        count = [SELECT COUNT() FROM Application__c WHERE Company__r.Name = 'Test Account 3'];
        System.assertEquals(2, count, 'The Company with the name "Test Account 3" should have 2 Applications.');
    }
}