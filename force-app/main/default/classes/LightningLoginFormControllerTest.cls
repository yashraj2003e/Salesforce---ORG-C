@IsTest(SeeAllData=true)
public with sharing class LightningLoginFormControllerTest {
  @IsTest
  static void testLoginWithCorrectCredentials() {
    System.assertEquals(
      null,
      LightningLoginFormController.login(
        'yashadmob121@gmail.com',
        'AKANKSHA',
        'quint/'
      )
    );
  }

  @IsTest
  static void testLoginWithoutCorrectCredentials() {
    System.assertEquals(
      'Your login attempt has failed. Make sure the username and password are correct',
      LightningLoginFormController.login(
        'yashadmob121@gmail.com',
        'YASHRAJ',
        'quint/'
      )
    );
  }

  @IsTest
  static void LightningLoginFormControllerInstantiation() {
    LightningLoginFormController controller = new LightningLoginFormController();
    System.assertNotEquals(controller, null);
  }

  @IsTest
  static void testIsUsernamePasswordEnabled() {
    System.assertEquals(
      true,
      LightningLoginFormController.getIsUsernamePasswordEnabled()
    );
  }

  @IsTest
  static void testIsSelfRegistrationEnabled() {
    System.assertEquals(
      false,
      LightningLoginFormController.getIsSelfRegistrationEnabled()
    );
  }

  @IsTest
  static void testGetSelfRegistrationURL() {
    System.assertEquals(
      null,
      LightningLoginFormController.getSelfRegistrationUrl()
    );
  }

  @IsTest
  static void testAuthConfig() {
    Auth.AuthConfiguration authConfig = LightningLoginFormController.getAuthConfig();
    System.assertNotEquals(null, authConfig);
  }
}
