trigger transactionListTrigger on transaction_list__c (after insert,after update) {
    if(Trigger.isAfter) {
        if(Trigger.isInsert) {
            contactTriggerHandler.updateContactTransactions(Trigger.new);
        }
        if(Trigger.isUpdate) {
            contactTriggerHandler.updateContactTransactions(Trigger.new);
        }
    }
}