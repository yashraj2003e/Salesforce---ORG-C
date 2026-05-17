public class scrambleCustomerUsers implements Queueable {
    public void execute(QueueableContext qc){
        
    }
	/*
    List<contact> contacts;
    
    public scrambleCustomerUsers(List<contact> contacts) {
        this.contacts = contacts;
    }
    
    public void execute(QueueableContext qc) {
      
        Map<Id,String> contactUserMap = new Map<Id,String>();

        for(Contact c : contacts) {
            System.debug('Line 14 -> ');
            System.debug(c.User__c);
            if(c.User__c != null) {
                System.debug('Line 15 -> ');
                System.debug(c.User__c);
                String name = c.FirstName + ' ' + c.lastName;
                contactUserMap.put(c.User__c,name);
                
            }
        }
                
        List<User> users = [
            SELECT Id, firstName,lastName, Username, Email, IsActive, federationIdentifier
            FROM User
            WHERE Id IN :contactUserMap.keySet()
        ];
        
        for(user u : users) {
            u.FirstName = (String)contactUserMap.get(u.id);
            u.LastName = (String)contactUserMap.get(u.id);
            u.username = u.username + '.invalid';
            u.email = u.email + '.invalid';
            u.isactive = false;
        }
         
        update users;   
    }
    
    
    */
}