public class contactTriggerHandler {

    public static void addIntegrationId(List<contact> insertedContacts) {
        for(contact con : insertedContacts) {
            UUID integrationId = UUID.randomUUID();
            if(con.integration_id__c == null) {
                con.integration_id__c = String.valueOf(integrationId);
            }
        }
    }


    public static void handleContactInsert(List<contact> contacts) {
        System.debug(UserInfo.getUserId());
        List<account> accounts = new List<account>();
        List<contact> updatedContacts = new List<contact>();
        for(contact customercontact : contacts) {
            String accountName = customercontact.FirstName + ' ' + customercontact.LastName;
            account ac = new account(name = accountName,market__c = yashOrgCConstants.MARKET);
            accounts.add(ac);
        }
        
        insert accounts;
        
        List<ID> ids = new List<ID>();
        for(integer i = 0;i<contacts.size();i++) {
            contact c = new contact(Id = contacts[i].Id,accountId = accounts[i].id);
            ids.add(contacts[i].id);
            updatedContacts.add(c);
        }
        System.debug(ids.size());
        for(contact c1 : [select id,integration_id__c from contact where id in :ids]) {
            System.debug(c1);
        }
        update updatedContacts;
        
        System.enqueueJob(new createCustomerUser(contacts));
    }
 
    public static void syncContactUpdate(List<contact> updatedContact) {
		List<contact> contactsToSync = new List<contact>();
        for(contact con : updatedContact) {
            if(!FeatureManagement.checkPermission('Data_Integration_User')) {
                contactsToSync.add(con);
            }
        }
        if(!contactsToSync.isEmpty()) {
            System.enqueueJob(new syncContactQueueable(contactsToSync));
        }
    }
    
    public static void updateContactTransactions(List<transaction_list__c> transactions) {
        List<contact> contactsToUpdate = new List<contact>();
        Map<Id,Double> contactPoints = new Map<Id,Double>();
        List<ID> contactIds = new List<ID>();
        
        for(transaction_list__c curtransaction : transactions) {
            contactIds.add(curtransaction.contact__c);
        }
        
        List<contact> contacts = [select id,award_points__c from contact where id in :contactIds];
        
        for(contact c : contacts) {
            contactPoints.put(c.Id,c.award_points__c);
        }
              
        for(transaction_list__c currtransaction : transactions) {
            Double existing_points = (Double)contactPoints.get(currtransaction.Contact__c);
            contact c = new contact(id = currtransaction.contact__c);
            c.award_points__c = existing_points + currtransaction.award_points__c;
            contactsToUpdate.add(c);
        }
        
        if(!contactsToUpdate.isEmpty()) {
            update contactsToUpdate;
        }
        
    }
}