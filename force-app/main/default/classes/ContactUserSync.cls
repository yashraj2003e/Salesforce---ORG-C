public with sharing class ContactUserSync implements Queueable {
  final String QUEUEABLE_EXECUTE = 'ContactUserSync.execute';

  Map<ID, String> contacts = new Map<ID, String>();

  public ContactUserSync(Map<ID, String> contactsToSync) {
    this.contacts = contactsToSync;
  }

  public void execute(QueueableContext context) {
    List<User> usersToUpdate = new List<User>(
      [
        SELECT Id, ContactId, email, username
        FROM User
        WHERE ContactId IN :contacts.keySet()
      ]
    );

    for (user curUser : usersToUpdate) {
      curUser.email = contacts.get(curUser.ContactId);
      curUser.username = contacts.get(curUser.ContactId);
    }

    List<Database.saveResult> updateResult = Database.update(
      usersToUpdate,
      false
    );

    for (Database.SaveResult sr : updateResult) {
      if (!sr.isSuccess()) {
        for (Database.Error err : sr.getErrors()) {
          YashOrgC_Utility.publishErrorEvent(
            err.getMessage(),
            QUEUEABLE_EXECUTE
          );
        }
      }
    }
  }
}
