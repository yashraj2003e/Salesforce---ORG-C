trigger acountTrigger on Account(before update) {
  if (Trigger.isUpdate) {
    if (Trigger.isBefore) {
      accountTriggerHandler.validateContactActiveStatus(
        Trigger.oldMap,
        Trigger.newMap
      );
    }
  }
}
