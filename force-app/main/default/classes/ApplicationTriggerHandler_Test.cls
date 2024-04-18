@isTest
private class ApplicationTriggerHandler_Test {
    
    @isTest private static void testBeforeInsert() {
        Test.setMock(HttpCalloutMock.class, new JoobleCalloutMock());
        Test.startTest();
        JoobleCallout.getJoobleListings('Salesforce Developer', 'Remote', '2024-03-01');
        Test.stopTest();

        List<Task> tasksCreated = [SELECT Id FROM Task];
        // 2 Applications meet the criteria: title (Salesforce Developer), location (remote), and date (>= 2024-03-01)
        // 2 Applications inserted should create 6 tasks
        Assert.areEqual(6, tasksCreated.size());
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

    @isTest static void testStatusApplied() {
        // Prepare test data
        Account acc = new Account(Name = 'Test Account');
        insert acc;

        Application__c app = new Application__c();
        app.Position_Title__c = 'Salesforce Developer';
        app.Company__c = acc.Id;
        app.Status__c = 'SAVED';
        insert app;

        // Update the status to 'APPLIED'
        Test.startTest();
        app.Status__c = 'APPLIED';
        update app;
        Test.stopTest();

        // Query for the tasks
        List<Task> tasks = [SELECT Id, Subject FROM Task WHERE WhatId = :app.Id];

        // Assert that 7 tasks (3 AFTER_INSERT + 4) were created
        Assert.areEqual(7, tasks.size(), 'Seven tasks should have been created.');

        // Assert that the tasks have the correct subjects
        Set<String> expectedSubjects = new Set<String>{
            'Reach out to the hiring manager or recruiter',
            'Follow up on your application via email weekly',
            'Continue identifying and saving similar job opportunities',
            'Set up weekly networking calls to explore similar companies/roles',
            // AFTER_INSERT task subject lines
            'Check if the job description aligns with your interests and values',
            'Review the highlighted skills to see if the role is a good fit',
            'Research the company & role and mark your excitement level'
        };
        Set<String> actualSubjects = new Set<String>();
        for (Task task : tasks) {
            actualSubjects.add(task.Subject);
        }
        Assert.areEqual(expectedSubjects, actualSubjects, 'The tasks do not have the correct subjects.');
    }

    @isTest static void testStatusInterviewing() {
        // Prepare test data
        Account acc = new Account(Name = 'Test Account');
        insert acc;

        Application__c app = new Application__c();
        app.Position_Title__c = 'Salesforce Developer';
        app.Company__c = acc.Id;
        app.Status__c = 'SAVED';
        insert app;

        // Update the status to 'INTERVIEWING'
        Test.startTest();
        app.Status__c = 'INTERVIEWING';
        update app;
        Test.stopTest();

        // Query for the tasks
        List<Task> tasks = [SELECT Id, Subject FROM Task WHERE WhatId = :app.Id];

        // Assert that 8 tasks (3 AFTER_INSERT + 5) were created
        Assert.areEqual(8, tasks.size(), 'Seven tasks should have been created.');

        // Assert that the tasks have the correct subjects
        Set<String> expectedSubjects = new Set<String>{
            'Prepare your blurb or “tell me about yourself” response',
            'Practice answering behavioral interview questions',
            'Research the company and your interviewers',
            'Set up your virtual interview space and test your tech',
            'Send thank you emails within 24 hours',
            // AFTER_INSERT task subject lines
            'Check if the job description aligns with your interests and values',
            'Review the highlighted skills to see if the role is a good fit',
            'Research the company & role and mark your excitement level'
        };
        Set<String> actualSubjects = new Set<String>();
        for (Task task : tasks) {
            actualSubjects.add(task.Subject);
        }
        Assert.areEqual(expectedSubjects, actualSubjects, 'The tasks do not have the correct subjects.');
    }

    @isTest private static void testStatusNegotiating() {
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

        // Update the Application to 'NEGOTIATING'
        insertedApp.Status__c = 'NEGOTIATING';
        update insertedApp;

        List<Task> tasksCreated = [SELECT Id FROM Task];
        // Application inserted & updated should create 6 tasks (3 from the insert, 3 from the update)
        Assert.areEqual(6, tasksCreated.size());
    }
    @isTest private static void testStatusAccepted() {
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

        // Update the Application to 'ACCEPTED'
        insertedApp.Status__c = 'ACCEPTED';
        update insertedApp;

        List<Task> tasksCreated = [SELECT Id FROM Task];
        // Application inserted & updated should create 6 tasks (3 from the insert, 3 from the update)
        Assert.areEqual(6, tasksCreated.size());
    }

    @isTest private static void testStatusClosed() {
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

        // Update the Application to 'CLOSED'
        insertedApp.Status__c = 'CLOSED';
        update insertedApp;

        List<Task> tasksCreated = [SELECT Id FROM Task];
        // Application inserted & updated should create 5 tasks (3 from the insert, 2 from the update)
        Assert.areEqual(5, tasksCreated.size());
    }

    @isTest private static void testPreventDuplicateTasks() {
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

        // Udpate the status to 'APPLYING'
        Application__c insertedApp = [SELECT Id, Status__c FROM Application__c WHERE Id = :app.Id];
        insertedApp.Status__c = 'APPLYING';
        update insertedApp;

        // Update the status back to 'SAVED'
        insertedApp = [SELECT Id, Status__c FROM Application__c WHERE Id = :app.Id];
        Test.startTest();
        insertedApp.Status__c = 'SAVED';
        update insertedApp;
        Test.stopTest();

        // Assert that 8 tasks (3 when 'SAVED' + 5 when 'APPLYING') were created
        // This tests whether duplicate tasks (with the same subject line) were created
        List<Task> tasks = [SELECT Id, Subject FROM Task WHERE WhatId = :app.Id];
        Assert.areEqual(8, tasks.size(), 'Eight tasks should have been created.');
    }
}