/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an org are executed whenever Apex code is deployed
 * to a production org to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production org. In addition, all triggers must have some code coverage.
 *
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the org size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class UserDeactivationBatchTest extends TriggerHandler {
  public UserDeactivationBatchTest() {
    super('UserDeactivationBatchTest');
  }

  @isTest
  static void deactivationTest() {
    TriggerHandler.byPass('ContactTriggerHandler');

    Contact c = new Contact(
      FirstName = 'bat13c123h',
      LastName = 'te11323st',
      isactive__c = true,
      email = 'batcht13testt123t@gmail.com',
      ownerId = '005dL00001lobvFQAQ'
    );

    // missing: [Username, LastName, Email, Alias, TimeZoneSidKey, LocaleSidKey, EmailEncodingKey, ProfileId, LanguageLocaleKey

    insert c;

    account ac = new account(
      name = 'testacc',
      market__c = 'a01dL00002Ciy1RQAR',
      ownerId = '005dL00001lobvFQAQ'
    );

    insert ac;

    c.accountId = ac.Id;
    update c;

    System.debug(userInfo.getUserId());

    User u = new User(
      firstName = 'ba13tc123h',
      lastName = 'te11323st',
      email = 'batc12133hh@gmail.com',
      username = 'c11323hh@gmail.com',
      alias = 'bcc',
      isactive = true,
      timezonesidkey = 'Asia/Kolkata',
      LocaleSidKey = 'en_US',
      EmailEncodingKey = 'UTF-8',
      ProfileId = '00edL00000QWY1fQAH',
      LanguageLocaleKey = 'en_US',
      contactId = c.id
    );

    insert u;

    System.Test.setCreatedDate(u.id, System.now().addDays(-6));

    System.Test.startTest();
    Database.executeBatch(new UserDeactivationBatch());
    System.Test.stopTest();

    User updatedUser = [
      SELECT id, isactive, createddate
      FROM user
      WHERE id = :u.id
    ];
    Contact updatedContact = [
      SELECT id, isactive__c
      FROM contact
      WHERE id = :c.id
    ];
    System.assertEquals(false, updatedUser.isactive);
    System.assertEquals(false, updatedContact.isactive__c);

    TriggerHandler.clearAllByPass();
  }
}
