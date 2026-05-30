public without sharing class LogTriggerHandler extends TriggerHandler {
  public LogTriggerHandler() {
    super('LogTriggerHandler');
  }
  public override void beforeInsert() {
    System.debug('working !!');
  }

  public override void afterInsert() {
    List<Account> ac = [
      SELECT id, active__c
      FROM account
      WHERE id = '001dL00002CYjZ3'
    ];

    TriggerHandler.byPass('AccountTriggerHandler');
    for (account acc : ac) {
      acc.active__c = 'No';
    }
    update ac;
    TriggerHandler.clearByPass('AccountTriggerHandler');
  }
}
