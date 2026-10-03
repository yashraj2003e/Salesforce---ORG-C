# Environment Details - 
Salesforce Org Link - https://yashorgc-dev-ed.develop.my.salesforce.com

# Key Features -
1) Bi-Directional contact details sync through REST API utilizing below features ->
   * Named Credential
   * Auth Provider
   * External Client Application (migrated from Connected Application)
     
2) Automatic User creation and linking through a Queueable APEX, ensuring recursion is prevented through custom permission.
   
4) Platform Event to store Error logs (As the transaction rollsback if the transaction is failed, the error log is not created through direct DML, even asynchronous apex are rolled back. As Platform Events can be set to publish immediately, it is Ideal to generate an error log and throw error simultaneously when required).
   * To capture Debug Logs, the trace should be set on - *Automated Process* user.

5) Scrambling Batch - Mentioning the batch specifically to showcase the utilization of Stateful (Database.stateful). The batch anonymize the data of contact and user, the logic is in place in the same class. The key point here is to avoid Mixed DML as User is a setup object and contact is a non-setup object. This was accomplished by developing a stateful batch and invoking the class twice - one for contact anonymization and one for user.
     
6) Additional business automation -
   * Includes batch processing for deactivation, scrambling, and cleanup-style operations.
   * Applies validation logic to protect related records during Account updates.


# High Level System Design (Backend Systen)

<img width="3968" height="3790" alt="mermaid-diagram (3)" src="https://github.com/user-attachments/assets/22a70272-8d3a-4d26-90f8-536cbaa3839d" />

# High Level System Design (Frontend Systen)

<img width="1536" height="1024" alt="Salesforce Community Architecture Flowchart" src="https://github.com/user-attachments/assets/eb4153fe-a907-45b2-83ec-19c424c6f5b3" />

# 1) External Content Renderer (iFrame) High Level Design

<img width="1312" height="1199" alt="LWC External Content Processing Flow" src="https://github.com/user-attachments/assets/af27ff09-810c-4136-acb9-1e8a5c967edc" />

# 2) Key Apex Classes High Level Design

## Contact Creation HLD

<img width="2422" height="3016" alt="mermaid-diagram (1)" src="https://github.com/user-attachments/assets/ea369c6d-0080-4091-bbf7-96b30bb0ca27" />

## Contact Update HLD

<img width="2422" height="3016" alt="mermaid-diagram (1)" src="https://github.com/user-attachments/assets/be29d12a-43b5-44e2-aa4d-d4d37a8a47a5" />

# 3) Asynchronous Apex High Level Design

## User Creation Queueable Class

<img width="926" height="2496" alt="mermaid-diagram (4)" src="https://github.com/user-attachments/assets/755e503b-9790-4ea1-8c61-da9b1c6ba1e0" />

## Contact-User Sync Queueable Class

<img width="846" height="1730" alt="mermaid-diagram (5)" src="https://github.com/user-attachments/assets/177c9d02-15fe-4cb6-ac55-d01948e15758" />

## Scrambling Batch Class

<img width="3990" height="2634" alt="mermaid-diagram (6)" src="https://github.com/user-attachments/assets/ad3de2d4-4d83-4d0e-a3b2-d4c3b754549d" />

## User Deactivation Batch Class

<img width="2654" height="2650" alt="mermaid-diagram (7)" src="https://github.com/user-attachments/assets/01724d08-cdb2-43dd-8575-7efab1d20bfe" />

## Transaction List Batch Class

<img width="548" height="1174" alt="mermaid-diagram (8)" src="https://github.com/user-attachments/assets/cd08952b-b502-490d-9962-e2c6ed3daed4" />
