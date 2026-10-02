trigger ErrorEventTrigger on Error_Event__e(after insert) {
  System.debug(Trigger.new);
  new ErrorEventTriggerHandler().run();
}
