public with sharing class ExternalContent {
  @AuraEnabled(cacheable=false)
  public static Map<String, String> getExternalContentDetails(
    String ExternalContentName
  ) {
    List<External_Content__c> externalContents = [
      SELECT
        id,
        is_active__c,
        endpoint__c,
        HTTP_Method__c,
        Contact_Parameters__c,
        Encryption_Key__c
      FROM external_content__c
      WHERE name = :ExternalContentName
      LIMIT 1
    ];

    if (
      externalContents.isEmpty() || externalContents[0].is_active__c == false
    ) {
      throw new AuraHandledException(
        'No such External Content record exists or the Content is not active !'
      );
    }

    External_Content__c externalContent = externalContents[0];

    Map<String, String> outboundData = new Map<String, String>();

    outboundData.put('endpointURL', externalContent.Endpoint__c);
    outboundData.put('method', externalContent.http_method__c);

    if (externalContent.Contact_Parameters__c != null) {
      List<String> outboundParameters = externalContent.Contact_Parameters__c.split(
        ';'
      );

      String dataToQuery = '';

      for (string parameter : outboundParameters) {
        dataToQuery += parameter;
        dataToQuery += ',';
      }

      dataToQuery = dataToQuery.substring(0, dataToQuery.length() - 1);

      ID contactId = [
        SELECT contactid
        FROM user
        WHERE id = :UserInfo.getUserId()
      ]
      .contactId;

      string query =
        'SELECT ' +
        dataToQuery +
        ' FROM CONTACT WHERE ID = :contactId';

      Contact contactData = database.query(query);
      String serializedData = JSON.serialize(contactData);
      // outboundData.put('parameter',JSON.serialize(dataToQuery));

      crypto_key__c cryptoKey = [
        SELECT id, key__c, vector__c
        FROM Crypto_Key__c
        WHERE id = :externalContent.Encryption_Key__c
        LIMIT 1
      ];

      blob key = EncodingUtil.base64Decode(cryptoKey.key__c);
      blob vector = EncodingUtil.base64Decode(cryptoKey.vector__c);

      Blob encryptedData = crypto.encrypt(
        'AES256-CBC',
        key,
        vector,
        Blob.valueOf(serializedData)
      );

      outboundData.put(
        'outboundData',
        EncodingUtil.base64Encode(encryptedData)
      );
    }

    return outboundData;
  }
}