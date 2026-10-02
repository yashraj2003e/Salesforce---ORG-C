# scramblingBatch HLD

```mermaid
flowchart TD
  A[Batch is started] --> B{User batch?}
  B -- No --> C[Query Contacts to scramble]
  B -- Yes --> D[Query Users to scramble]

  C --> E[executeScramblingNonSetupObjects()]
  D --> F[executeScramblingSetupObjects()]

  E --> G[Prefix Contact fields with opt-out text]
  E --> H[Mark Contact inactive]
  E --> I[Collect Account and User references]
  E --> J[Database.update Contacts]
  J --> K{Any row failures?}
  K -- Yes --> L[Enqueue errorLog]
  K -- No --> M[Scramble related Accounts]
  M --> N[Database.update Accounts]
  N --> O{Any row failures?}
  O -- Yes --> P[Enqueue errorLog]
  O -- No --> Q[Done]

  F --> R[Prefix User fields with opt-out text]
  F --> S[Mark User inactive]
  F --> T[Database.update Users]
  T --> U{Any row failures?}
  U -- Yes --> V[Publish error event]
  U -- No --> W[Done]

  E --> X[finish()]
  F --> X
  X --> Y{Non-user batch and userIds collected?}
  Y -- Yes --> Z[Launch second scramblingBatch for Users]
  Y -- No --> AA[Finish]
```

## Summary

- Scrambles either Contacts first or Users directly, depending on how the batch was started.
- The non-user path can collect related User ids and chain a second batch for setup objects.
- Errors are handled through both error events and the `errorLog` queueable.
