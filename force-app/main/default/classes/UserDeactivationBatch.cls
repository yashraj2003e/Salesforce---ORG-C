/*
Batch intended to deactivate atmost 5,000 users and contacts to use heap efficiently.
*/

public with sharing class UserDeactivationBatch implements Database.Batchable<SObject>, Database.stateful, Schedulable {
  private static final String DEACTIVATE_USER = 'UserDeactivationBatch.deactivateSetupObject';
  private static final String DEACTIVATE_CONTACT = 'UserDeactivationBatch.deactivateNonSetupObject';

  private YashOrgc_Config__mdt deactivationConfig = YashOrgc_Config__mdt.getInstance(
    'user_deactivation'
  );

  private Decimal deactivationDays = deactivationConfig.user_deactivation__c;

  private Set<ID> profileToDeactivate = new Set<ID>{
    deactivationConfig.Customer_Community_Plus_Profile__c,
    deactivationConfig.Customer_Community_Profile__c
  };

  private DateTime deactivationDate = System.now()
    .addDays(-Integer.valueOf(deactivationDays));

  private Boolean isContactBatch;
  private Set<ID> contactIds = new Set<ID>();

  public UserDeactivationBatch() {
    isContactBatch = false;
  }

  public UserDeactivationBatch(Set<ID> contactIds) {
    this.isContactBatch = true;
    this.contactIds = contactIds;
  }

  public void execute(SchedulableContext sc) {
    Database.executeBatch(new UserDeactivationBatch());
  }

  public Database.QueryLocator start(Database.BatchableContext bc) {
    if (!isContactBatch) {
      // deactivate users who never logged in and were created before org's defined days or users who never logged in after defined days in org
      return Database.getQueryLocator(
        [
          SELECT id, isactive, contactId
          FROM User
          WHERE
            profileId IN :profileToDeactivate
            AND isactive = TRUE
            AND (lastlogindate < :deactivationDate
            OR (lastlogindate = NULL
            AND createddate < :deactivationDate))
          ORDER BY createddate
          LIMIT 5000
        ]
      );
    } else {
      return Database.getQueryLocator(
        [SELECT id, isactive__c FROM contact WHERE id IN :contactIds]
      );
    }
  }

  public void execute(
    Database.BatchableContext bc,
    List<SObject> objectToDeactivate
  ) {
    if (isContactBatch) {
      deactivateNonSetupObject((List<Contact>) objectToDeactivate);
    } else {
      deactivateSetupObject((List<User>) objectToDeactivate);
    }
  }

  public void deactivateSetupObject(List<User> usersToDeactivate) {
    for (User currentUser : usersToDeactivate) {
      currentUser.isactive = false;
      if (currentUser.contactId != null) {
        contactIds.add(currentUser.contactId);
      } else {
        System.enqueueJob(
          new errorLog(
            'Missing Contact for User - ' + String.valueOf(currentUser.Id),
            DEACTIVATE_USER
          )
        );
      }
    }

    if (!usersToDeactivate.isEmpty()) {
      List<Database.saveResult> result = Database.update(
        usersToDeactivate,
        false
      );

      for (Database.saveResult currentResult : result) {
        if (!currentResult.isSuccess()) {
          for (Database.error errors : currentResult.getErrors()) {
            System.enqueueJob(
              new errorLog(errors.getMessage(), DEACTIVATE_USER)
            );
          }
        }
      }
    }
  }

  public void deactivateNonSetupObject(List<Contact> contactsToDeactivate) {
    for (Contact currentContact : contactsToDeactivate) {
      currentContact.isactive__c = false;
    }

    List<Database.SaveResult> results = Database.update(
      contactsToDeactivate,
      false
    );

    for (Database.SaveResult result : results) {
      if (!result.isSuccess()) {
        for (Database.Error error : result.getErrors()) {
          System.enqueueJob(
            new errorLog(error.getMessage(), DEACTIVATE_CONTACT)
          );
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
