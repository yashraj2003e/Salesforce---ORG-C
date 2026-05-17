public class errorLogTest {
    
    public static final String strErrorLogTestTestLog = 'errorLogTest.testLog()';
	
    public static void testLog() {
        try {
            contact c = new contact();
            c.FirstName = 'y';
            c.LastName = 'r';
            c.email = 't@gmail.com';
            c.award_points__c = -100;
            insert c;
        }
        catch(exception e) {
            errorLog.createErrorLog(e,strErrorLogTestTestLog);
        }
    }
    
    
}