public class errorLogTest {
  public static final String strErrorLogTestTestLog = 'errorLogTest.testLog()';

  public static void testLog() {
    try {
      contact c = new contact();
      c.FirstName = 'y';
      c.LastName = 'r';
      c.email = 't@gmail.com';
      insert c;
    } catch (exception e) {
      System.enqueueJob(new errorLog(e, strErrorLogTestTestLog));
    }
  }
}
