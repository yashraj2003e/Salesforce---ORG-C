public with sharing class LogTriggerHandler extends TriggerHandler {
  public LogTriggerHandler() {
    super('LogTriggerHandler');
  }
  public override void beforeInsert() {
    System.debug('working !!');
  }

  public override void afterInsert() {
    account ac = [
      SELECT id, active__c
      FROM account
      WHERE id = '001dL00002CYjZ3'
      LIMIT 1
    ];

    TriggerHandler.byPass('AccountTriggerHandler');
    ac.active__c = 'No';
    update ac;
    TriggerHandler.clearByPass('AccountTriggerHandler');
  }
}
