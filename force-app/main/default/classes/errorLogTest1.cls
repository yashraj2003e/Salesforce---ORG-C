@isTest
public class errorLogTest1 {
  @isTest
  static void testCreateErrorLogWithException() {
    try {
      contact c = new contact();
      c.FirstName = 'Test';
      c.LastName = 'User';
      c.email = 'test@example.com';
      insert c;

      // Force an exception
      contact invalidContact = new contact();
      insert invalidContact; // Missing required fields
    } catch (exception e) {
      errorLog.createErrorLog(
        e,
        'errorLogTest.testCreateErrorLogWithException'
      );
    }

    // Assert error log was created
    List<error_log__c> logs = [SELECT id, Description__c FROM error_log__c];
    System.assert(!logs.isEmpty(), 'Error log should have been created');
  }

  @isTest
  static void testCreateErrorLogWithMessage() {
    errorLog.createErrorLog(
      'Test error message',
      'errorLogTest.testCreateErrorLogWithMessage'
    );

    List<error_log__c> logs = [SELECT id, Description__c FROM error_log__c];
    System.assert(!logs.isEmpty(), 'Error log should have been created');
    System.assert(
      logs[0].Description__c.contains('Test error message'),
      'Error message should be logged'
    );
  }

  @isTest
  static void testCreateErrorLogWithNullInput() {
    // Edge case: what happens with null?
    try {
      errorLog.createErrorLog(
        null,
        'errorLogTest.testCreateErrorLogWithNullInput'
      );
    } catch (exception e) {
      // Should handle gracefully
    }
  }
}
