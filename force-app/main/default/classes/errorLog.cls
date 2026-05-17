public class errorLog {
    
    /*public errorLog() {
        errorLogTest.testLog();
    }*/

    public static void createErrorLog(Exception e,String methodName) {
        /*System.debug(e);
        System.debug(e.getCause());
        System.debug(e.getLineNumber());
        System.debug(e.getMessage());
        System.debug(e.getStackTraceString());
        System.debug(e.getTypeName());
		*/
		String errorData = e.getTypeName() + ': ' + e.getMessage() + ' in method - ' + methodName + '\n' + e.getStackTraceString();
        error_log__c er = new error_log__c();
        er.Description__c = errorData;
        er.Method__c = methodName;
        insert er;
    }
    
    public static void createErrorLog(string e,String methodName) {
        String errorData = e;
        error_log__c er = new error_log__c();
        er.Description__c = errorData;
        er.Method__c = methodName;
        insert er;
    }
    
    
}