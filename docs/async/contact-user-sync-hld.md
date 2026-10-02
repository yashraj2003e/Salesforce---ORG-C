# ContactUserSync HLD

```mermaid
flowchart TD
  A[Queued with ContactId -> Email map] --> B[ContactUserSync.execute()]
  B --> C[Query User by ContactId]
  C --> D[Set User.Email from Contact email]
  D --> E[Set User.Username from Contact email]
  E --> F[Database.update(allOrNone=false)]
  F --> G{Any row failures?}
  G -- Yes --> H[Publish error event per failure]
  G -- No --> I[Done]
```

## Summary

- Runs only when a Contact email changes.
- Syncs the related User's `Email` and `Username` fields.
- Uses partial update handling and publishes errors for failed rows.
