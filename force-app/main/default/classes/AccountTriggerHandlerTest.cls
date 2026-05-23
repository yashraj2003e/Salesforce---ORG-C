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
private class AccountTriggerHandlerTest {
  @isTest
  static void accountWithActiveContactTest() {
    // TO DO: implement unit test

    account ac = new account(
      name = 'test ac',
      market__c = yashorgCConstants.MARKET,
      active__c = 'Yes'
    );
    insert ac;

    contact c = new contact(
      lastname = 'test',
      email = 'acTesttest@gmail.com',
      accountid = ac.id
    );

    insert c;

    System.Test.startTest();

    ac.active__c = 'No';

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
