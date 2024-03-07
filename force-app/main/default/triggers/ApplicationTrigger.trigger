trigger ApplicationTrigger on Application__c (after insert) {

  switch on Trigger.operationType {
    when AFTER_INSERT {
      ApplicationTriggerHandler.afterInsert(Trigger.new);
    }
  }

}