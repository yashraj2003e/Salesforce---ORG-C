public without sharing virtual class TriggerHandler {
  private OperationType context;
  private static Set<String> byPassedHandlers = new Set<String>();
  private String triggerName;

  public TriggerHandler(String triggerName) {
    this.triggerName = triggerName;
    setContext();
  }

  public void run() {
    if (!validateRun())
      return;
    if (context == OperationType.BEFORE_INSERT)
      beforeInsert();
    if (context == OperationType.AFTER_INSERT)
      afterInsert();
    if (context == OperationType.BEFORE_UPDATE)
      beforeUpdate();
    if (context == OperationType.AFTER_UPDATE)
      afterUpdate();
    if (context == OperationType.BEFORE_DELETE)
      beforeDelete();
    if (context == OperationType.AFTER_DELETE)
      afterDelete();
    if (context == OperationType.AFTER_UNDELETE)
      afterUndelete();
  }

  private Boolean validateRun() {
    if (!Trigger.isExecuting || context == null) {
      return false;
    }

    if (byPassedHandlers.contains(this.triggerName))
      return false;

    return true;
  }

  public static void byPass(String triggerName) {
    byPassedHandlers.add(triggerName);
  }

  public static void clearByPass(String triggerName) {
    byPassedHandlers.remove(triggerName);
  }

  public static void clearAllByPass() {
    byPassedHandlers.clear();
  }

  private void setContext() {
    if (!Trigger.isExecuting)
      return;

    if (Trigger.isInsert && Trigger.isBefore) {
      context = OperationType.BEFORE_INSERT;
    }
    if (Trigger.isInsert && Trigger.isAfter) {
      context = OperationType.AFTER_INSERT;
    }
    if (Trigger.isUpdate && Trigger.isBefore) {
      context = OperationType.BEFORE_UPDATE;
    }
    if (Trigger.isUpdate && Trigger.isAfter) {
      context = OperationType.AFTER_UPDATE;
    }
    if (Trigger.isDelete && Trigger.isBefore) {
      context = OperationType.BEFORE_DELETE;
    }
    if (Trigger.isDelete && Trigger.isAfter) {
      context = OperationType.AFTER_DELETE;
    }
    if (Trigger.isUndelete && Trigger.isAfter) {
      context = OperationType.AFTER_UNDELETE;
    }
  }

  private enum OperationType {
    BEFORE_INSERT,
    BEFORE_UPDATE,
    BEFORE_DELETE,
    AFTER_INSERT,
    AFTER_UPDATE,
    AFTER_DELETE,
    AFTER_UNDELETE
  }

  protected virtual void beforeInsert() {
  }
  protected virtual void afterInsert() {
  }
  protected virtual void beforeUpdate() {
  }
  protected virtual void afterUpdate() {
  }
  protected virtual void beforeDelete() {
  }
  protected virtual void afterDelete() {
  }
  protected virtual void afterUndelete() {
  }
}
