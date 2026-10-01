public with sharing class ContactUserSync implements Queueable {
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

    update usersToUpdate;
  }
}
