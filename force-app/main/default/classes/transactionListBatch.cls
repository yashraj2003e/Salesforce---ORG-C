public class transactionListBatch implements Database.Batchable<SObject> {
  public Database.queryLocator start(Database.BatchableContext bc) {
    return Database.getQueryLocator(
      [
        SELECT id, award_points__c, contact__c
        FROM transaction_list__c
        WHERE expiry_date__c = yesterday
      ]
    );
  }

  public void execute(
    Database.BatchableContext bc,
    List<transaction_list__c> transactionList
  ) {
    for (transaction_list__c transactions : transactionList) {
      transactions.award_points__c = 0;
    }

    if (!transactionList.isEmpty()) {
      update transactionList;
    }
  }

  public void finish(Database.BatchableContext bc) {
    System.debug('Mission Complete');
  }
}
