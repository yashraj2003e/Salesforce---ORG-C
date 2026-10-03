public with sharing class CryptoKeyTriggerHandler extends TriggerHandler {
  List<Crypto_key__c> oldList;
  List<Crypto_key__c> newList;
  Map<Id, Crypto_Key__c> oldMap;
  Map<Id, Crypto_Key__c> newMap;

  public CryptoKeyTriggerHandler() {
    super('CryptokeyTriggerHandler');

    this.oldList = (List<Crypto_key__c>) Trigger.old;
    this.newList = (List<Crypto_key__c>) Trigger.new;

    this.oldMap = (Map<Id, Crypto_key__c>) Trigger.oldMap;
    this.newMap = (Map<Id, Crypto_key__c>) Trigger.newMap;
  }

  public override void beforeInsert() {
    for (crypto_key__c curEncryption : this.newList) {
      curEncryption.Key__c = encodingUtil.base64Encode(
        crypto.generateAesKey(256)
      );
      curEncryption.Vector__c = encodingUtil.base64Encode(
        crypto.generateAesKey(128)
      );
    }
  }
}
