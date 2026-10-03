# External Content Renderer HLD

```mermaid
flowchart TD
  A[Community page loads component] --> B[externalContentRenderer LWC]
  B --> C[@api externalContentName]
  C --> D[@wire getExternalContentDetails]
  D --> E[ExternalContent Apex class]

  E --> F{External_Content__c exists and is_active__c = true?}
  F -- No --> G[Throw AuraHandledException]
  F -- Yes --> H[Read endpoint__c, HTTP_Method__c, Contact_Parameters__c, Encryption_Key__c]
  H --> I[Get current user ContactId]
  I --> J[Build dynamic SOQL using Contact_Parameters__c]
  J --> K[Query Contact record]
  K --> L[JSON.serialize(contact data)]
  L --> M[Load Crypto_Key__c record]
  M --> N[Base64 decode key and vector]
  N --> O[AES256-CBC encryption of payload]
  O --> P[Set outboundData = encrypted base64 string]
  P --> Q[Return { endpointURL, method, outboundData }]

  Q --> R[LWC receives wire response]
  R --> S[renderedCallback()]
  S --> T{Has already submitted?}
  T -- Yes --> U[Stop]
  T -- No --> V[Find hidden form in template]
  V --> W[Set form.action = endpointURL]
  W --> X[Set form.method = method]
  X --> Y[Set hidden input query = outboundData]
  Y --> Z[form.submit()]
  Z --> AA[Target iframe = externalContentFrame]
  AA --> AB[External endpoint receives request]
  AB --> AC[External system renders content inside iframe]

  classDef ui fill:#dfeeff,stroke:#1f4e79,stroke-width:1px;
  classDef apex fill:#e8f5e9,stroke:#2e7d32,stroke-width:1px;
  classDef crypto fill:#fff3cd,stroke:#b8860b,stroke-width:1px;
  classDef external fill:#f3e5f5,stroke:#6a1b9a,stroke-width:1px;

  class A,B,C,D,R,S,V,W,X,Y,Z,AA ui;
  class E,F,G,H,I,J,K,L,M,N,O,P,Q apex;
  class O,P,AB crypto;
  class AB,AC external;
```

## Summary

- The component is configured with an `externalContentName` value supplied from the page.
- A wire call invokes Apex to fetch the metadata for the external content record.
- Apex validates that the record exists and is active before exposing the endpoint configuration.
- It builds a dynamic Contact SOQL query based on the configured `Contact_Parameters__c`, reads the logged-in user’s Contact, and encrypts the serialized response using the configured crypto key.
- The LWC receives the encrypted payload and performs a hidden form submission to the external URL.
- The external content is rendered inside an iframe, allowing the page to embed remote content without navigating away from the current experience.

## Functional flow

1. The page loads the LWC and passes the external content name.
2. Apex queries `External_Content__c` metadata and validates activity status.
3. Contact data is selected dynamically from the configured parameter list.
4. The selected Contact data is serialized, encrypted, and returned to the UI.
5. The renderer submits a POST/GET form to the external endpoint using the target iframe.
6. The remote content renders inside the embedded frame.

## Design notes

- This pattern is useful when an external system must receive user-specific Salesforce data without performing a full page redirect.
- The payload is not sent in plain text; it is encrypted before being posted.
- The component guards against duplicate form-submission by tracking `hasSubmitted` in `renderedCallback()`.
- The implementation is designed for community pages and is exposed via the LWC metadata target configuration.
