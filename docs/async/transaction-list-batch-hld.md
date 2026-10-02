# transactionListBatch HLD

```mermaid
flowchart TD
  A[Batch starts] --> B[start(): Query expired transaction_list__c rows]
  B --> C[execute(): Loop each transaction]
  C --> D[Set award_points__c to 0]
  D --> E[update transaction records]
  E --> F[finish(): log completion]
```

## Summary

- Finds transaction list records that expired yesterday.
- Resets their award points to zero.
- Ends with a simple completion log in `finish()`.
