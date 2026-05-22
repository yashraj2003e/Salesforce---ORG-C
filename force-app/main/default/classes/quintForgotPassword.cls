public without sharing class quintForgotPassword {

    public static final String ForgotPassword = 'quintForgotPassword.resetPassword';
    public quintForgotPassword() {
        System.debug('Constructor called');
    }
    @AuraEnabled
    public static Boolean resetPassword(String username) {
        System.debug('reached here');
        try {
            Site.forgotPassword(username);
            return true;
        }
        catch(Exception e) {
            errorLog.createErrorLog(e, ForgotPassword);
            return false;
        }
    }


}