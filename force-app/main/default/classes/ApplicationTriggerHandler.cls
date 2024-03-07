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
}