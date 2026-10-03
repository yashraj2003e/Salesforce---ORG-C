public class YashOrgC_Utility {
  public static String appendSafe(String value) {
    if (value == null) {
      return '';
    }
    return value;
  }

  public static String addSpaceText(string value1, string value2) {
    return value1 + ' ' + value2;
  }

  public static Integer getRandomNumber() {
    Integer min = 0;
    Integer max = yashOrgCConstants.marketIds.size() - 1;
    return min + Math.mod(Math.abs(Crypto.getRandomInteger()), (max - min + 1));
  }

  public static String urlCleanup(String url) {
    Integer protocolEnd = url.indexOf('://');
    Integer pathStart = url.indexOf('/', protocolEnd + 3);

    String mainUrl = pathStart == -1 ? url : url.substring(0, pathStart);

    return mainUrl;
  }

  public static void publishErrorEvent(String errorMsg, String methodName) {
    Error_Event__e err = new Error_Event__e();
    err.method__c = errorMsg;
    err.description__c = methodName;

    EventBus.publish(err);
  }

  public static void publishErrorEvent(
    Exception exception_err,
    String methodName
  ) {
    Error_Event__e err = new Error_Event__e();
    String errorMsg =
      (String) exception_err.getTypeName() +
      ': ' +
      exception_err.getMessage() +
      ' in method - ' +
      methodName +
      '\n' +
      exception_err.getStackTraceString();
    err.description__c = errorMsg;
    err.method__c = methodName;
    System.debug(err);
    EventBus.publish(err);
  }
}
