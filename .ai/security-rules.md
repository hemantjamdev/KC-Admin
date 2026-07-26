# Security Rules

- Never commit secrets, API keys, service account JSON files, or private certificates to version control.
- Never hard-code admin roles or authorization bypasses inside client app source code.
- Firestore security rules must enforce default deny and validate `boutiqueId` and `branchId` scoping.
- Sanitize and validate all user inputs prior to processing.
- UUID is an identifier, not a security token. Do not treat entity IDs as secret authorization tokens.
- Sensitive client storage (tokens) must use secure storage abstractions.
- Never log customer personal identifiers or stitching data.
- Support secure account deletion flows when required by platform guidelines.
