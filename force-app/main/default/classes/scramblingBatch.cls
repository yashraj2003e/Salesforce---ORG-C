public class scramblingBatch implements Database.Batchable<SObject>, Database.stateful {
  String BATCH_EXECUTE = 'scramblingBatch.execute';
  String BATCH_FINISH = 'scramblingBatch.finish';
  String NON_SETUP_OBJECTS = 'scramblingBatch.executeScramblingNonSetupObjects';
  String SETUP_OBJECTS = 'scramblingBatch.executeScramblingSetupObjects';
  String SCRAMBLE_ACCOUNT = 'scramblingBatch.ScrambleAccount';

  public Boolean isUserBatch;
  public Integer processedCount = 0;

  public Set<ID> userIds = new Set<ID>();

  public scramblingBatch() {
    this.isUserBatch = false;
  }

  public scramblingBatch(Set<ID> userIds) {
    this.isUserBatch = true;
    this.userIds = userIds;
  }

  public Database.queryLocator start(Database.BatchableContext db) {
    return !isUserBatch
      ? Database.getQueryLocator(
          [
            SELECT
              id,
              firstName,
              lastName,
              isactive__c,
              opt_out_yri__c,
              email,
              accountId,
              user__c
            FROM contact
            WHERE
              opt_out_yri__c = :yashOrgCConstants.REQUESTED
              AND (NOT name LIKE 'opt%')
          ]
        )
      : Database.getQueryLocator(
          [
            SELECT
              id,
              firstname,
              lastname,
              username,
              federationIdentifier,
              isactive
            FROM user
            WHERE id IN :userIds AND (NOT name LIKE 'opt%')
          ]
        );
  }

  public void execute(
    Database.BatchableContext db,
    List<SObject> objectToScramble
  ) {
    if (objectToScramble.isEmpty())
      return;
    processedCount += objectToScramble.size();
    try {
      if (isUserBatch) {
        executeScramblingSetupObjects((List<user>) objectToScramble);
      } else {
        executeScramblingNonSetupObjects((List<contact>) objectToScramble);
      }
    } catch (Exception e) {
      YashOrgC_Utility.publishErrorEvent(e, BATCH_EXECUTE);
    }
  }

  public void finish(Database.BatchableContext db) {
    try {
      if (System.test.isRunningTest()) {
        log__c log = new log__c(data__c = String.valueOf(processedCount));
        insert log;
      }
      if (!isUserBatch) {
        if (!userIds.isEmpty()) {
          Database.executeBatch(new scramblingBatch(userIds));
        }
      }
    } catch (exception e) {
      YashOrgC_Utility.publishErrorEvent(e, BATCH_FINISH);
    }
  }

  public void executeScramblingNonSetupObjects(
    List<contact> contactsToScramble
  ) {
    try {
      Set<ID> accountIds = new Set<ID>();

      for (contact con : contactsToScramble) {
        con.firstName =
          yashOrgCConstants.OPT_OUT +
          YashOrgC_Utility.appendSafe(con.firstName);
        con.lastName =
          yashOrgCConstants.OPT_OUT + YashOrgC_Utility.appendSafe(con.lastName);
        con.isactive__c = false;
        con.opt_out_yri__c = yashOrgCConstants.OPT_OUT;
        con.email =
          YashOrgC_Utility.appendSafe(con.email) + yashOrgCConstants.INVALID;
        if (con.accountId != null)
          accountIds.add(con.accountID);
        if (con.user__c != null)
          userIds.add(con.user__c);

        if (
          System.test.isRunningTest() &&
          con.firstName == (yashOrgCConstants.OPT_OUT + 'bad')
        ) {
          con.opt_out_yri__c = 'forced failure';
        }
      }

      if (!contactsToScramble.isEmpty()) {
        Database.SaveResult[] scrambledContacts = Database.update(
          contactsToScramble,
          false
        );

        for (Database.SaveResult sr : scrambledContacts) {
          if (!sr.isSuccess()) {
            for (Database.error er : sr.getErrors()) {
              System.enqueueJob(
                new errorLog(er.getMessage(), NON_SETUP_OBJECTS)
              );
            }
          }
        }
      }

      if (!accountIds.isEmpty()) {
        scrambleAccount(accountIds);
      }
    } catch (exception e) {
      YashOrgC_Utility.publishErrorEvent(e, NON_SETUP_OBJECTS);
    }
  }

  public void scrambleAccount(Set<Id> accountIds) {
    try {
      List<account> accountsToScramble = new List<account>();

      for (account ac : [
        SELECT id, name
        FROM account
        WHERE (NOT name LIKE 'opt%') AND id IN :accountIDs
      ]) {
        ac.name =
          yashOrgCConstants.OPT_OUT + YashOrgC_Utility.appendSafe(ac.name);
        accountsToScramble.add(ac);
      }

      if (!accountsToScramble.isEmpty()) {
        List<Database.SaveResult> scrambledAccounts = Database.update(
          accountsToScramble,
          false
        );

        for (Database.saveResult sr : scrambledAccounts) {
          if (!sr.isSuccess()) {
            for (Database.error er : sr.getErrors()) {
              System.enqueueJob(
                new errorLog(er.getMessage(), SCRAMBLE_ACCOUNT)
              );
            }
          }
        }
      }
    } catch (Exception e) {
      YashOrgC_Utility.publishErrorEvent(e, SCRAMBLE_ACCOUNT);
    }
  }

  public void executeScramblingSetupObjects(List<user> users) {
    try {
      List<user> usersToScramble = new List<user>();

      for (user u : users) {
        u.firstName =
          yashOrgCConstants.OPT_OUT + YashOrgC_Utility.appendSafe(u.firstName);
        u.lastName =
          yashOrgCConstants.OPT_OUT + YashOrgC_Utility.appendSafe(u.lastName);
        u.userName = u.userName + yashOrgCConstants.INVALID;
        u.federationIdentifier =
          YashOrgC_Utility.appendSafe(u.federationIdentifier) +
          yashOrgCConstants.INVALID;
        u.isactive = false;
        usersToScramble.add(u);
      }

      if (!usersToScramble.isEmpty()) {
        List<Database.saveResult> scrambledUsers = Database.update(
          usersToScramble
        );
        for (Database.saveResult sr : scrambledUsers) {
          if (!sr.isSuccess()) {
            for (Database.error er : sr.getErrors()) {
              YashOrgC_Utility.publishErrorEvent(
                er.getMessage(),
                SETUP_OBJECTS
              );
            }
          }
        }
      }
    } catch (exception e) {
      YashOrgC_Utility.publishErrorEvent(e, SETUP_OBJECTS);
    }
  }
}
