# Frontend System HLD

```mermaid
flowchart TD
  subgraph UX[Frontend Experience Layer]
    A[Community / Experience Page] --> B[quintLogin LWC]
    A --> C[quingForgotPassword LWC]
    A --> D[externalContentRenderer LWC]

    B --> E[Username + Password form]
    C --> F[Username form]
    D --> G[Hidden iframe + form submission]
  end

  subgraph Auth[Authentication Flow]
    E --> H[handleSubmit()]
    H --> I[QuintLogin.SiteLogin(username, password)]
    I --> J[Site.login(username, password, sitePrefix)]
    J --> K{Login success?}
    K -- Yes --> L[Redirect to community home / site URL]
    K -- No --> M[Display invalid credentials error]

    F --> N[handleSubmit()]
    N --> O[quintForgotPassword.resetPassword(username)]
    O --> P[Validate username is active and member of current network]
    P --> Q{Valid user?}
    Q -- Yes --> R[Site.forgotPassword(username)]
    R --> S[Show success message and redirect to login]
    Q -- No --> T[Show error / reject reset]
  end

  subgraph Content[Embedded External Content Flow]
    D --> U[@api externalContentName]
    U --> V[@wire getExternalContentDetails]
    V --> W[ExternalContent Apex method]
    W --> X[Validate External_Content__c record is active]
    X --> Y[Fetch endpoint, method, contact parameters, crypto key]
    Y --> Z[Query current user Contact]
    Z --> AA[Encrypt contact payload]
    AA --> AB[Return endpointURL + method + outboundData]
    AB --> AC[renderedCallback()]
    AC --> AD[Find hidden form and submit to external endpoint]
    AD --> AE[Target iframe: externalContentFrame]
    AE --> AF[External system loads inside iframe]
  end

  subgraph Support[Shared support layer]
    I --> AG[YashOrgC_Utility.publishErrorEvent()]
    O --> AG
    W --> AG
  end

  classDef ui fill:#dfeeff,stroke:#1f4e79,stroke-width:1px;
  classDef auth fill:#e8f5e9,stroke:#2e7d32,stroke-width:1px;
  classDef content fill:#fff3cd,stroke:#b8860b,stroke-width:1px;
  classDef support fill:#f3e5f5,stroke:#6a1b9a,stroke-width:1px;

  class A,B,C,D,E,F,G ui;
  class H,I,J,K,L,M,N,O,P,Q,R,S,T auth;
  class U,V,W,X,Y,Z,AA,AB,AC,AD,AE,AF content;
  class AG support;
```

## Summary

- The frontend is centered around community-driven user interaction rather than heavy custom UI frameworks.
- The most important frontend modules are the login page, reset-password page, and external content renderer.
- The UI is intentionally thin: it captures user inputs, delegates validation and data retrieval to Apex/Auth services, and reacts to server results by redirecting or submitting a hidden form.
- Error handling is centralized through `YashOrgC_Utility.publishErrorEvent()`, so failures are tracked without exposing internal details to the user.

## Frontend components

### 1. Login component

**LWC:** `quintLogin`

Purpose:

- Collect username and password from the user.
- Validate required fields.
- Call `QuintLogin.SiteLogin()`.
- Redirect to the community site URL on success.

Key flow:

- User types credentials.
- `handleCredentialChange()` stores values.
- `handleSubmit()` checks for empty values.
- Apex `Site.login()` returns a URL.
- Browser redirects to the returned community page.

### 2. Forgot password component

**LWC:** `quingForgotPassword`

Purpose:

- Accept a username.
- Validate that the username belongs to the current community network.
- Trigger `Site.forgotPassword(username)`.
- Show success/error states and redirect to login page.

Key flow:

- User submits username.
- Apex verifies active user and NetworkMember membership.
- If valid, password reset email is issued.
- UI updates success message and redirects after a short delay.

### 3. External content renderer

**LWC:** `externalContentRenderer`

Purpose:

- Accept an `externalContentName` parameter.
- Fetch external endpoint metadata from Apex.
- Build the outbound payload from the current user Contact.
- Encrypt the payload before sending it.
- Submit a hidden form to the external endpoint inside an iframe.

Key flow:

- `@wire getExternalContentDetails` loads configuration.
- `renderedCallback()` waits for endpoint + method + encrypted data.
- A hidden HTML form is submitted with target = iframe.
- The remote system renders inside the embedded frame without leaving the page.

## Frontend architecture pattern

The frontend follows a simple Salesforce community pattern:

1. UI collects input
2. LWC calls Apex service methods
3. Apex validates or resolves business logic
4. Response is returned to the UI
5. UI redirects, displays status, or submits an embedded form

This keeps the UI lightweight while preserving Salesforce security and platform features such as Site.login, network validation, and encrypted data handling.

## Important exclusions

To keep this HLD focused, the following were intentionally omitted because they do not materially affect the frontend behavior:

- Non-core trigger handlers
- Generic utility classes not directly part of the UI flow
- Low-value batch jobs or background processors
- Internal backend orchestration details unrelated to the user experience

## Design takeaway

The meaningful frontend system is a set of thin, user-focused LWC screens that sit on top of platform authentication and lightweight Apex service methods. The system is designed to keep the customer experience simple:

- login
- password recovery
- secure outbound content embedding

This keeps the user journey clear while the platform handles identity, validation, and security concerns in the background.
