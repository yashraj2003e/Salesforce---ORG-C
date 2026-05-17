public class scramblingBatch implements Database.Batchable<SObject>,Database.stateful {
    
    String strScramblingBatchExecute = 'scramblingBatch.execute';
    String strScramblingBatchFinish = 'scramblingBatch.finish';
    String strScramblingBatchexecuteScramblingNonSetupObjects = 'scramblingBatch.executeScramblingNonSetupObjects';
    String strScramblingBatchexecuteScramblingSetupObjects = 'scramblingBatch.executeScramblingSetupObjects';
    String strScramblingBatchScrambleAccount = 'scramblingBatch.ScrambleAccount';
    
    public Boolean isUserBatch;
    
    public Set<ID> userIds = new Set<ID>();
    
    public scramblingBatch() {
        this.isUserBatch = false;
    }
    
    public scramblingBatch(Set<ID> userIds) {
        this.isUserBatch = true;
        this.userIds = userIds;
    }

    public Database.queryLocator start(Database.BatchableContext db) {
        return !isUserBatch ? Database.getQueryLocator([select id,firstName,lastName,isactive__c,opt_out_yri__c,email,accountId,user__c
                                                        from contact 
                                                        where opt_out_yri__c = 'requested']) : 
        					  Database.getQueryLocator([select id,firstname,lastname,username,federationIdentifier,isactive 
                                                        from user 
                                                        where id in :userIds]);
    }
    
    public void execute(Database.BatchableContext db,List<SObject> objectToScramble) {
        try {
            if(isUserBatch) {
                executeScramblingSetupObjects((List<user>)objectToScramble);
            }
            else {
                executeScramblingNonSetupObjects((List<contact>)objectToScramble);
            }
        }
        catch(Exception e) {
            errorLog.createErrorLog(e,strScramblingBatchExecute);
        }
    }
    
    public void finish(Database.BatchableContext db) {
        try {
            if(!isUserBatch) {
                if(!userIds.isEmpty()) {
                    Database.executeBatch(new scramblingBatch(userIds));
                }
            }
        }
        catch(exception e) {
            errorLog.createErrorLog(e, strScramblingBatchFinish);
        }
    }
    
    public void executeScramblingNonSetupObjects(List<contact> contactsToScramble) {
        try {
            Set<ID> accountIds = new Set<ID>();
            
            for(contact con : contactsToScramble) {
                con.firstName = (con.firstName == null ? '' : con.firstName) + yashOrgCConstants.OPT_OUT;
                con.lastName = (con.lastName == null ? '' : con.lastName) + yashOrgCConstants.OPT_OUT;
                con.isactive__c = false;
                con.opt_out_yri__c = 'opt out';
                con.email = (con.email == null ? '' : con.email) + yashOrgCConstants.INVALID;
                if(con.accountId != null) accountIds.add(con.accountID);
                if(con.user__c != null) userIds.add(con.user__c);
            }
            
            update contactsToScramble;        
            if(!accountIds.isEmpty()) {
                scrambleAccount(accountIds);
            }
        }
        catch(exception e) {
            errorLog.createErrorLog(e, strScramblingBatchexecuteScramblingNonSetupObjects);
        }
    }
    
    public void scrambleAccount(Set<Id> accountIds) {
        try {
            List<account> accountsToScramble = new List<account>();
            
            for(account ac : [select id,name from account where id in :accountIDs]) {
                ac.name = (ac.name == null ? '' : ac.name) + yashOrgCConstants.OPT_OUT;
                accountsToScramble.add(ac);
            }
            
            update accountsToScramble;
        }
        catch(Exception e) {
            errorLog.createErrorLog(e, strScramblingBatchScrambleAccount);
        }
    }


    public void executeScramblingSetupObjects(List<user> users) {
        try {
            List<user> usersToScramble = new List<user>();
            
            for(user u : users) {
                u.firstName = (u.firstName == null ? '' : u.firstName) + yashOrgCConstants.OPT_OUT;
                u.lastName = (u.lastName == null ? '' : u.lastName) + yashOrgCConstants.OPT_OUT;
                u.userName = u.userName + yashOrgCConstants.INVALID;
                u.federationIdentifier = (u.federationIdentifier == null ? '' : u.federationIdentifier) + yashOrgCConstants.INVALID;
                u.isactive = false;
                usersToScramble.add(u);
            }
            
            if(!usersToScramble.isEmpty()) {
                update usersToScramble;
            }
        }
        catch(exception e) {
            errorLog.createErrorLog(e, strScramblingBatchexecuteScramblingSetupObjects);
        }
    }    
    
}