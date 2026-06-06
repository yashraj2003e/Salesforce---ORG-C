public class contactTriggerHandler extends TriggerHandler {
  Map<Id, Contact> oldMap;
  Map<Id, Contact> newMap;
  List<Contact> oldList;
  List<Contact> newList;

  public contactTriggerHandler() {
    super('ContactTriggerHandler');
    this.oldMap = (Map<Id, Contact>) Trigger.oldMap;
    this.newMap = (Map<Id, Contact>) Trigger.newMap;
    this.oldList = (List<Contact>) Trigger.old;
    this.newList = (List<Contact>) Trigger.new;
  }

  public override void beforeInsert() {
    addIntegrationId();
  }

  public override void afterInsert() {
    handleContactInsert();
  }

  public override void afterUpdate() {
    syncContactUpdate();
  }

  public void addIntegrationId() {
    for (contact con : this.newList) {
      UUID integrationId = UUID.randomUUID();
      if (con.integration_id__c == null) {
        con.integration_id__c = String.valueOf(integrationId);
      }
    }
  }

  public void handleContactInsert() {
    System.debug(UserInfo.getUserId());
    List<account> accounts = new List<account>();
    List<contact> updatedContacts = new List<contact>();
    for (contact customercontact : this.newList) {
      String accountName = YashOrgC_Utility.addSpaceText(
        customercontact.FirstName,
        customercontact.LastName
      );

      Integer randomMarket = YashOrgC_Utility.getRandomNumber();

      account ac = new account(
        name = accountName,
        market__c = yashOrgCConstants.marketIds[randomMarket]
      );

      accounts.add(ac);
    }

    if (!accounts.isEmpty()) {
      insert accounts;
      updateAccountOwner(accounts);
    }

    List<ID> ids = new List<ID>();
    for (integer i = 0; i < this.newList.size(); i++) {
      contact c = new contact(
        Id = this.newList[i].Id,
        accountId = accounts[i].id,
        ownerId = accounts[i].ownerId
      );
      ids.add(this.newList[i].id);
      updatedContacts.add(c);
    }

    if (!updatedContacts.isEmpty()) {
      update updatedContacts;
    }

    System.enqueueJob(new createCustomerUser(this.newList));
    syncContactUpdate();
  }

  public void updateAccountOwner(List<Account> accounts) {
    Set<Id> marketIds = new Set<Id>();

    for (Account acc : accounts) {
      if (acc.Market__c != null) {
        marketIds.add(acc.Market__c);
      }
    }

    Map<Id, Market__c> marketMap = new Map<Id, Market__c>(
      [
        SELECT Id, OwnerId
        FROM Market__c
        WHERE Id IN :marketIds
      ]
    );

    for (Account acc : accounts) {
      Market__c market = marketMap.get(acc.Market__c);

      if (market != null) {
        acc.OwnerId = market.OwnerId;
      }
    }

    update accounts;
  }

  public void syncContactUpdate() {
    List<contact> contactsToSync = new List<contact>();
    Boolean canSync = !FeatureManagement.checkPermission(
      'Data_Integration_User'
    );
    if (canSync) {
      contactsToSync.addAll(this.newList);
    }
    if (!contactsToSync.isEmpty()) {
      System.enqueueJob(new syncContactQueueable(contactsToSync));
    }
  }
}
