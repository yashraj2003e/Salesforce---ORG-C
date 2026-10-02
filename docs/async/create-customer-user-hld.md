# createCustomerUser HLD

```mermaid
flowchart TD
  A[Queueable is enqueued] --> B[createCustomerUser.execute()]
  B --> C[Iterate Contacts]
  C --> D[Build User record]
  D --> E[Set alias, username, email, profile, locale]
  E --> F[Insert Users]
  F --> G[Update Contact.User__c]
  G --> H[Update Contact records]
  H --> I[Contact afterUpdate fires]
  I --> J[syncContactUpdate()]
  I --> K[contactUserSync()]
  K --> L{Email changed?}
  L -- Yes --> M[Enqueue ContactUserSync]
  L -- No --> N[No email sync]
```

## Summary

- Creates a community User for each Contact in the queue.
- Links the new User back to the Contact through `User__c`.
- The Contact update can trigger the normal after-update Contact logic again.
