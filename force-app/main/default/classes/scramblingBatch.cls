public class scramblingBatch implements Database.Batchable<SObject>, Database.stateful {
  String BATCH_EXECUTE = 'scramblingBatch.execute';
  String BATCH_FINISH = 'scramblingBatch.finish';
  String NON_SETUP_OBJECTS = 'scramblingBatch.executeScramblingNonSetupObjects';
  String SETUP_OBJECTS = 'scramblingBatch.executeScramblingSetupObjects';
  String SCRAMBLE_ACCOUNT = 'scramblingBatch.ScrambleAccount';

  public Boolean isUserBatch;

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
            WHERE opt_out_yri__c = :yashOrgCConstants.REQUESTED
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
            WHERE id IN :userIds
          ]
        );
  }

  public void execute(
    Database.BatchableContext db,
    List<SObject> objectToScramble
  ) {
    try {
      if (isUserBatch) {
        executeScramblingSetupObjects((List<user>) objectToScramble);
      } else {
        executeScramblingNonSetupObjects((List<contact>) objectToScramble);
      }
    } catch (Exception e) {
      errorLog.createErrorLog(e, BATCH_EXECUTE);
    }
  }

  public void finish(Database.BatchableContext db) {
    try {
      if (!isUserBatch) {
        if (!userIds.isEmpty()) {
          Database.executeBatch(new scramblingBatch(userIds));
        }
      }
    } catch (exception e) {
      errorLog.createErrorLog(e, BATCH_FINISH);
    }
  }

  public void executeScramblingNonSetupObjects(
    List<contact> contactsToScramble
  ) {
    try {
      Set<ID> accountIds = new Set<ID>();

      for (contact con : contactsToScramble) {
        con.firstName =
          YashOrgC_Utility.appendSafe(con.firstName) +
          yashOrgCConstants.OPT_OUT;
        con.lastName =
          YashOrgC_Utility.appendSafe(con.lastName) + yashOrgCConstants.OPT_OUT;
        con.isactive__c = false;
        con.opt_out_yri__c = yashOrgCConstants.OPT_OUT;
        con.email =
          YashOrgC_Utility.appendSafe(con.email) + yashOrgCConstants.INVALID;
        if (con.accountId != null)
          accountIds.add(con.accountID);
        if (con.user__c != null)
          userIds.add(con.user__c);
      }

      if (!contactsToScramble.isEmpty()) {
        Database.SaveResult[] scrambledContacts = Database.update(
          contactsToScramble,
          false
        );

        for (Database.SaveResult sr : scrambledContacts) {
          if (!sr.isSuccess()) {
            for (Database.error er : sr.getErrors()) {
              errorLog.createErrorLog(er.getMessage(), NON_SETUP_OBJECTS);
            }
          }
        }
      }

      if (!accountIds.isEmpty()) {
        scrambleAccount(accountIds);
      }
    } catch (exception e) {
      errorLog.createErrorLog(e, NON_SETUP_OBJECTS);
    }
  }

  public void scrambleAccount(Set<Id> accountIds) {
    try {
      List<account> accountsToScramble = new List<account>();

      for (account ac : [
        SELECT id, name
        FROM account
        WHERE id IN :accountIDs
      ]) {
        ac.name =
          YashOrgC_Utility.appendSafe(ac.name) + yashOrgCConstants.OPT_OUT;
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
              errorLog.createErrorLog(er.getMessage(), SCRAMBLE_ACCOUNT);
            }
          }
        }
      }
    } catch (Exception e) {
      errorLog.createErrorLog(e, SCRAMBLE_ACCOUNT);
    }
  }

  public void executeScramblingSetupObjects(List<user> users) {
    try {
      List<user> usersToScramble = new List<user>();

      for (user u : users) {
        u.firstName =
          YashOrgC_Utility.appendSafe(u.firstName) + yashOrgCConstants.OPT_OUT;
        u.lastName =
          YashOrgC_Utility.appendSafe(u.lastName) + yashOrgCConstants.OPT_OUT;
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
              errorLog.createErrorLog(er.getMessage(), SETUP_OBJECTS);
            }
          }
        }
      }
    } catch (exception e) {
      errorLog.createErrorLog(e, SETUP_OBJECTS);
    }
  }
}
