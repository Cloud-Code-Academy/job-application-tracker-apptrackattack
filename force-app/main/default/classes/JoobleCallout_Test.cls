@isTest
private class JoobleCallout_Test {
    @TestSetup
    static void makeData(){
        //Create Accounts
        List<Account> acctsToInsert = new List<Account>();
        for (Integer i=1; i<=3; i++){
            Account acct = new Account(
                Name = 'Test Account ' + i
            );
            acctsToInsert.add(acct);
        }

        //Create Existing Appllications
        List<Application> appsToInsert = new List<Application>();
        for (Integer)
    }
}