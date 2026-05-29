public class createCustomerUser implements Queueable {
  public static final String createCustomerUserExecute = 'createCustomerUser.execute()';

  List<Contact> contacts;

  public createCustomerUser(List<Contact> contacts) {
    this.contacts = contacts;
  }

  public void execute(QueueableContext qc) {
    List<User> customerUsers = new List<User>();
    Map<Id, Contact> contactMap = new Map<Id, Contact>();

    try {
      for (Contact c : contacts) {
        contactMap.put(c.Id, c);

        User newUser = new User();

        String alias = '';

        String base =
          (c.FirstName != null ? c.FirstName.substring(0, 1) : 'X') +
          (c.LastName != null ? c.LastName : '');

        if (base.length() > 8) {
          base = base.substring(0, 8);
        }

        alias = base;
        newUser.alias = alias;
        newUser.CommunityNickname = c.email + 'YRI.net';
        newUser.ContactId = c.Id;
        newUser.Email = c.email;
        newUser.EmailEncodingKey = 'UTF-8';
        newUser.TimeZoneSidKey = 'Asia/Kolkata';
        newUser.FederationIdentifier = c.email;
        newUser.FirstName = c.firstName;
        newUser.LastName = c.lastName;
        newUser.LocaleSidKey = 'en_US';
        newUser.Username = c.email;
        newUser.LanguageLocaleKey = 'en_US';
        newUser.ProfileId = yashOrgCConstants.COMMUNITY_PROFILE;

        customerUsers.add(newUser);
      }

      insert customerUsers;

      List<Contact> updateUsersOnContact = new List<Contact>();

      for (User u : customerUsers) {
        Contact c = new Contact(Id = (id) contactMap.get(u.ContactId).id);
        c.User__c = u.Id;
        updateUsersOnContact.add(c);
      }

      update updateUsersOnContact;
    } catch (exception e) {
      errorlog.createErrorLog(e, createCustomerUserExecute);
      throw e;
    }
  }
}
