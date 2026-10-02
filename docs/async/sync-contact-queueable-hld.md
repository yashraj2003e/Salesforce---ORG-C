# SyncContactQueueable HLD

```mermaid
flowchart TD
  A[Queueable is enqueued with Contacts] --> B[SyncContactQueueable.execute()]
  B --> C{Test run?}
  C -- Yes --> D[Return immediately]
  C -- No --> E[Load sync_Contact metadata]
  E --> F[Build HTTP POST request]
  F --> G[Serialize contactsDTO payload]
  G --> H[Send callout]
  H --> I{Status code 200?}
  I -- Yes --> J[Done]
  I -- No --> K[Enqueue errorLog queueable]
  K --> L[Insert error_log__c]
```

## Summary

- Sends updated Contact data to the external `sync_Contact` endpoint.
- Only executes the callout outside of test context.
- Non-200 responses are handed off to the error logging queueable.
