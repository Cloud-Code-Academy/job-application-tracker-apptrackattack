public with sharing class ApplicationTriggerHandler {
    
    public static void afterInsert(List<Application__c> newApplications) {
        for (Application__c app : newApplications) {
            id appId = app.Id;
            String appStatus = app.Status__c;
            // Create new tasks
            createStatusTasks(appId, appStatus);
        }
    }

    public static void afterUpdate(List<Application__c> updatedApplications, Map<Id, Application__c> oldApplications) {
        List<Task> tasksToAdd = new List<Task>();
        for (Application__c app : updatedApplications) {
            id appId = app.Id;
            String appStatus = app.Status__c;
            // Create new tasks
            createStatusTasks(appId, appStatus);
        }
    }

    private static void createStatusTasks(Id appId, String appStatus) {
        List<Task> tasksToAdd = new List<Task>();
        // Create set of existing task subject lines for this application
        Set<String> existingTaskSubjects = new Set<String>();
        for (Task task : [SELECT Subject FROM Task WHERE WhatId = :appId]) {
            existingTaskSubjects.add(task.Subject);
        }
        System.debug('Existing task subjects: ' + existingTaskSubjects);

        switch on appStatus {
            when 'Saved' {
                createSavedTasks(appId, existingTaskSubjects, tasksToAdd);
            }
            when 'Applying' {
                createApplyingTasks(appId, existingTaskSubjects, tasksToAdd);
            }
            when 'Applied' {
                createAppliedTasks(appId, existingTaskSubjects, tasksToAdd);
            }
            when 'Interviewing' {
                createInterviewingTasks(appId, existingTaskSubjects, tasksToAdd);
            }
            when 'Negotiating' {
                createNegotiatingTasks(appId, existingTaskSubjects, tasksToAdd);
            }
            when 'Accepted' {
                createAcceptedTasks(appId, existingTaskSubjects, tasksToAdd);
            }
            when 'Closed' {
                createClosedTasks(appId, existingTaskSubjects, tasksToAdd);
            }
            when else {
                System.debug('No tasks created for status: ' + appStatus);
            }
        }
        try {
                insert tasksToAdd;
            } catch (Exception e) {
                System.debug('Error: ' + e.getMessage());
            }
    }

    private static List<Task> createSavedTasks(Id appId, Set<String> existingTaskSubjects, List<Task> tasksToAdd) {
        Task task1 = new Task(
            Subject      = 'Check if the job description aligns with your interests and values',
            WhatId       = appId,
            ActivityDate = Date.today().addDays(1)
        );
        if (!existingTaskSubjects.contains(task1.Subject)) {
            tasksToAdd.add(task1);
        }
        
        Task task2 = new Task(
            Subject      = 'Review the highlighted skills to see if the role is a good fit',
            WhatId       = appId,
            ActivityDate = Date.today().addDays(1)
        );
        if (!existingTaskSubjects.contains(task2.Subject)) {
            tasksToAdd.add(task2);
        }
        
        Task task3 = new Task(
            Subject      = 'Research the company & role and mark your excitement level',
            WhatId       = appId,
            ActivityDate = Date.today().addDays(2)
        );
        if (!existingTaskSubjects.contains(task3.Subject)) {
            tasksToAdd.add(task3);
        }

        return tasksToAdd;
    }

    private static List<Task> createApplyingTasks(Id appId, Set<String> existingTaskSubjects, List<Task> tasksToAdd) {
        Task task1 = new Task(
            Subject      = 'Find and research someone who works at the company and add them as a contact',
            WhatId       = appId,
            ActivityDate = Date.today().addDays(1)
        );
        if (!existingTaskSubjects.contains(task1.Subject)) {
            tasksToAdd.add(task1);
        }

        Task task2 = new Task(
            Subject      = 'Set up an informational interview to learn more about the role/company',
            WhatId       = appId,
            ActivityDate = Date.today().addDays(2)
        );
        if (!existingTaskSubjects.contains(task2.Subject)) {
            tasksToAdd.add(task2);
        }

        Task task3 = new Task(
            Subject      = 'Identify potential referrals to help get your application on the top of the pile',
            WhatId       = appId,
            ActivityDate = Date.today().addDays(2)
        );
        if (!existingTaskSubjects.contains(task3.Subject)) {
            tasksToAdd.add(task3);
        }

        Task task4 = new Task(
            Subject      = 'Customize your work achievements using the job description keywords',
            WhatId       = appId,
            ActivityDate = Date.today().addDays(1)
        );
        if (!existingTaskSubjects.contains(task4.Subject)) {
            tasksToAdd.add(task4);
        }

        Task task5 = new Task(
            Subject      = 'Submit your application on the company website if possible',
            WhatId       = appId,
            ActivityDate = Date.today().addDays(2)
        );
        if (!existingTaskSubjects.contains(task5.Subject)) {
            tasksToAdd.add(task5);
        }

        return tasksToAdd;
    }

    private static List<Task> createAppliedTasks(Id appId, Set<String> existingTaskSubjects, List<Task> tasksToAdd) {
        Task task1 = new Task(
            Subject      = 'Reach out to the hiring manager or recruiter',
            WhatId       = appId,
            ActivityDate = Date.today().addDays(2)
        );
        if (!existingTaskSubjects.contains(task1.Subject)) {
            tasksToAdd.add(task1);
        }
        
        Task task2 = new Task(
            Subject      = 'Follow up on your application via email weekly',
            WhatId       = appId,
            ActivityDate = Date.today().addDays(2)
        );
        if (!existingTaskSubjects.contains(task2.Subject)) {
            tasksToAdd.add(task2);
        }
        
        Task task3 = new Task(
            Subject      = 'Continue identifying and saving similar job opportunities',
            WhatId       = appId,
            ActivityDate = Date.today().addDays(2)
        );
        if (!existingTaskSubjects.contains(task3.Subject)) {
            tasksToAdd.add(task3);
        }
        
        Task task4 = new Task(
            Subject      = 'Set up weekly networking calls to explore similar companies/roles',
            WhatId       = appId,
            ActivityDate = Date.today().addDays(1)
        );
        if (!existingTaskSubjects.contains(task4.Subject)) {
            tasksToAdd.add(task4);
        }

        return tasksToAdd;
    }

    private static List<Task> createInterviewingTasks(Id appId, Set<String> existingTaskSubjects, List<Task> tasksToAdd) {
        Task task1 = new Task(
            Subject      = 'Prepare your blurb or “tell me about yourself” response',
            WhatId       = appId,
            ActivityDate = Date.today().addDays(2)
        );
        if (!existingTaskSubjects.contains(task1.Subject)) {
            tasksToAdd.add(task1);
        }
        
        Task task2 = new Task(
            Subject      = 'Practice answering behavioral interview questions',
            WhatId       = appId,
            ActivityDate = Date.today().addDays(2)
        );
        if (!existingTaskSubjects.contains(task2.Subject)) {
            tasksToAdd.add(task2);
        }
        
        Task task3 = new Task(
            Subject      = 'Research the company and your interviewers',
            WhatId       = appId,
            ActivityDate = Date.today().addDays(2)
        );
        if (!existingTaskSubjects.contains(task3.Subject)) {
            tasksToAdd.add(task3);
        }
        
        Task task4 = new Task(
            Subject      = 'Set up your virtual interview space and test your tech',
            WhatId       = appId,
            ActivityDate = Date.today().addDays(2)
        );
        if (!existingTaskSubjects.contains(task4.Subject)) {
            tasksToAdd.add(task4);
        }

        Task task5 = new Task(
            Subject      = 'Send thank you emails within 24 hours',
            WhatId       = appId,
            ActivityDate = Date.today().addDays(3)
        );
        if (!existingTaskSubjects.contains(task5.Subject)) {
            tasksToAdd.add(task5);
        }

        return tasksToAdd;
    }

    private static List<Task> createNegotiatingTasks(Id appId, Set<String> existingTaskSubjects, List<Task> tasksToAdd) {
        Task task1 = new Task(
            Subject      = 'Research your market value and know your numbers',
            WhatId       = appId,
            ActivityDate = Date.today().addDays(2)
        );
        if (!existingTaskSubjects.contains(task1.Subject)) {
            tasksToAdd.add(task1);
        }
        
        Task task2 = new Task(
            Subject      = 'Prepare your negotiation scripts',
            WhatId       = appId,
            ActivityDate = Date.today().addDays(2)
        );
        if (!existingTaskSubjects.contains(task2.Subject)) {
            tasksToAdd.add(task2);
        }
        
        Task task3 = new Task(
            Subject      = 'Evaluate your offer and decline or accept',
            WhatId       = appId,
            ActivityDate = Date.today().addDays(2)
        );
        if (!existingTaskSubjects.contains(task3.Subject)) {
            tasksToAdd.add(task3);
        }

        return tasksToAdd;
    }

    private static List<Task> createAcceptedTasks(Id appId, Set<String> existingTaskSubjects, List<Task> tasksToAdd) {
        Task task1 = new Task(
            Subject      = 'Plan your resignation if applicable',
            WhatId       = appId,
            ActivityDate = Date.today().addDays(2)
        );
        if (!existingTaskSubjects.contains(task1.Subject)) {
            tasksToAdd.add(task1);
        }
        
        Task task2 = new Task(
            Subject      = 'Take some time to relax and recharge',
            WhatId       = appId,
            ActivityDate = Date.today().addDays(2)
        );
        if (!existingTaskSubjects.contains(task2.Subject)) {
            tasksToAdd.add(task2);
        }
        
        Task task3 = new Task(
            Subject      = 'Prepare for your first day of onboarding',
            WhatId       = appId,
            ActivityDate = Date.today().addDays(2)
        );
        if (!existingTaskSubjects.contains(task3.Subject)) {
            tasksToAdd.add(task3);
        }

        return tasksToAdd;
    }

    private static List<Task> createClosedTasks(Id appId, Set<String> existingTaskSubjects, List<Task> tasksToAdd) {
        Task task1 = new Task(
            Subject      = 'Send a follow-up email thanking the interviewer and asking for feedback',
            WhatId       = appId,
            ActivityDate = Date.today().addDays(2)
        );
        if (!existingTaskSubjects.contains(task1.Subject)) {
            tasksToAdd.add(task1);
        }
        
        Task task2 = new Task(
            Subject      = 'Review your notes and reflect on areas of improvement',
            WhatId       = appId,
            ActivityDate = Date.today().addDays(2)
        );
        if (!existingTaskSubjects.contains(task2.Subject)) {
            tasksToAdd.add(task2);
        }
        return tasksToAdd;
    }
}