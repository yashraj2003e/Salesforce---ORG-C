public class contactTriggerHandler {
  public static void addIntegrationId(List<contact> insertedContacts) {
    for (contact con : insertedContacts) {
      UUID integrationId = UUID.randomUUID();
      if (con.integration_id__c == null) {
        con.integration_id__c = String.valueOf(integrationId);
      }
    }
  }

  public static void handleContactInsert(List<contact> contacts) {
    System.debug(UserInfo.getUserId());
    List<account> accounts = new List<account>();
    List<contact> updatedContacts = new List<contact>();
    for (contact customercontact : contacts) {
      String accountName =
        customercontact.FirstName +
        ' ' +
        customercontact.LastName;
      account ac = new account(
        name = accountName,
        active__c = 'Yes',
        market__c = yashOrgCConstants.MARKET
      );
      accounts.add(ac);
    }

    if (!accounts.isEmpty()) {
      insert accounts;
    }

    List<ID> ids = new List<ID>();
    for (integer i = 0; i < contacts.size(); i++) {
      contact c = new contact(Id = contacts[i].Id, accountId = accounts[i].id);
      ids.add(contacts[i].id);
      updatedContacts.add(c);
    }
    System.debug(ids.size());
    for (contact c1 : [
      SELECT id, integration_id__c
      FROM contact
      WHERE id IN :ids
    ]) {
      System.debug(c1);
    }

    if (!updatedContacts.isEmpty()) {
      update updatedContacts;
    }

    System.enqueueJob(new createCustomerUser(contacts));
    syncContactUpdate(contacts);
  }

  public static void syncContactUpdate(List<contact> updatedContact) {
    List<contact> contactsToSync = new List<contact>();
    Boolean canSync = !FeatureManagement.checkPermission(
      'Data_Integration_User'
    );
    if (canSync) {
      contactsToSync.addAll(updatedContact);
    }
    if (!contactsToSync.isEmpty()) {
      System.enqueueJob(new syncContactQueueable(contactsToSync));
    }
  }
}
