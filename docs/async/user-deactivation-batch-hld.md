# UserDeactivationBatch HLD

```mermaid
flowchart TD
  A[Batch or schedule starts] --> B[UserDeactivationBatch.execute()]
  B --> C{Schedulable invocation?}
  C -- Yes --> D[Start default user batch]
  C -- No --> E[Continue existing batch]

  D --> F[start(): Query Users to deactivate]
  E --> G{Contact batch?}
  G -- No --> F
  G -- Yes --> H[start(): Query Contacts by ContactId]

  F --> I[deactivateSetupObject()]
  I --> J[Mark User inactive]
  J --> K{User has ContactId?}
  K -- Yes --> L[Collect ContactId for follow-up]
  K -- No --> M[Enqueue errorLog]
  I --> N[Database.update Users]
  N --> O{Any row failures?}
  O -- Yes --> P[Enqueue errorLog]
  O -- No --> Q[finish()]
  Q --> R[Launch Contact batch with collected ContactIds]

  H --> S[deactivateNonSetupObject()]
  S --> T[Mark Contact inactive]
  T --> U[Database.update Contacts]
  U --> V{Any row failures?}
  V -- Yes --> W[Enqueue errorLog]
  V -- No --> X[Done]
```

## Summary

- Deactivates Users first, then chains a second batch to deactivate related Contacts.
- Also supports a Contact-only path when started with Contact ids.
- All failures are routed into `errorLog` queueables.
