public with sharing class ErrorEventTriggerHandler extends TriggerHandler {
  List<Error_Event__e> newList;

  public ErrorEventTriggerHandler() {
    super('ErrorEventTriggerHandler');
    this.newList = (List<Error_Event__e>) Trigger.new;
  }

  public override void afterInsert() {
    List<error_log__c> er = new List<error_log__c>();

    for (error_event__e e : this.newList) {
      error_log__c error_log = new error_log__c();
      error_log.description__c = e.description__c;
      error_log.method__c = e.method__c;
      er.add(error_log);
    }

    insert er;
  }
}
