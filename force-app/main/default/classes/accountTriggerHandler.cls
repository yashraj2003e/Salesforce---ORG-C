public without sharing class accountTriggerHandler extends TriggerHandler {
  Map<Id, Account> oldMap;
  Map<Id, Account> newMap;
  List<Account> oldList;
  List<Account> newList;

  public accountTriggerHandler() {
    super('AccountTriggerHandler');
    this.oldMap = (Map<Id, Account>) Trigger.oldMap;
    this.newMap = (Map<Id, Account>) Trigger.newMap;
    this.oldList = (List<Account>) Trigger.old;
    this.newList = (List<Account>) Trigger.new;
  }

  public override void beforeUpdate() {
    validateContactActiveStatus();
  }

  public void validateContactActiveStatus() {
    List<ID> accounts = new List<ID>();
    for (Id accountId : this.newMap.keyset()) {
      if (
        this.newMap.get(accountId).active__c == 'No' &&
        this.oldMap.get(accountId).active__c == 'Yes'
      ) {
        accounts.add(accountId);
      }
    }

    List<aggregateResult> ar = [
      SELECT accountId
      FROM contact
      WHERE isactive__c = TRUE AND accountId IN :accounts
      GROUP BY accountId
    ];

    for (AggregateResult a : ar) {
      Id accId = (Id) a.get('AccountId');
      Account ac = this.newMap.get(accId);
      if (ac != null) {
        ac.active__c.addError('Account has atleast one active contact!');
      }
    }
  }
}
