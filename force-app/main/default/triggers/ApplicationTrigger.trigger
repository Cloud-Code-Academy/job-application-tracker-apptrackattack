trigger ApplicationTrigger on Application__c (after insert, after update) {

  switch on Trigger.operationType {
    when AFTER_INSERT {
      ApplicationTriggerHandler.afterInsert(Trigger.new);
    }
    when AFTER_UPDATE {
      ApplicationTriggerHandler.afterUpdate(Trigger.new, Trigger.oldMap);
    }
  }
}