@isTest
private class ScramblingBatchTest {
  @isTest
  static void contactTest() {
    contact c = new contact(
      firstname = 'batch',
      lastname = 'test',
      email = 'batchtest@gmail.com',
      opt_out_YRI__c = yashOrgCConstants.requested
    );
    insert c;

    System.test.startTest();
    scramblingBatch sB = new scramblingBatch();
    Database.executeBatch(sB);
    System.test.stopTest();

    contact scrambledContact = [
      SELECT id, firstname, lastname, opt_out_YRI__c
      FROM contact
      WHERE id = :c.id
      LIMIT 1
    ];

    log__c processedCount = [
      SELECT id, data__c
      FROM log__c
      ORDER BY createddate DESC
      LIMIT 1
    ];

    System.debug(sb.processedCount);
    // System.assert(sb.processedCount == 2);
    System.assertEquals(
      yashOrgCConstants.OPT_OUT,
      scrambledContact.opt_out_YRI__c
    );
    System.assertEquals(1, Integer.valueOf(processedCount.data__c));
  }

  @isTest
  static void userTest() {
    contact c = new contact(
      firstname = 'batch',
      lastname = 'test',
      email = 'batchtest@gmail.com',
      opt_out_YRI__c = yashOrgCConstants.requested
    );
    insert c;

    System.Test.startTest();
    scramblingBatch sB = new scramblingBatch();
    Database.executeBatch(sb);
    System.Test.stopTest();

    contact scrambledContact = [
      SELECT id, firstname, lastname, opt_out_YRI__c, isactive__c
      FROM contact
      WHERE id = :c.id
      LIMIT 1
    ];

    user scrambledUser = [
      SELECT id, name, isactive
      FROM user
      WHERE contactid = :c.id
      LIMIT 1
    ];

    System.assert(scrambledContact.opt_out_YRI__c == yashOrgCConstants.OPT_OUT);
    System.assert(scrambledContact.isactive__c == false);
    System.assert(scrambledUser.isactive == false);
    String userName = scrambledUser.name.substring(
      scrambledUser.name.length() - 7
    );
    System.assertEquals(yashOrgCConstants.OPT_OUT, userName);
  }

  @isTest
  static void multipleContacts() {
    contact c = new contact(
      firstname = 'batch',
      lastname = 'test',
      email = 'batchtest@gmail.com',
      opt_out_YRI__c = yashOrgCConstants.requested
    );
    insert c;

    contact c1 = new contact(
      firstname = 'batch1',
      lastname = 'test2',
      email = 'batchtest2@gmail.com',
      opt_out_YRI__c = yashOrgCConstants.requested
    );
    insert c1;

    System.Test.startTest();
    scramblingBatch sB = new scramblingBatch();
    Database.executeBatch(sB);
    System.Test.stopTest();

    log__c processedCount = [
      SELECT data__c
      FROM log__c
      ORDER BY createddate DESC
      LIMIT 1
    ];
    System.assertEquals(2, Integer.valueOf(processedCount.data__c));
  }

  @isTest
  static void bulkContactTest() {
    Contact c = new Contact(
      FirstName = 'batch',
      LastName = 'test',
      Email = 'batchtest@gmail.com',
      opt_out_YRI__c = yashOrgCConstants.requested
    );

    Contact c1 = new Contact(
      FirstName = 'bad',
      LastName = 'test2',
      Email = 'batchtest2@gmail.com',
      opt_out_YRI__c = yashOrgCConstants.requested
    );

    insert new List<Contact>{ c, c1 };

    System.Test.startTest();

    Database.executeBatch(new scramblingBatch());

    System.Test.stopTest();

    Contact successContact = [
      SELECT opt_out_yri__c
      FROM Contact
      WHERE Id = :c.Id
    ];

    Contact failedContact = [
      SELECT opt_out_yri__c
      FROM Contact
      WHERE Id = :c1.Id
    ];

    error_log__c log = [
      SELECT id, method__c, Description__c
      FROM Error_Log__c
      ORDER BY createddate DESC
      LIMIT 1
    ];

    System.assertEquals(
      yashOrgCConstants.OPT_OUT,
      successContact.opt_out_yri__c
    );

    System.assertNotEquals(
      yashOrgCConstants.OPT_OUT,
      failedContact.opt_out_yri__c
    );
    System.debug(log);
    System.assertEquals(
      'scramblingBatch.executeScramblingNonSetupObjects',
      log.method__c
    );
  }
}
