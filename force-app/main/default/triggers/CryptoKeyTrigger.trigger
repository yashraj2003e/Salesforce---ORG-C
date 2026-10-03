trigger CryptoKeyTrigger on Crypto_Key__c(before insert) {
  new CryptoKeyTriggerHandler().run();
}
