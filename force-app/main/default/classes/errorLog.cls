public without sharing class errorLog {
  /*

  * Migrated to - ErrorEventTriggerHandler

  */

  // public Exception exception_err;
  // public String err;
  // public String methodName;

  // public errorLog(Exception error, String methodName) {
  //   this.exception_err = error;
  //   this.methodName = methodName;
  // }

  // public errorLog(String error, String methodName) {
  //   this.err = error;
  //   this.methodName = methodName;
  // }

  // public void execute(QueueableContext qc) {
  //   /*System.debug(e);
  //       System.debug(e.getCause());
  //       System.debug(e.getLineNumber());
  //       System.debug(e.getMessage());
  //       System.debug(e.getStackTraceString());
  //       System.debug(e.getTypeName());
  // 	*/
  //   String errorData = '';
  //   if (exception_err != null) {
  //     errorData =
  //       exception_err.getTypeName() +
  //       ': ' +
  //       exception_err.getMessage() +
  //       ' in method - ' +
  //       methodName +
  //       '\n' +
  //       exception_err.getStackTraceString();
  //   } else {
  //     errorData = err;
  //   }

  //   error_log__c er = new error_log__c();
  //   er.Description__c = errorData;
  //   er.Method__c = methodName;
  //   insert er;

  //   if (exception_err != null) {
  //     throw exception_err;
  //   }
  // }

  // public static void createErrorLog(string e,String methodName) {
  //     String errorData = e;
  //     error_log__c er = new error_log__c();
  //     er.Description__c = errorData;
  //     er.Method__c = methodName;
  //     insert er;
  // }
}
