# Firebase Rules (Future Preparation)

> [!IMPORTANT]
> Firebase is **NOT** configured yet and packages are not installed. These rules govern future Firebase integration once the official setup task is executed.

- **Data Source Encapsulation**: Firebase SDKs must only be invoked inside `data/datasources/` or infrastructure services.
- **No Direct UI Calls**: Widgets must never import or call Firebase directly.
- **No Live Snapshot Listeners**: Do not use `snapshots()` or continuous stream listeners for normal application data. Use one-time `get()` reads with manual refresh.
- **Multi-Tenant / Branch Scoping**: Every branch-owned document in Firestore must include `boutiqueId` and `branchId`.
- **Security Rules**: Validate authentication and resource ownership in Firestore security rules. Never trust client-provided role fields.
- **No Client Secrets**: Never store Firebase Admin credentials, private keys, or API secrets inside the client app.
- **ID Separation**: Firebase Auth UID is not the business ID. Customer documents use a permanent UUID `customerId`.
- **Storage Paths**: Firebase Storage paths must include boutique and branch scope (`boutiques/{boutiqueId}/branches/{branchId}/...`).
- **Server Timestamps**: Use server timestamps (`FieldValue.serverTimestamp()`) for creation and update metadata fields.
- **Batch Limits**: Batch operations must respect Firestore's 500-operation limit.

## Standard Entity Metadata Fields

```text
createdAt
updatedAt
createdBy
updatedBy
boutiqueId
branchId
isActive
```
