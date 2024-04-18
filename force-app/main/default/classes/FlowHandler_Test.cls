@isTest
public with sharing class FlowHandler_Test {

    @TestSetup static void createTestData(){
        // Create a test account
        Account testAccount = new Account(
            Name = 'Test Account'
        );
        insert testAccount;

        // Create a test application
        Application__c testApplication = new Application__c(
            Company__c = testAccount.Id,
            Position_Title__c = 'Salesforce Developer',
            Location__c = 'remote'
        );
        insert testApplication;

        // Create a test event for tomorrow
        Event testEvent = new Event(
            Subject = 'Test Interview',
            StartDateTime = DateTime.newInstance(Date.today().year(), Date.today().month(), Date.today().day()+1, 14, 00, 00),
            EndDateTime = DateTime.newInstance(Date.today().year(), Date.today().month(), Date.today().day()+1, 15, 00, 00),
            WhatId = testApplication.Id,
            Location = 'test location'
        );
        insert testEvent;
    }

    @isTest static void checkForEventOverlapPostiveEnd() {
        // Create a new test event that overlaps with the existing event
        Event testEvent = new Event(
            Subject = 'Test Interview',
            StartDateTime = DateTime.newInstance(Date.today().year(), Date.today().month(), Date.today().day()+1, 14, 30, 00),
            EndDateTime = DateTime.newInstance(Date.today().year(), Date.today().month(), Date.today().day()+1, 15, 30, 00)
        );

        Test.startTest();
        List<Boolean> overlapFound = FlowHandler.checkForInterviewOverlap(new List<List<DateTime>>{new List<DateTime>{testEvent.StartDateTime, testEvent.EndDateTime}});
        Test.stopTest();

        // Assert that overlap is found
        System.assertEquals(true, overlapFound[0]);
    }

    @isTest static void checkForEventOverlapPostiveBeginning() {
        // Create a new test event that overlaps with the existing event
        Event testEvent = new Event(
            Subject = 'Test Interview',
            StartDateTime = DateTime.newInstance(Date.today().year(), Date.today().month(), Date.today().day()+1, 13, 30, 00),
            EndDateTime = DateTime.newInstance(Date.today().year(), Date.today().month(), Date.today().day()+1, 14, 30, 00)
        );

        Test.startTest();
        List<Boolean> overlapFound = FlowHandler.checkForInterviewOverlap(new List<List<DateTime>>{new List<DateTime>{testEvent.StartDateTime, testEvent.EndDateTime}});
        Test.stopTest();

        // Assert that overlap is found
        System.assertEquals(true, overlapFound[0]);
    }

    @isTest static void checkForEventOverlapPositiveBeginningEnd() {
        // Create a new test event that overlaps with the existing event
        Event testEvent = new Event(
            Subject = 'Test Interview',
            StartDateTime = DateTime.newInstance(Date.today().year(), Date.today().month(), Date.today().day()+1, 13, 00, 00),
            EndDateTime = DateTime.newInstance(Date.today().year(), Date.today().month(), Date.today().day()+1, 16, 00, 00)
        );

        Test.startTest();
        List<Boolean> overlapFound = FlowHandler.checkForInterviewOverlap(new List<List<DateTime>>{new List<DateTime>{testEvent.StartDateTime, testEvent.EndDateTime}});
        Test.stopTest();

        // Assert that overlap is found
        System.assertEquals(true, overlapFound[0]);
    }

    @isTest static void checkForEventOverlapNegative() {
        // Create a new test event that does not overlap with the existing event
        Event testEvent = new Event(
            Subject = 'Test Interview',
            StartDateTime = DateTime.newInstance(Date.today().year(), Date.today().month(), Date.today().day()+1, 15, 30, 00),
            EndDateTime = DateTime.newInstance(Date.today().year(), Date.today().month(), Date.today().day()+1, 16, 30, 00)
        );

        Test.startTest();
        List<Boolean> overlapFound = FlowHandler.checkForInterviewOverlap(new List<List<DateTime>>{new List<DateTime>{testEvent.StartDateTime, testEvent.EndDateTime}});
        Test.stopTest();

        // Assert that no overlap is found
        System.assertEquals(false, overlapFound[0]);
    }
}