public class SyncContactQueueable implements Queueable, Database.AllowsCallouts {
    
    string syncContactQueueableExecute = 'SyncContactQueueable.execute()';
    
    public List<contactsDTO> updatedContact;
    
    public SyncContactQueueable(List<Contact> updateContact) {
        List<contactsDTO> mappedData = new List<contactsDTO>();
        for(contact c : updateContact) {
            contactsDTO cDTO = new contactsDTO();
                cDTO.integrationid = c.integration_id__c;
                cDTO.id = c.id;
                cDTO.firstname = c.firstname;
                cDTO.LastName = c.lastname;
                cDTO.isactive = c.isactive__c;
                cDTO.email = c.email;
                cDTO.awardpoints = c.award_points__c;
                cDTO.optOutYRI = c.opt_out_YRI__c;
                mappedData.add(cDTO);
        }
        
        this.updatedContact = mappedData;
    }
 
    public void execute(QueueableContext qc) {
    try {
        Http http = new Http();
        HttpRequest req = new HttpRequest();
            
        yashorgb_integration_config__mdt config = yashorgb_integration_config__mdt.getInstance('sync_Contact');
        req.setEndpoint('callout:yashorgb'+config.endpoint__c);
        req.setMethod('POST');
        req.setHeader('Content-Type','application/json');
        req.setBody(JSON.serialize(updatedContact));

        HttpResponse res = http.send(req);
            
        if(res.getStatusCode() != 200) {
            String resultData = res.getBody() + res.getStatusCode();
            errorLog.createErrorLog(resultData,syncContactQueueableExecute);        
        }
    }
    catch(Exception e) {
        errorLog.createErrorLog(e,syncContactQueueableExecute);
        throw e;
    }
}
}