@isTest
private class AccountTriggerHandlerTest {
  @isTest
  static void accountWithActiveContactTest() {
    System.Test.startTest();
    contact c = new contact(
      lastname = 'test',
      email = 'acTesttest@gmail.com',
      isactive__c = true
    );

    insert c;
    contact updatedContact = [
      SELECT id, accountid
      FROM contact
      WHERE id = :c.id
    ];

    System.debug(updatedContact);

    account ac = [
      SELECT id, active__c
      FROM account
      WHERE id = :updatedContact.accountid
    ];
    ac.active__c = 'Yes';
    update ac;

    ac.active__c = 'No';
    System.debug(ac);
    Database.saveResult sr = Database.update(ac, false);

    System.Test.stopTest();

    System.assertEquals(false, sr.isSuccess());

    System.assert(
      sr.getErrors()[0]
        .getMessage()
        .contains('Account has atleast one active contact')
    );
  }
}
