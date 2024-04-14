public with sharing class ApplicationTriggerHandler {
    
    public static void afterInsert(List<Application__c> newApplications) {
        List<Task> tasksToAdd = new List<Task>();
        for (Application__c app : newApplications) {
            if (app.Status__c == 'Saved') {
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
        try {
            insert tasksToAdd;
        } catch (Exception e) {
            System.debug('Error: ' + e.getMessage());
        }
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
            } else if (app.Status__c == 'APPLIED' && oldApp.Status__c != 'APPLIED') {
                Task task1 = new Task(
                    Subject      = 'Reach out to the hiring manager or recruiter',
                    WhatId       = app.Id,
                    ActivityDate = Date.today().addDays(2)
                );
                tasksToAdd.add(task1);
            
                Task task2 = new Task(
                    Subject      = 'Follow up on your application via email weekly',
                    WhatId       = app.Id,
                    ActivityDate = Date.today().addDays(2)
                );
                tasksToAdd.add(task2);
            
                Task task3 = new Task(
                    Subject      = 'Continue identifying and saving similar job opportunities',
                    WhatId       = app.Id,
                    ActivityDate = Date.today().addDays(2)
                );
                tasksToAdd.add(task3);
            
                Task task4 = new Task(
                    Subject      = 'Set up weekly networking calls to explore similar companies/roles',
                    WhatId       = app.Id,
                    ActivityDate = Date.today().addDays(1)
                );
                tasksToAdd.add(task4);
            } else if (app.Status__c == 'INTERVIEWING' && oldApp.Status__c != 'INTERVIEWING') {
                Task task1 = new Task(
                    Subject      = 'Prepare your blurb or “tell me about yourself” response',
                    WhatId       = app.Id,
                    ActivityDate = Date.today().addDays(2)
                );
                tasksToAdd.add(task1);
            
                Task task2 = new Task(
                    Subject      = 'Practice answering behavioral interview questions',
                    WhatId       = app.Id,
                    ActivityDate = Date.today().addDays(2)
                );
                tasksToAdd.add(task2);
            
                Task task3 = new Task(
                    Subject      = 'Research the company and your interviewers',
                    WhatId       = app.Id,
                    ActivityDate = Date.today().addDays(2)
                );
                tasksToAdd.add(task3);
            
                Task task4 = new Task(
                    Subject      = 'Set up your virtual interview space and test your tech',
                    WhatId       = app.Id,
                    ActivityDate = Date.today().addDays(2)
                );
                tasksToAdd.add(task4);

                Task task5 = new Task(
                    Subject      = 'Send thank you emails within 24 hours',
                    WhatId       = app.Id,
                    ActivityDate = Date.today().addDays(3)
                );
                tasksToAdd.add(task5);

            } else if (app.Status__c == 'NEGOTIATING' && oldApp.Status__c != 'NEGOTIATING') {
                Task task1 = new Task(
                    Subject      = 'Research your market value and know your numbers',
                    WhatId       = app.Id,
                    ActivityDate = Date.today().addDays(2)
                );
                tasksToAdd.add(task1);
            
                Task task2 = new Task(
                    Subject      = 'Prepare your negotiation scripts',
                    WhatId       = app.Id,
                    ActivityDate = Date.today().addDays(2)
                );
                tasksToAdd.add(task2);
            
                Task task3 = new Task(
                    Subject      = 'Evaluate your offer and decline or accept',
                    WhatId       = app.Id,
                    ActivityDate = Date.today().addDays(2)
                );
                tasksToAdd.add(task3);
        
            } else if (app.Status__c == 'ACCEPTED' && oldApp.Status__c != 'ACCEPTED') {
                Task task1 = new Task(
                    Subject      = 'Plan your resignation if applicable',
                    WhatId       = app.Id,
                    ActivityDate = Date.today().addDays(2)
                );
                tasksToAdd.add(task1);
            
                Task task2 = new Task(
                    Subject      = 'Take some time to relax and recharge',
                    WhatId       = app.Id,
                    ActivityDate = Date.today().addDays(2)
                );
                tasksToAdd.add(task2);
            
                Task task3 = new Task(
                    Subject      = 'Prepare for your first day of onboarding',
                    WhatId       = app.Id,
                    ActivityDate = Date.today().addDays(2)
                );
                tasksToAdd.add(task3);

            } else if (app.Status__c == 'CLOSED' && oldApp.Status__c != 'CLOSED') {
                Task task1 = new Task(
                    Subject      = 'Send a follow-up email thanking the interviewer and asking for feedback',
                    WhatId       = app.Id,
                    ActivityDate = Date.today().addDays(2)
                );
                tasksToAdd.add(task1);
            
                Task task2 = new Task(
                    Subject      = 'Review your notes and reflect on areas of improvement',
                    WhatId       = app.Id,
                    ActivityDate = Date.today().addDays(2)
                );
                tasksToAdd.add(task2);
            }
            try {
                insert tasksToAdd;
            } catch (Exception e) {
                System.debug('Error: ' + e.getMessage());
            }
        }
    }
}