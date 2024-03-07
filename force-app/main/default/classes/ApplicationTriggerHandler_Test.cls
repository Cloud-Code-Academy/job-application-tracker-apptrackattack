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
}