trigger contactTrigger on Contact (before insert,after insert,after update) {
    if(Trigger.isInsert) {
        if(Trigger.isBefore) {
            contactTriggerHandler.addIntegrationId(Trigger.new);
        }
        if(Trigger.isAfter) {
            contactTriggerHandler.handleContactInsert(Trigger.new);
            contactTriggerHandler.syncContactUpdate(Trigger.new);
        }
    }
    else if(Trigger.isUpdate) {
        if(Trigger.isAfter) {
            contactTriggerHandler.syncContactUpdate(Trigger.new);
        }
    }
}