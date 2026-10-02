# errorLog HLD

```mermaid
flowchart TD
  A[Queueable is enqueued with error data] --> B[errorLog.execute()]
  B --> C{Exception provided?}
  C -- Yes --> D[Build detailed exception text]
  C -- No --> E[Use provided error string]
  D --> F[Insert error_log__c]
  E --> F[Insert error_log__c]
  F --> G{Exception provided?}
  G -- Yes --> H[Re-throw exception]
  G -- No --> I[Done]
```

## Summary

- Centralized queueable for writing failures into `error_log__c`.
- Used by other async paths when they need a durable error record.
- Re-throws the exception only when it was created from an exception input.
