public with sharing class ExternalContentTriggerHandler extends TriggerHandler {
  List<External_Content__c> oldList;
  List<External_Content__c> newList;
  Map<Id, External_Content__c> oldMap;
  Map<Id, External_Content__c> newMap;

  public ExternalContentTriggerHandler() {
    super('ExternalContentTriggerHandler');
    this.oldList = (List<External_Content__c>) Trigger.old;
    this.newList = (List<External_Content__c>) Trigger.new;
    this.oldMap = (Map<Id, External_Content__c>) Trigger.oldMap;
    this.oldMap = (Map<Id, External_Content__c>) Trigger.newMap;
  }
}
