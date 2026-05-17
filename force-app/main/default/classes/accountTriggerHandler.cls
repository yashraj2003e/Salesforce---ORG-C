public class accountTriggerHandler {
    public static void validateContactActiveStatus(Map<Id,account> oldMap,Map<Id,account> newMap) {
            List<ID> accounts = new List<ID>();
            for(Id accountId : newMap.keyset()) {
                if(newMap.get(accountId).active__c == 'No' && oldMap.get(accountId).active__c == 'Yes') {
                    accounts.add(accountId);
                }
            }

            List<aggregateResult> ar = [select accountId from contact where isactive__c = true and accountId in :accounts group by accountId];
            
            for (AggregateResult a : ar) {   
                Id accId = (Id) a.get('AccountId');
                Account ac = newMap.get(accId);
                if (ac != null) {
                    ac.active__c.addError('Account has atleast one active contact!');
                }
            }
    }
}