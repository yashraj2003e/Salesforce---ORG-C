public class transactionListBatch implements Database.Batchable<SObject> {
    public Database.queryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([select id,award_points__c,contact__c from transaction_list__c where expiry_date__c = yesterday]);
    }
    
    public void execute(Database.BatchableContext bc,List<transaction_list__c> transactionList) {
        Map<Id, Double> contactPoints = new Map<Id, Double>();

        for (transaction_list__c t : transactionList) { 
            Double existing = contactPoints.get(t.contact__c);
            if (existing == null) existing = 0;
            Double pts = t.award_points__c == null ? 0 : t.award_points__c;
            contactPoints.put(t.contact__c, existing + pts);
        }

        List<contact> contactsToUpdate = new List<contact>();
        
        List<contact> contacts = [select id,award_points__c from contact where id in :contactPoints.keyset()];
        
        for(contact c : contacts) {
            c.award_points__c = c.award_points__c - contactPoints.get(c.id);
        }
        
		update contacts;
    }
    
    public void finish(Database.BatchableContext bc) {
        System.debug('Mission Complete');
    }
}