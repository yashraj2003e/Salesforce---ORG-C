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

  public static String getSiteURL(string name) {
    return '/' + name + '/';
  }
}
