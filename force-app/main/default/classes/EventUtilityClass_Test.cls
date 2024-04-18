@isTest
public with sharing class EventUtilityClass_Test {

    @TestSetup static void createTestData(){
        // Get Id of System Admin User (to use as record owner)
        String SystemAdminProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1].Id;
        User testUser = [SELECT Id, FirstName, Email FROM User WHERE IsActive = true AND ProfileId = :SystemAdminProfileId LIMIT 1];

        // Create a test account
        Account testAccount = new Account(
            Name = 'Test Account',
            OwnerId = testUser.Id
        );
        insert testAccount;

        // Create a test application
        Application__c testApplication = new Application__c(
            Company__c = testAccount.Id,
            Position_Title__c = 'Salesforce Developer',
            Location__c = 'remote',
            OwnerId = testUser.Id
        );
        insert testApplication;
    }
    
    @isTest static void sendTestEmailPostive() {
        // Get Id of System Admin User (to use as Event owner)
        String SystemAdminProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1].Id;
        User testUser = [SELECT Id, FirstName, Email FROM User WHERE IsActive = true AND ProfileId = :SystemAdminProfileId LIMIT 1];

        // Get Id of test application
        Application__c testApplication = [SELECT Id FROM Application__c LIMIT 1];
        
        // Create a test event for tomorrow
        Event testEvent = new Event(
            Subject = 'Test Interview',
            StartDateTime = DateTime.newInstance(Date.today().year(), Date.today().month(), Date.today().day()+1, 14, 00, 00),
            EndDateTime = DateTime.newInstance(Date.today().year(), Date.today().month(), Date.today().day()+1, 15, 00, 00),
            WhatId = testApplication.Id,
            Location = 'test location',
            OwnerId = testUser.Id
        );
        insert testEvent;

        Test.startTest();
        EventUtilityClass.sendReminderEmail();

        // Assert that 1 email sent -- Must be INSIDE Test.startTest() and Test.stopTest()
        System.assertEquals(1, Limits.getEmailInvocations());
        Test.stopTest();
    }

    @isTest static void sendTestEmailNegative() {
        // Get Id of System Admin User (to use as Event owner)
        String SystemAdminProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1].Id;
        User testUser = [SELECT Id, FirstName, Email FROM User WHERE IsActive = true AND ProfileId = :SystemAdminProfileId LIMIT 1];

        // Get Id of test application
        Application__c testApplication = [SELECT Id FROM Application__c LIMIT 1];
        
        // Create a test event for today
        Event testEvent = new Event(
            Subject = 'Test Interview',
            StartDateTime = DateTime.newInstance(Date.today().year(), Date.today().month(), Date.today().day(), 14, 00, 00),
            EndDateTime = DateTime.newInstance(Date.today().year(), Date.today().month(), Date.today().day(), 15, 00, 00),
            WhatId = testApplication.Id,
            Location = 'test location',
            OwnerId = testUser.Id
        );
        insert testEvent;

        Test.startTest();
        EventUtilityClass.sendReminderEmail();

        // Assert that no email sent -- Must be INSIDE Test.startTest() and Test.stopTest()
        System.assertEquals(0, Limits.getEmailInvocations());
        Test.stopTest();
    }
}