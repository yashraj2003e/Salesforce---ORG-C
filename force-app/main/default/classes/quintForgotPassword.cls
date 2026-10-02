public without sharing class quintForgotPassword {
  public static final String FORGOT_PASSWORD = 'QuintForgotPassword.resetPassword';

  public static final String ISVALID_USERNAME = 'QuintForgotPassword.isValidUsername';

  @AuraEnabled
  public static Boolean resetPassword(String username) {
    try {
      Id networkId = Network.getNetworkId();

      if (!isValidUsername(username, networkId)) {
        return false;
      }

      Site.forgotPassword(username);

      return true;
    } catch (Exception e) {
      YashOrgC_Utility.publishErrorEvent(e, FORGOT_PASSWORD);
      return false;
    }
  }

  public static Boolean isValidUsername(String username, Id networkId) {
    try {
      List<User> users = [
        SELECT Id, IsActive
        FROM User
        WHERE Username = :username
        LIMIT 1
      ];

      if (users.isEmpty()) {
        return false;
      }

      User requestingUser = users[0];

      if (!requestingUser.IsActive) {
        return false;
      }

      List<NetworkMember> memberships = [
        SELECT Id
        FROM NetworkMember
        WHERE MemberId = :requestingUser.Id AND NetworkId = :networkId
        LIMIT 1
      ];

      return !memberships.isEmpty();
    } catch (Exception e) {
      YashOrgC_Utility.publishErrorEvent(e, ISVALID_USERNAME);
      return false;
    }
  }
}
