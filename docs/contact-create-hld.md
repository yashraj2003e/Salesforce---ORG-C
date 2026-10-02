# Contact Create HLD

```mermaid
flowchart TD
  A[Contact is inserted] --> B[contactTrigger.beforeInsert()]
  B --> C[addIntegrationId()]
  C --> C1[Populate integration_id__c if blank]

  A --> D[contactTrigger.afterInsert()]
  D --> E[handleContactInsert()]
  E --> F[Create 1 Account per Contact]
  F --> G[Assign random Market__c and current user as owner]
  G --> H[Insert Accounts]
  H --> I[updateAccountOwner()]
  I --> J[Set Account.OwnerId from Market__c owner]
  J --> K[Update Accounts]

  E --> L[Update Contact.AccountId and Contact.OwnerId]
  L --> M[Update Contact records]
  E --> N[Enqueue createCustomerUser]
  E --> O[syncContactUpdate()]

  N --> P[createCustomerUser.execute()]
  P --> Q[Insert Community User per Contact]
  Q --> R[Update Contact.User__c]
  R --> S[Contact afterUpdate fires again]
  S --> T[syncContactUpdate()]
  S --> U[contactUserSync()]
  U --> V{Email changed?}
  V -- Yes --> W[Enqueue ContactUserSync]
  V -- No --> X[No user email sync]

  O --> Y{Data_Integration_User permission?}
  Y -- No --> Z[Enqueue syncContactQueueable]
  Y -- Yes --> AA[Skip outbound sync]

  T --> Y
  Z --> AB[Map Contact to DTO]
  AB --> AC[HTTP POST to external sync_Contact endpoint]
```

## Summary

- Before insert, the trigger assigns `integration_id__c` if it is missing.
- After insert, the handler creates and links an Account for each Contact.
- It then enqueues a queueable that creates the related community User and writes that User back to the Contact.
- The post-insert update from `createCustomerUser` can fire the Contact trigger again, which may enqueue the external sync path and the email-sync path.
