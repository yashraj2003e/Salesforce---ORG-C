@RestResource(urlMapping='/syncContact')
global without sharing class syncContact {
  private static final string syncContactsyncContactMethod = 'syncContact.syncContactMethod()';

  private static final Map<String, String> fieldMap = new Map<String, String>{
    'email' => 'email',
    'firstname' => 'firstName',
    'lastname' => 'lastName',
    'awardpoints' => 'transaction_Points__c',
    'isactive' => 'isactive__c',
    'optoutyri' => 'opt_out_YRI__c',
    'integrationid' => 'integration_id__c'
  };

  @HttpPost
  global static void syncContactMethod() {
    try {
      String body = RestContext.request.requestBody.toString();

      List<contactsDTO> dtos = (List<contactsDTO>) JSON.deserialize(
        body,
        List<contactsDTO>.class
      );

      List<Contact> cons = new List<Contact>();

      List<String> sourceContactIds = new List<String>();

      for (contactsDTO dto : dtos) {
        sourceContactIds.add(dto.integrationid);
      }

      Map<String, ID> sourceContactIdMap = new Map<String, ID>();

      for (contact con : [
        SELECT integration_id__c, id
        FROM contact
        WHERE integration_id__c IN :sourceContactIds
      ]) {
        sourceContactIdMap.put(con.integration_id__c, con.id);
      }

      List<contact> contactsToUpdate = new List<contact>();
      List<contact> contactsToInsert = new List<contact>();

      for (contactsDTO dto : dtos) {
        Contact c = new Contact();

        Map<String, Object> dtoMap = (Map<String, Object>) JSON.deserializeUntyped(
          JSON.serialize(dto)
        );

        for (String key : dtoMap.keySet()) {
          Object value = dtoMap.get(key);
          if (fieldMap.containsKey(key) && value != null) {
            c.put(fieldMap.get(key), value);
          }
        }
        System.debug(c);
        System.debug(dtoMap);
        System.debug(sourceContactIdMap);
        if (sourceContactIdMap.containsKey(dto.integrationid)) {
          c.id = (ID) sourceContactIdMap.get(dto.integrationid);
          contactsToUpdate.add(c);
        } else {
          contactsToInsert.add(c);
        }
      }

      if (!contactsToInsert.isEmpty()) {
        insert contactsToInsert;
      } else {
        update contactsToUpdate;
      }
    } catch (Exception e) {
      errorLog.createErrorLog(e, syncContactsyncContactMethod);
      throw e;
    }
  }
}
