public with sharing class EventUtilityClass {
    
    // Send reminder email about upcoming interview
    public static void sendReminderEmail(){
        List<Event> eventList = [SELECT Id, OwnerId, WhatId, Owner.FirstName, Owner.Email, Subject, StartDateTime FROM Event WHERE StartDateTime = TOMORROW];

        List<Id> appIDs = new List<Id>();
        for (Event evnt : eventList) {
        appIDs.add(evnt.WhatId);
        }
        // Get applications to display app name and retrieve the AccountId (Company__c)
        List<Application__c> appList = [SELECT Id, Name, Company__c FROM Application__c WHERE Id IN :appIDs];
        // Get the accounts to display the company name in email
        List<Id> accIDs = new List<Id>();   
        for (Application__c app : appList) {
        accIDs.add(app.Company__c);
        }
        // Account Map to locate the associated account object and its fields
        Map<Id,Account> acctMap = new Map<Id,Account>([SELECT Id, Name FROM Account WHERE Id IN :accIDs]);

        String intervieweeName = eventList[0].Owner.FirstName;
        String eventSubject = eventList[0].Subject;
        String eventTime = eventList[0].StartDateTime.format();
        String dayOfWeek = eventList[0].StartDateTime.format('EEEE');
        String appName = appList[0].Name;
        String companyName =  acctMap.get(appList[0].Company__c).Name;

        if (!eventList.isEmpty()){
            List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
            for(Event event : eventList){
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setSaveAsActivity(false); // because sending to User not Contact
            email.setToAddresses(new List<String>{event.Owner.Email});
            email.setSubject('Interview Reminder — ' + companyName);
            email.setPlainTextBody('Hey ' + intervieweeName + ',\n\n' + 'Don\'t forget you have an interview with ' + companyName + ' on ' + dayOfWeek + '. This is associated with application ' + appName + '. Make sure you\'re ready! \n\n' + 'Details: ' + eventSubject + '\n' + 'Date/Time: ' + eventTime + '\n\n' + 'Good luck!');
            email.setTargetObjectId(event.OwnerId);
            emails.add(email);
            }
            Messaging.sendEmail(emails);
        }
    }
}