public without sharing class SyncContactResponse {
  String integrationId;
  String status;
  String failReason;
  public syncContactResponse(
    string integrationId,
    string status,
    string failReason
  ) {
    this.integrationId = integrationId;
    this.status = status;
    this.failReason = failReason;
  }
}
