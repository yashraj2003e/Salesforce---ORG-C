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
private class UserDeactivationBatchTest {
  @isTest
  static void deactivationTest() {
    Contact c = new Contact(
      FirstName = 'batch',
      LastName = 'test',
      isactive__c = true,
      email = 'batchttesttt@gmail.com'
    );

    insert c;

    List<User> u = [SELECT id, isactive FROM user WHERE contactId = :c.id];

    User curUser;

    if (!u.isEmpty()) {
      curUser = u[0];
    }

    System.Test.startTest();
    Database.executeBatch(new UserDeactivationBatch());
    System.Test.stopTest();

    System.assertEquals(false, curUser.isactive);
    System.assertEquals(false, c.isactive__c);
  }
}
