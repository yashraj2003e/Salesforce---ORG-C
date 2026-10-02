public with sharing class QuintLogin {
  public static final String LOGIN = 'QuintLogin.SiteLogin';

  @AuraEnabled
  public static String SiteLogin(string username, string password) {
    // String urlWithoutProtocol = YashOrgC_Utility.getURLWithoutProtocol(siteURL);
    try {
      String sitePrefix = networkName();
      PageReference pr = Site.login(username, password, sitePrefix);
      return pr != null ? pr.getUrl() : null;
    } catch (Exception e) {
      YashOrgC_Utility.publishErrorEvent(e, LOGIN);
      return null;
    }
  }

  public static String networkName() {
    ID networkId = Network.getNetworkId();
    String siteName = [SELECT name FROM network WHERE id = :networkId].name;
    return siteName + '/';
  }
}
