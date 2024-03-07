@isTest
private class ApplicationTriggerHandler_Test {
    
    @isTest private static void testBeforeInsert() {
        Test.setMock(HttpCalloutMock.class, new JoobleCalloutMock());
        Test.startTest();
        JoobleCallout.getJoobleListings();
        Test.stopTest();

        List<Task> tasksCreated = [SELECT Id FROM Task];
        // 3 Applications inserted should create 9 tasks
        Assert.areEqual(9, tasksCreated.size());
    }

    @isTest private static void testStatusApplying() {
        // Insert an Account to link to the Application
        Account acc = new Account();
        acc.Name = 'Test Account';
        insert acc;

        // Insert an Application
        Application__c app = new Application__c();
        app.Position_Title__c = 'Salesforce Developer';
        app.Company__c = acc.Id;
        app.Status__c = 'SAVED';
        insert app;

        Application__c insertedApp = [SELECT Id, Status__c FROM Application__c WHERE Id = :app.Id];

        // Update the Application to 'APPLYING'
        insertedApp.Status__c = 'APPLYING';
        update insertedApp;

        List<Task> tasksCreated = [SELECT Id FROM Task];
        // Application inserted & updated should create 8 tasks (3 from the insert, 5 from the update)
        Assert.areEqual(8, tasksCreated.size());
    }
}