# Overall System HLD

```mermaid
flowchart TD
  subgraph SalesForce[Salesforce Core]
    A[Contact Insert] --> B[contactTrigger.beforeInsert()]
    B --> C[Assign integration_id__c]

    A --> D[contactTrigger.afterInsert()]
    D --> E[Create Account for Contact]
    E --> F[Set Account market and owner]
    F --> G[Update Account owner by Market__c]
    E --> H[Update Contact.AccountId and OwnerId]
    D --> I[Enqueue createCustomerUser]
    D --> J[Call syncContactUpdate()]

    K[Contact Update] --> L[contactTrigger.afterUpdate()]
    L --> J
    L --> M[contactUserSync()]

    N[Account Update] --> O[accountTrigger.beforeUpdate()]
    O --> P{Any active Contacts on Account?}
    P -- Yes --> Q[Block update with addError]
    P -- No --> R[Allow Account update]
  end

  subgraph Async[Async Processing]
    I --> S[createCustomerUser Queueable]
    S --> T[Insert Community User]
    T --> U[Update Contact.User__c]
    U --> L

    J --> V{Has Data_Integration_User permission?}
    V -- No --> W[Enqueue syncContactQueueable]
    V -- Yes --> X[Skip outbound sync]

    M --> Y{Email changed?}
    Y -- Yes --> Z[Enqueue ContactUserSync]
    Y -- No --> AA[No User email sync]

    W --> AB[Map Contact to contactsDTO]
    AB --> AC[POST to sync_Contact endpoint]
    AC --> AD{HTTP 200?}
    AD -- Yes --> AE[Done]
    AD -- No --> AF[Enqueue errorLog]

    Z --> AG[Query User by ContactId]
    AG --> AH[Update User.Email and Username]
    AH --> AI[Database.update(allOrNone=false)]
    AI --> AJ[Publish per-row errors]
  end

  subgraph ErrorPipeline[Error Reporting]
    AF --> AK[Insert error_log__c]
    AJ --> AL[Publish Error_Event__e]
    AM[publishErrorEvent()] --> AL
    AL --> AN[ErrorEventTrigger]
    AN --> AO[ErrorEventTriggerHandler]
    AO --> AP[Insert error_log__c]
  end

  classDef business fill:#dff1ff,stroke:#1b6ca8,stroke-width:1px;
  classDef async fill:#fff3cd,stroke:#b38b00,stroke-width:1px;
  classDef error fill:#fce8e6,stroke:#b3261e,stroke-width:1px;

  class A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P,Q,R business;
  class S,T,U,V,W,X,Y,Z,AA,AB,AC,AD,AE,AF,AG,AH,AI,AJ async;
  class AK,AL,AM,AN,AO,AP error;
```

## Summary

- Contact create drives the main orchestration: Account creation, community User creation, and outbound Contact sync.
- Contact update reuses the same outbound sync path and also syncs the related User when the email changes.
- Account update has a validation guard that blocks deactivating an Account if it still has active Contacts.
- Errors are reported through two mechanisms: direct `error_log__c` insertion and platform event publication through `Error_Event__e`.
