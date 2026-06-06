public without sharing class UserDeactivationBatch implements Database.Batchable<SObject>, Database.stateful {
  public static final String DEACTIVE_USER = 'UserDeactivationBatch.deactivateSetupObject';
  public static final String DEACTIVATE_USER = 'UserDeactivationBatch.deactivateSetupObject';
  public static final String DEACTIVATE_CONTACT = 'UserDeactivationBatch.deactivateNonSetupObject';

  public static Decimal deactivationDays = yashorgc_config__mdt.getInstance(
      'user_deactivation_days'
    )
    .user_deactivation__c;
  //   DateTime deactivationDate = dateTime.newInstance(
  //     deactivationDays,
  //     Time.newInstance(0, 0, 0, 0)
  //   );
  DateTime deactivationDate = System.now()
    .addDays(-Integer.valueOf(deactivationDays));
  public Boolean isContactBatch;
  List<ID> contactIds = new List<ID>();

  public UserDeactivationBatch() {
    isContactBatch = false;
  }

  public UserDeactivationBatch(List<ID> contactIds) {
    this.isContactBatch = true;
    this.contactIds = contactIds;
  }

  public Database.QueryLocator start(Database.BatchableContext bc) {
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

  public void execute(Database.BatchableContext bc, List<SObject> data) {
    if (isContactBatch) {
      deactiveNonSetupObject((List<Id>) contactIds);
    } else {
      deactivateSetupObject((List<User>) data);
    }
  }

  public void deactivateSetupObject(List<User> usersToDeactivate) {
    for (user currentUser : usersToDeactivate) {
      currentUser.isactive = false;
      contactIds.add(currentUser.contactId);
    }

    if (!usersToDeactivate.isEmpty()) {
      List<Database.saveResult> result = Database.update(
        usersToDeactivate,
        false
      );

      for (Database.saveResult currentResult : result) {
        if (!currentResult.isSuccess()) {
          for (Database.error errors : currentResult.getErrors()) {
            errorLog.createErrorLog(errors.getMessage(), DEACTIVATE_USER);
          }
        }
      }
    }
  }

  public void deactiveNonSetupObject(List<Id> contactIds) {
    List<contact> contactsToDeactivate = [
      SELECT id, isactive__c
      FROM contact
      WHERE id IN :contactIds
    ];

    for (contact currentContact : contactsToDeactivate) {
      currentContact.isactive__c = false;
    }

    List<Database.SaveResult> results = Database.update(contactsToDeactivate);

    for (Database.SaveResult result : results) {
      if (!result.isSuccess()) {
        for (Database.Error error : result.getErrors()) {
          errorLog.createErrorLog(error.getMessage(), DEACTIVATE_CONTACT);
        }
      }
    }
  }

  public void finish(Database.BatchableContext bc) {
    if (!isContactBatch) {
      Database.executeBatch(new UserDeactivationBatch(contactIds));
    }
  }
}
