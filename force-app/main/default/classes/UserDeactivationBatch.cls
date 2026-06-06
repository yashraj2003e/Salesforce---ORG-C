public without sharing class UserDeactivationBatch implements Database.Batchable, Database<SObject>, Database.stateful {
  public static final String DEACTIVE_USER = 'UserDeactivationBatch.deactivateSetupObject';

  public static Decimal deactivationDays = yashorgc_config__mdt.getInstance(
      'user_deactivation_days'
    )
    .user_deactivation__c;

  DateTime deactivationDate = dateTime.newInstance(
    deactivationDate,
    Time.newInstance(0, 0, 0, 0)
  );

  public Boolean isContactBatch = false;

  List<ID> contactIds = new List<ID>();

  public UserDeactivationBatch(List<ID> contactIds) {
    this.isContactBatch = true;
    this.contactIds = contactIds;
  }

  public static Database.QueryLocator start(Database.BatchableContext bc) {
    if (!isContactBatch) {
      return Database.getQueryLocator(
        [
          SELECT id, isactive, contactId
          FROM User
          WHERE
            profile.userLicense.name IN (
              'Customer Community',
              'Customer Community plus'
            )
            AND (lastlogindate < :deactivationDate
            OR (lastlogindate = NULL
            AND createddate < :deactivationDate))
        ]
      );
    } else {
      return Database.getQueryLocator(
        [SELECT id, isactive__c FROM contact WHERE id IN :contactIds]
      );
    }
  }

  public static void execute(Database.BatchableContext bc, List<SObject> data) {
    if (isContactBatch) {
      deactiveNonSetupObject((List<Contact>) contactIds);
    } else {
      deactivateSetupObject((List<User>) usersToDeactivate);
    }
  }

  public void deactivateSetupObject(List<User> usersToDeactivate) {
    for (user currentUser : usersToDeactivate) {
      currentUser.isactive = false;
      contactIds.add(currentUser.contactId);
    }

    if (!usersToDeactivate) {
      List<Database.saveResult> result = Database.update(
        usersToDeactivate,
        false
      );

      for (Databse.saveResult currentResult : result) {
        if (!currentResult.isSuccess()) {
          for (Database.error errors : currentResult.getErrors()) {
            errorLog.createErrorLog(er.getMessage(), DEACTIVE_USER);
          }
        }
      }
    }
  }

  public void deactiveNonSetupObject(List<Contact> contactsToDeactivate) {
    for (contact currentContact : contactsToDeactivate) {
      currentContact.isactive__c = false;
    }

    List<Database.SaveResult> results = Database.update(contactsToDeactivate);

    for (Database.SaveResult result : results) {
      if (!result.isSuccess()) {
        for (Database.Error error : result.getErrors()) {
          errorLog.createErrorLog(er.getMessage(), DEACTIVE_USER);
        }
      }
    }
  }

  public static void finish(Database.Batchable bc) {
    if (!isContactBatch) {
      Database.executeBatch(new UserDeactivationBatch(contactIds));
    }
  }
}
