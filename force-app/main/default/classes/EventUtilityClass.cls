public with sharing class EventUtilityClass {
    
    // Send reminder email about upcoming interview
    public static void sendReminderEmail(){
        List<Event> interviews = [SELECT Id, OwnerId, WhatId, Subject, StartDateTime, Location FROM Event WHERE StartDateTime = TOMORROW];

        Set<Id> appIDs = new Set<Id>();
        Set<Id> userIds = new Set<Id>();
        for (Event interview : interviews) {
        appIDs.add(interview.WhatId);
        userIds.add(interview.OwnerId);
        }
        // Application Map to locate the associated application object and its fields
        Map<Id,Application__c> appMap = new Map<Id,Application__c>([SELECT Id, Name, Company__c, OwnerId FROM Application__c WHERE Id IN :appIDs]);

        // User Map to locate the associated user object and its fields
        Map<Id,User> userMap = new Map<Id,User>([SELECT Id, FirstName, Email FROM User WHERE Id IN :userIds]);

        // Get the accounts to display the company name in email
        Set<Id> accIDs = new Set<Id>();
        Map<Id,Id> appIdAcctIdMap = new Map<Id,Id>(); 
        for (Application__c app : appMap.values()) {
        accIDs.add(app.Company__c);
        appIdAcctIdMap.put(app.Id, app.Company__c);
        }
        // Account Map to locate the associated account object and its fields
        Map<Id,Account> acctMap = new Map<Id,Account>([SELECT Id, Name FROM Account WHERE Id IN :accIDs]);

        List<Messaging.SingleEmailMessage> reminderEmails = new List<Messaging.SingleEmailMessage>();
        
        for (Event interview : interviews) {
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();

            String intervieweeName = userMap.get(interview.ownerId).FirstName;
            String eventSubject = interview.Subject;
            String eventTime = interview.StartDateTime.format();
            String eventLocation = interview.Location;
            String dayOfWeek = interview.StartDateTime.format('EEEE');
            String appName = appMap.get(interview.WhatId).Name;
            String companyName =  acctMap.get(appIdAcctIdMap.get(interview.WhatId)).Name;

            email.setSaveAsActivity(false); // because sending to User not Contact
            email.setToAddresses(new List<String>{userMap.get(interview.OwnerId).Email});
            email.setSubject('Interview Reminder — ' + companyName);
            email.setPlainTextBody('Hey ' + intervieweeName + ',\n\n' + 'Don\'t forget you have an interview with ' + companyName + ' on ' + dayOfWeek + '. This is associated with application ' + appName + '. Make sure you\'re ready! \n\n' + 'Details: ' + eventSubject + '\n' + 'Date & Time: ' + eventTime + '\n' + 'Location: ' + eventLocation +'\n\n' + 'Good luck!' + '\n');
            email.setTargetObjectId(interview.OwnerId);

            reminderEmails.add(email);
        }

        if (reminderEmails.size() > 0) {
            Messaging.sendEmail(reminderEmails);
        }
    }
}