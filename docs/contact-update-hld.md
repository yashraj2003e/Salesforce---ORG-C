# Contact Update HLD

```mermaid
flowchart TD
  A[Contact is updated] --> B[contactTrigger.afterUpdate()]
  B --> C[syncContactUpdate()]
  B --> D[contactUserSync()]

  C --> E{Data_Integration_User permission?}
  E -- No --> F[Enqueue syncContactQueueable]
  E -- Yes --> G[Skip outbound sync]

  F --> H[Map Contact to contactsDTO]
  H --> I[HTTP POST to sync_Contact endpoint]
  I --> J{Response 200?}
  J -- Yes --> K[Done]
  J -- No --> L[Enqueue errorLog / publish error event]

  D --> M{Email changed?}
  M -- Yes --> N[Enqueue ContactUserSync]
  M -- No --> O[Skip user email sync]
  N --> P[Query User by ContactId]
  P --> Q[Update User.Email and User.Username]
  Q --> R[Database.update(allOrNone=false)]
  R --> S[Publish errors for failed rows]
```

## Summary

- After update, the trigger handler runs two branches: the outbound Contact sync and the linked User email sync.
- `syncContactUpdate()` enqueues `syncContactQueueable` unless the running user has the `Data_Integration_User` permission.
- `contactUserSync()` only enqueues `ContactUserSync` when the Contact email actually changed.
- `ContactUserSync` updates the related User record's `Email` and `Username` fields.
