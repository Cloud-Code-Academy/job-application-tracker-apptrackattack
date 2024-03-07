public with sharing class ApplicationTriggerHandler {
    
    public static void afterInsert(List<Application__c> newApplications) {
        List<Task> tasksToAdd = new List<Task>();
        for (Application__c app : newApplications) {
            if (app.Status__c == 'Saved'){
                Task task1 = new Task(
                Subject      = 'Check if the job description aligns with your interests and values',
                WhatId       = app.Id,
                ActivityDate = Date.today().addDays(1)
            );
            tasksToAdd.add(task1);

            Task task2 = new Task(
                Subject      = 'Review the highlighted skills to see if the role is a good fit',
                WhatId       = app.Id,
                ActivityDate = Date.today().addDays(1)
            );
            tasksToAdd.add(task2);

            Task task3 = new Task(
                Subject      = 'Research the company & role and mark your excitement level',
                WhatId       = app.Id,
                ActivityDate = Date.today().addDays(2)
            );
            tasksToAdd.add(task3);
            } 
        }
        insert tasksToAdd;
    }

    public static void afterUpdate(List<Application__c> updatedApplications, Map<Id, Application__c> oldApplications) {
        List<Task> tasksToAdd = new List<Task>();
        for (Application__c app : updatedApplications) {
            Application__c oldApp = oldApplications.get(app.Id);
            if (app.Status__c == 'APPLYING' && oldApp.Status__c != 'APPLYING') {
                Task task1 = new Task(
                    Subject      = 'Find and research someone who works at the company and add them as a contact',
                    WhatId       = app.Id,
                    ActivityDate = Date.today().addDays(1)
                );
                tasksToAdd.add(task1);

                Task task2 = new Task(
                    Subject      = 'Set up an informational interview to learn more about the role/company',
                    WhatId       = app.Id,
                    ActivityDate = Date.today().addDays(2)
                );
                tasksToAdd.add(task2);

                Task task3 = new Task(
                    Subject      = 'Identify potential referrals to help get your application on the top of the pile',
                    WhatId       = app.Id,
                    ActivityDate = Date.today().addDays(2)
                );
                tasksToAdd.add(task3);

                Task task4 = new Task(
                    Subject      = 'Customize your work achievements using the job description keywords',
                    WhatId       = app.Id,
                    ActivityDate = Date.today().addDays(1)
                );
                tasksToAdd.add(task4);

                Task task5 = new Task(
                    Subject      = 'Submit your application on the company website if possible',
                    WhatId       = app.Id,
                    ActivityDate = Date.today().addDays(2)
                );
                tasksToAdd.add(task5);
            }
        }
        insert tasksToAdd;
    }
}