# Kapada Creation Firestore Schema

> This document is the canonical shared Firebase data contract.
> Changes must be applied to both repositories.

## Architecture Principles

- Both Flutter apps use the same Firebase project.
- KC-App and KC-Admin remain independent Flutter projects and Git repositories.
- Firestore is the shared source of backend data.
- Normal screens fetch data once and refresh manually.
- Do not use continuous Firestore listeners for standard screens.
- Use cursor-based pagination instead of offset pagination.
- Customer identity uses a permanent `customerId`.
- `customerId` is separate from Firebase Authentication `uid`.
- The backend supports multiple boutiques.
- Each boutique may contain multiple branches.
- Business documents include `boutiqueId` and `branchId` where applicable.
- Customers may browse designs without authentication.
- Admins create and manage stitching orders.
- Customers can only view their own stitching orders.
- The product does not support cart, checkout, payment, or shipping.
