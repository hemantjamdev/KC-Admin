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

## Top-Level Collections

The initial Firestore schema uses these top-level collections:

- `boutiques`
- `branches`
- `admins`
- `customers`
- `categories`
- `designs`
- `designAvailability`
- `sections`
- `sectionItems`
- `favourites`
- `stitchingOrders`
- `stitchingOrderHistory`
- `notifications`
- `notificationReads`
- `deviceTokens`

### Collection Responsibilities

#### `boutiques`

Stores the primary boutique businesses using the platform.

#### `branches`

Stores physical or operational branches belonging to a boutique.

#### `admins`

Stores authorized admin profiles linked to Firebase Authentication users.

#### `customers`

Stores permanent Kapada Creation customer identities.

The customer document ID must use `customerId`, not Firebase Authentication UID.

#### `categories`

Stores design categories belonging to a boutique.

#### `designs`

Stores reusable design information.

Designs must not contain one global availability field because availability is branch-specific.

#### `designAvailability`

Stores the availability of a design for a specific branch.

Each document links one design to one branch.

#### `sections`

Stores curated groups shown in the customer application, such as new arrivals or festive collections.

#### `sectionItems`

Stores ordered design references belonging to a section.

Do not embed complete design documents inside sections.

#### `favourites`

Stores a relationship between one customer and one design.

Duplicate favourites must be prevented using a deterministic document ID.

#### `stitchingOrders`

Stores the current state and summary of each stitching order.

#### `stitchingOrderHistory`

Stores the append-only status timeline for stitching orders.

#### `notifications`

Stores global, boutique, branch, customer, and stitching-related notifications.

#### `notificationReads`

Stores whether a customer has read a notification.

Do not duplicate complete notification documents here.

#### `deviceTokens`

Stores Firebase Cloud Messaging tokens for customer and admin devices.

## Shared Document Conventions

Firestore document fields must use lower camel case.

Use Firestore `Timestamp` values for all stored dates and times.

Do not store timestamps as:

- Strings
- Unix integers
- Formatted date text

### Common fields

Use these fields only where they are relevant:

| Field | Firestore type | Purpose |
|---|---|---|
| `id` | `string` | Must match the Firestore document ID |
| `boutiqueId` | `string` | Identifies the owning boutique |
| `branchId` | `string` | Identifies the owning or selected branch |
| `createdAt` | `timestamp` | Creation time generated with a server timestamp |
| `updatedAt` | `timestamp` | Last modification time generated with a server timestamp |
| `createdBy` | `string` | Firebase UID of the authenticated creator |
| `updatedBy` | `string` | Firebase UID of the authenticated updater |
| `isActive` | `boolean` | Controls whether the document is currently active |
| `schemaVersion` | `number` | Version of the document structure |

### Required rules

- `id` must match the actual Firestore document ID when the collection uses an `id` field.
- `createdAt` must never be changed after document creation.
- `updatedAt` must be refreshed whenever persistent document data changes.
- `createdBy` and `updatedBy` store Firebase Authentication UIDs, not customer IDs or display names.
- New versioned business documents start with `schemaVersion: 1`.
- Do not add `boutiqueId` or `branchId` to documents where they have no valid business meaning.
- Do not use both `status` and `isActive` for the same purpose.
- Do not authorize access using duplicated names, email addresses, or display text.
- Authorization must use stable IDs and authenticated Firebase UIDs.

### Soft deletion

Do not use soft deletion by default.

Use it only when historical references, restoration, or audit requirements make permanent deletion unsafe.

When soft deletion is required, use:

| Field | Firestore type |
|---|---|
| `isDeleted` | `boolean` |
| `deletedAt` | `timestamp` |
| `deletedBy` | `string` |

A soft-deleted document must be excluded from normal customer and admin listing queries.

## Document ID Conventions

Use stable document IDs that remain unchanged for the lifetime of the record.

### ID strategy

| Collection | Document ID strategy |
|---|---|
| `boutiques` | Firestore-generated ID |
| `branches` | Firestore-generated ID |
| `admins` | Firebase Authentication UID |
| `customers` | Permanent application-generated UUID stored as `customerId` |
| `categories` | Firestore-generated ID |
| `designs` | Firestore-generated ID |
| `designAvailability` | Deterministic ID using `branchId_designId` |
| `sections` | Firestore-generated ID |
| `sectionItems` | Firestore-generated ID |
| `favourites` | Deterministic ID using `customerId_designId` |
| `stitchingOrders` | Firestore-generated ID |
| `stitchingOrderHistory` | Firestore-generated ID |
| `notifications` | Firestore-generated ID |
| `notificationReads` | Deterministic ID using `customerId_notificationId` |
| `deviceTokens` | Deterministic ID derived from the FCM token using a secure hash |

### Required rules

- Never use display names, emails, phone numbers, slugs, or mutable business values as primary document IDs.
- Never use Firebase Authentication UID as the customer document ID.
- `customerId` must remain unchanged even if the customer later links or changes a Firebase Authentication account.
- Human-readable values such as `branchCode`, `orderNumber`, and `slug` are fields, not document IDs.
- Deterministic IDs are used only to prevent duplicate relationship documents.
- Do not parse deterministic document IDs for authorization.
- Authorization must validate the explicit fields stored inside the document.
- Firestore-generated IDs must be created using Firestore's automatic document ID generation.
- FCM tokens must not be stored directly as document IDs because they may contain unsafe characters and may change.
- The raw FCM token must still be stored inside the `deviceTokens` document.

## Collection Schemas

### `boutiques`

Stores the boutique businesses using the platform.

#### Document ID

Use a Firestore-generated ID.

The `id` field must match the Firestore document ID.

#### Fields

| Field | Firestore type | Required | Description |
|---|---|---:|---|
| `id` | `string` | Yes | Firestore document ID |
| `name` | `string` | Yes | Boutique display name |
| `slug` | `string` | Yes | Stable lowercase URL-safe identifier |
| `logoUrl` | `string` | No | Firebase Storage or CDN URL for the boutique logo |
| `phone` | `string` | No | Primary contact number |
| `email` | `string` | No | Primary contact email |
| `address` | `map` | No | Structured primary business address |
| `isActive` | `boolean` | Yes | Whether the boutique is active |
| `createdAt` | `timestamp` | Yes | Server-generated creation timestamp |
| `updatedAt` | `timestamp` | Yes | Server-generated last update timestamp |
| `createdBy` | `string` | Yes | Firebase UID of the creating admin |
| `updatedBy` | `string` | Yes | Firebase UID of the last updating admin |
| `schemaVersion` | `number` | Yes | Starts at `1` |

#### Address structure

When `address` is present, use this structure:

| Field | Firestore type | Required |
|---|---|---:|
| `line1` | `string` | Yes |
| `line2` | `string` | No |
| `city` | `string` | Yes |
| `state` | `string` | Yes |
| `postalCode` | `string` | Yes |
| `countryCode` | `string` | Yes |

Use ISO 3166-1 alpha-2 country codes, such as `IN`.

#### Validation rules

- `name` must not be empty.
- `slug` must be lowercase and URL-safe.
- `slug` must be unique across active boutiques.
- `isActive` defaults to `true`.
- Do not store branches inside the boutique document.
- Do not store admin accounts as embedded objects.
- Do not store large configuration maps.
- Do not store complete analytics summaries in this document.
- `createdAt` must never change after creation.
- `updatedAt` must change whenever boutique data changes.

#### Example

```json
{
  "id": "boutiqueDocumentId",
  "name": "Kapada Creation",
  "slug": "kapada-creation",
  "logoUrl": null,
  "phone": null,
  "email": null,
  "address": {
    "line1": "Main Road",
    "line2": null,
    "city": "Ahmedabad",
    "state": "Gujarat",
    "postalCode": "380001",
    "countryCode": "IN"
  },
  "isActive": true,
  "createdAt": "Firestore Timestamp",
  "updatedAt": "Firestore Timestamp",
  "createdBy": "firebaseAdminUid",
  "updatedBy": "firebaseAdminUid",
  "schemaVersion": 1
}
```

The JSON example is illustrative only. Actual timestamps must use Firestore `Timestamp`.

### `branches`

Stores physical or operational branches belonging to a boutique.

#### Document ID

Use a Firestore-generated ID.

The `id` field must match the Firestore document ID.

#### Fields

| Field | Firestore type | Required | Description |
|---|---|---:|---|
| `id` | `string` | Yes | Firestore document ID |
| `boutiqueId` | `string` | Yes | Parent boutique document ID |
| `name` | `string` | Yes | Branch display name |
| `code` | `string` | Yes | Short human-readable branch code |
| `phone` | `string` | No | Branch contact number |
| `email` | `string` | No | Branch contact email |
| `address` | `map` | Yes | Structured branch address |
| `isActive` | `boolean` | Yes | Whether the branch is active |
| `createdAt` | `timestamp` | Yes | Server-generated creation timestamp |
| `updatedAt` | `timestamp` | Yes | Server-generated last update timestamp |
| `createdBy` | `string` | Yes | Firebase UID of the creating admin |
| `updatedBy` | `string` | Yes | Firebase UID of the last updating admin |
| `schemaVersion` | `number` | Yes | Starts at `1` |

#### Address structure

Use this structure:

| Field | Firestore type | Required |
|---|---|---:|
| `line1` | `string` | Yes |
| `line2` | `string` | No |
| `city` | `string` | Yes |
| `state` | `string` | Yes |
| `postalCode` | `string` | Yes |
| `countryCode` | `string` | Yes |
| `latitude` | `number` | No |
| `longitude` | `number` | No |

Use ISO 3166-1 alpha-2 country codes, such as `IN`.

#### Validation rules

- `boutiqueId` must reference an existing boutique.
- `name` must not be empty.
- `code` must be uppercase and human-readable.
- `code` must be unique within the same boutique.
- `code` must not be used as the Firestore document ID.
- `isActive` defaults to `true`.
- A branch cannot be considered active when its parent boutique is inactive.
- Do not embed categories, designs, admins, customers, or stitching orders inside the branch document.
- `createdAt` must never change after creation.
- `updatedAt` must change whenever branch data changes.

#### Example

```json
{
  "id": "branchDocumentId",
  "boutiqueId": "boutiqueDocumentId",
  "name": "Navrangpura Branch",
  "code": "NAV01",
  "phone": null,
  "email": null,
  "address": {
    "line1": "C.G. Road",
    "line2": null,
    "city": "Ahmedabad",
    "state": "Gujarat",
    "postalCode": "380009",
    "countryCode": "IN",
    "latitude": null,
    "longitude": null
  },
  "isActive": true,
  "createdAt": "Firestore Timestamp",
  "updatedAt": "Firestore Timestamp",
  "createdBy": "firebaseAdminUid",
  "updatedBy": "firebaseAdminUid",
  "schemaVersion": 1
}
```

The JSON example is illustrative only. Actual timestamps must use Firestore `Timestamp`.

### `admins`

Stores authorized admin profiles linked to Firebase Authentication users.

Successful Firebase Email/Password authentication does not automatically grant admin access. An active admin document must also exist.

#### Document ID

Use the Firebase Authentication UID as the Firestore document ID.

The following values must match:

```text
admins/{documentId}
documentId == firebaseUid
id == firebaseUid
```

#### Fields

| Field | Firestore type | Required | Description |
| --- | --- | ---: | --- |
| `id` | `string` | Yes | Firebase Authentication UID and Firestore document ID |
| `firebaseUid` | `string` | Yes | Firebase Authentication UID |
| `email` | `string` | Yes | Admin login email |
| `displayName` | `string` | Yes | Admin display name |
| `boutiqueIds` | `array<string>` | Yes | Boutiques this admin may access |
| `branchIds` | `array<string>` | Yes | Branches this admin may access |
| `isSuperAdmin` | `boolean` | Yes | Whether the admin has platform-wide access |
| `isActive` | `boolean` | Yes | Whether admin access is currently allowed |
| `createdAt` | `timestamp` | Yes | Server-generated creation timestamp |
| `updatedAt` | `timestamp` | Yes | Server-generated last update timestamp |
| `createdBy` | `string` | Yes | Firebase UID of the admin or backend that created this profile |
| `updatedBy` | `string` | Yes | Firebase UID of the last updater |
| `lastLoginAt` | `timestamp` | No | Last successful authorized admin login |
| `schemaVersion` | `number` | Yes | Starts at `1` |

#### Access model

* `isSuperAdmin: true` grants access across all boutiques and branches.
* A normal admin must have at least one valid `boutiqueId`.
* `branchIds` may contain only branches belonging to a boutique listed in `boutiqueIds`.
* An empty `branchIds` array means no branch access unless `isSuperAdmin` is `true`.
* Do not infer admin access from the authentication provider.
* Do not infer admin access from the email domain.
* Do not authorize using display name or email.
* Future Firestore rules must validate the authenticated UID against this document.
* Future custom claims may improve rule performance, but this document remains the canonical admin profile.

#### Validation rules

* `id` must equal `firebaseUid`.
* The document ID must equal `firebaseUid`.
* `email` must match the Firebase Authentication account email.
* `displayName` must not be empty.
* `boutiqueIds` and `branchIds` must not contain duplicates.
* `isActive` defaults to `true`.
* Only a super admin or trusted backend may create another admin profile.
* Admin users cannot create their own admin documents.
* Normal admins must not change `isSuperAdmin`.
* Deactivating an admin document must immediately prevent protected Firestore access after rules are implemented.
* Never store passwords, password hashes, access tokens, refresh tokens, or secrets in this document.

#### Example

```json
{
  "id": "firebaseAdminUid",
  "firebaseUid": "firebaseAdminUid",
  "email": "admin@kapadacreation.com",
  "displayName": "Kapada Creation Admin",
  "boutiqueIds": [
    "boutiqueDocumentId"
  ],
  "branchIds": [
    "branchDocumentId"
  ],
  "isSuperAdmin": false,
  "isActive": true,
  "createdAt": "Firestore Timestamp",
  "updatedAt": "Firestore Timestamp",
  "createdBy": "superAdminFirebaseUid",
  "updatedBy": "superAdminFirebaseUid",
  "lastLoginAt": null,
  "schemaVersion": 1
}
```

The JSON example is illustrative only. Actual timestamps must use Firestore `Timestamp`.

### `customers`

Stores the permanent Kapada Creation customer identity.

A customer may be created in either of these ways:

1. The customer signs in using Google in `KC-App`.
2. An admin creates the customer while creating a stitching order.

The permanent `customerId` must not change when authentication details change.

#### Document ID

Use the permanent application-generated UUID as the Firestore document ID.

The following values must match:

```text
customers/{documentId}
documentId == customerId
id == customerId
```

Do not use Firebase Authentication UID as the customer document ID.

#### Fields

| Field | Firestore type | Required | Description |
| --- | --- | ---: | --- |
| `id` | `string` | Yes | Permanent customer ID and Firestore document ID |
| `customerId` | `string` | Yes | Permanent application-level UUID |
| `firebaseUid` | `string` | No | Linked Firebase Authentication UID |
| `displayName` | `string` | Yes | Customer display name |
| `email` | `string` | No | Customer email |
| `phone` | `string` | No | Customer contact number |
| `photoUrl` | `string` | No | Customer profile image URL |
| `preferredBoutiqueId` | `string` | No | Customer’s preferred boutique |
| `preferredBranchId` | `string` | No | Customer’s preferred branch |
| `source` | `string` | Yes | How the customer record was created |
| `isActive` | `boolean` | Yes | Whether the customer account is active |
| `createdAt` | `timestamp` | Yes | Server-generated creation timestamp |
| `updatedAt` | `timestamp` | Yes | Server-generated last update timestamp |
| `createdBy` | `string` | Yes | Firebase UID of the creator |
| `updatedBy` | `string` | Yes | Firebase UID of the last updater |
| `lastLoginAt` | `timestamp` | No | Last successful customer login |
| `schemaVersion` | `number` | Yes | Starts at `1` |

#### Allowed `source` values

```text
googleSignIn
adminCreated
```

Use stable lower camel case strings.

#### Identity rules

* `customerId` is the permanent business identity.
* `firebaseUid` is only the authentication identity.
* `firebaseUid` may initially be absent for an admin-created customer.
* Linking a Firebase account must update `firebaseUid` without changing `customerId`.
* One Firebase UID may be linked to only one active customer.
* One active customer may have at most one linked Firebase UID.
* Do not create a customer document for anonymous browsing.
* Do not authorize customer ownership using email or phone number.
* Customer-owned data must use `customerId`.

#### Admin-created customer linking

When an admin creates a customer:

* Generate a permanent UUID for `customerId`.
* Set `source` to `adminCreated`.
* Leave `firebaseUid` as `null`.
* Store available name, phone, or email details.
* Use this same `customerId` for stitching orders.

When the customer later signs in:

* Search for an eligible unlinked customer using trusted linking logic.
* Do not automatically link only because an email or phone matches.
* Require a secure verification process.
* Update the existing customer document with the new `firebaseUid`.
* Do not create a second customer record when a valid existing record is linked.

The exact secure linking workflow will be designed later.

#### Validation rules

* `id` must equal `customerId`.
* The document ID must equal `customerId`.
* `displayName` must not be empty.
* At least one of `email` or `phone` should be present for an admin-created customer.
* `preferredBranchId`, when present, must belong to `preferredBoutiqueId`.
* `isActive` defaults to `true`.
* Customers must not change their own `customerId`, `source`, `createdAt`, or `createdBy`.
* Customers must not link or replace `firebaseUid` directly from the client.
* Sensitive identity linking must be handled by trusted backend logic.
* Never store passwords, authentication tokens, or Google access tokens.

#### Example: Google-authenticated customer

```json
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "customerId": "550e8400-e29b-41d4-a716-446655440000",
  "firebaseUid": "firebaseCustomerUid",
  "displayName": "Customer Name",
  "email": "customer@example.com",
  "phone": null,
  "photoUrl": null,
  "preferredBoutiqueId": "boutiqueDocumentId",
  "preferredBranchId": "branchDocumentId",
  "source": "googleSignIn",
  "isActive": true,
  "createdAt": "Firestore Timestamp",
  "updatedAt": "Firestore Timestamp",
  "createdBy": "firebaseCustomerUid",
  "updatedBy": "firebaseCustomerUid",
  "lastLoginAt": "Firestore Timestamp",
  "schemaVersion": 1
}
```

#### Example: Admin-created customer

```json
{
  "id": "6ba7b810-9dad-11d1-80b4-00c04fd430c8",
  "customerId": "6ba7b810-9dad-11d1-80b4-00c04fd430c8",
  "firebaseUid": null,
  "displayName": "Walk-in Customer",
  "email": null,
  "phone": "+919876543210",
  "photoUrl": null,
  "preferredBoutiqueId": "boutiqueDocumentId",
  "preferredBranchId": "branchDocumentId",
  "source": "adminCreated",
  "isActive": true,
  "createdAt": "Firestore Timestamp",
  "updatedAt": "Firestore Timestamp",
  "createdBy": "firebaseAdminUid",
  "updatedBy": "firebaseAdminUid",
  "lastLoginAt": null,
  "schemaVersion": 1
}
```

The JSON examples are illustrative only. Actual timestamps must use Firestore `Timestamp`.

### `categories`

Stores design categories belonging to a boutique.

Categories are shared across branches within the same boutique.

#### Document ID

Use a Firestore-generated ID.

The `id` field must match the Firestore document ID.

#### Fields

| Field | Firestore type | Required | Description |
|---|---|---:|---|
| `id` | `string` | Yes | Firestore document ID |
| `boutiqueId` | `string` | Yes | Owning boutique document ID |
| `name` | `string` | Yes | Category display name |
| `slug` | `string` | Yes | Stable lowercase URL-safe identifier |
| `description` | `string` | No | Optional category description |
| `imageUrl` | `string` | No | Optional category image URL |
| `sortOrder` | `number` | Yes | Manual display ordering value |
| `isActive` | `boolean` | Yes | Whether the category is visible and usable |
| `createdAt` | `timestamp` | Yes | Server-generated creation timestamp |
| `updatedAt` | `timestamp` | Yes | Server-generated last update timestamp |
| `createdBy` | `string` | Yes | Firebase UID of the creating admin |
| `updatedBy` | `string` | Yes | Firebase UID of the last updating admin |
| `schemaVersion` | `number` | Yes | Starts at `1` |

#### Validation rules

- `boutiqueId` must reference an existing boutique.
- `name` must not be empty.
- `slug` must be lowercase and URL-safe.
- `slug` must be unique within the same boutique.
- `sortOrder` must be zero or greater.
- `isActive` defaults to `true`.
- An inactive category must not appear in normal customer browsing.
- Designs may remain linked to an inactive category for historical consistency.
- Do not embed design documents inside the category document.
- Do not store branch-specific visibility in this document.
- Do not use category name or slug as the Firestore document ID.
- `createdAt` must never change after creation.
- `updatedAt` must change whenever category data changes.

#### Example

```json
{
  "id": "categoryDocumentId",
  "boutiqueId": "boutiqueDocumentId",
  "name": "Bridal Wear",
  "slug": "bridal-wear",
  "description": "Curated bridal designs",
  "imageUrl": null,
  "sortOrder": 0,
  "isActive": true,
  "createdAt": "Firestore Timestamp",
  "updatedAt": "Firestore Timestamp",
  "createdBy": "firebaseAdminUid",
  "updatedBy": "firebaseAdminUid",
  "schemaVersion": 1
}
```

The JSON example is illustrative only. Actual timestamps must use Firestore `Timestamp`.

### `designs`

Stores the reusable design catalogue for a boutique.

A design may be available in one branch and unavailable in another. Therefore, branch availability must not be stored as one global boolean inside this document.

#### Document ID

Use a Firestore-generated ID.

The `id` field must match the Firestore document ID.

#### Fields

| Field | Firestore type | Required | Description |
|---|---|---:|---|
| `id` | `string` | Yes | Firestore document ID |
| `boutiqueId` | `string` | Yes | Owning boutique document ID |
| `categoryId` | `string` | Yes | Linked category document ID |
| `name` | `string` | Yes | Design display name |
| `slug` | `string` | Yes | Stable lowercase URL-safe identifier |
| `description` | `string` | No | Detailed design description |
| `thumbnailUrl` | `string` | Yes | Primary image used in design cards and lists |
| `imageUrls` | `array<string>` | Yes | Ordered design gallery images |
| `tags` | `array<string>` | Yes | Normalized descriptive tags |
| `searchKeywords` | `array<string>` | Yes | Normalized search terms used for simple Firestore search |
| `isActive` | `boolean` | Yes | Whether the design remains active in the catalogue |
| `createdAt` | `timestamp` | Yes | Server-generated creation timestamp |
| `updatedAt` | `timestamp` | Yes | Server-generated last update timestamp |
| `createdBy` | `string` | Yes | Firebase UID of the creating admin |
| `updatedBy` | `string` | Yes | Firebase UID of the last updating admin |
| `schemaVersion` | `number` | Yes | Starts at `1` |

#### Image rules

- `thumbnailUrl` must reference the primary display image.
- `imageUrls` must preserve the admin-defined display order.
- `imageUrls` must contain at least one image.
- `thumbnailUrl` should normally match one item in `imageUrls`.
- Do not store image bytes, Base64 strings, or large image metadata inside Firestore.
- Store only Firebase Storage or CDN URLs.
- Do not duplicate complete Storage metadata unless required later.

#### Search rules

- Store `tags` as lowercase normalized values.
- Store `searchKeywords` as lowercase normalized values.
- Remove duplicate values from both arrays.
- Do not store empty strings.
- `searchKeywords` may contain:
  - Full normalized design name
  - Individual design-name words
  - Category-related terms
  - Relevant tags
- Firestore does not provide full-text search.
- This field supports only basic prefix or exact-term search patterns.
- A dedicated external search service may be introduced later if required.

#### Availability rules

- Do not add `branchId` to this document.
- Do not add `isAvailable`, `inStock`, or global stock fields here.
- Branch-specific availability belongs in the `designAvailability` collection.
- A design must be active before it can appear in normal customer browsing.
- Customer browsing also requires an active availability document for the selected branch.
- An inactive design may remain referenced by favourites or historical stitching orders.

#### Validation rules

- `boutiqueId` must reference an existing boutique.
- `categoryId` must reference a category belonging to the same boutique.
- `name` must not be empty.
- `slug` must be lowercase and URL-safe.
- `slug` must be unique within the same boutique.
- `thumbnailUrl` must not be empty.
- `imageUrls` must contain at least one valid URL.
- `tags` and `searchKeywords` must not contain duplicates.
- `isActive` defaults to `true`.
- Do not embed category documents.
- Do not embed branch availability objects.
- Do not embed favourite or section relationships.
- Do not use design name or slug as the Firestore document ID.
- `createdAt` must never change after creation.
- `updatedAt` must change whenever design data changes.

#### Example

```json
{
  "id": "designDocumentId",
  "boutiqueId": "boutiqueDocumentId",
  "categoryId": "categoryDocumentId",
  "name": "Royal Maroon Bridal Lehenga",
  "slug": "royal-maroon-bridal-lehenga",
  "description": "A detailed bridal lehenga with traditional embroidery.",
  "thumbnailUrl": "https://example.com/designs/thumbnail.jpg",
  "imageUrls": [
    "https://example.com/designs/image-1.jpg",
    "https://example.com/designs/image-2.jpg"
  ],
  "tags": [
    "bridal",
    "lehenga",
    "maroon",
    "traditional"
  ],
  "searchKeywords": [
    "royal maroon bridal lehenga",
    "royal",
    "maroon",
    "bridal",
    "lehenga",
    "traditional"
  ],
  "isActive": true,
  "createdAt": "Firestore Timestamp",
  "updatedAt": "Firestore Timestamp",
  "createdBy": "firebaseAdminUid",
  "updatedBy": "firebaseAdminUid",
  "schemaVersion": 1
}
```

The JSON example is illustrative only. Actual timestamps must use Firestore `Timestamp`.

### `designAvailability`

Stores branch-specific availability for one design.

A design may be active in the catalogue but available only in selected branches.

#### Document ID

Use a deterministic document ID:

```text
branchId_designId
```

The document must also store `branchId` and `designId` as explicit fields.

Do not parse the document ID for authorization or business logic.

#### Fields

| Field | Firestore type | Required | Description |
| --- | --- | ---: | --- |
| `id` | `string` | Yes | Deterministic Firestore document ID |
| `boutiqueId` | `string` | Yes | Owning boutique document ID |
| `branchId` | `string` | Yes | Branch where the design is available |
| `designId` | `string` | Yes | Linked design document ID |
| `status` | `string` | Yes | Current availability status |
| `displayOrder` | `number` | No | Optional branch-specific manual ordering |
| `availableFrom` | `timestamp` | No | Optional future availability start |
| `availableUntil` | `timestamp` | No | Optional availability end |
| `createdAt` | `timestamp` | Yes | Server-generated creation timestamp |
| `updatedAt` | `timestamp` | Yes | Server-generated last update timestamp |
| `createdBy` | `string` | Yes | Firebase UID of the creating admin |
| `updatedBy` | `string` | Yes | Firebase UID of the last updating admin |
| `schemaVersion` | `number` | Yes | Starts at `1` |

#### Allowed `status` values

```text
available
unavailable
hidden
```

Use stable lower camel case strings.

#### Status meaning

* `available`: visible in normal customer browsing for that branch.
* `unavailable`: hidden from normal browsing but may remain visible in favourites or historical references.
* `hidden`: intentionally suppressed by admin even if the design still exists.

#### Validation rules

* `id` must equal `branchId_designId`.
* `boutiqueId`, `branchId`, and `designId` must all refer to records within the same boutique.
* Only one availability document may exist for each branch and design pair.
* `displayOrder`, when present, must be zero or greater.
* `availableUntil`, when present with `availableFrom`, must be later than `availableFrom`.
* A design must not appear in customer browsing unless:

  * The design is active.
  * The category is active.
  * The boutique is active.
  * The branch is active.
  * The availability status is `available`.
  * The current time is within the optional availability window.
* Do not store design names, descriptions, image galleries, or complete design data here.
* Do not use this collection as stock quantity or inventory tracking.
* Do not add payment, pricing, cart, or order fields.
* `createdAt` must never change after creation.
* `updatedAt` must change whenever availability changes.

#### Example

```json
{
  "id": "branchDocumentId_designDocumentId",
  "boutiqueId": "boutiqueDocumentId",
  "branchId": "branchDocumentId",
  "designId": "designDocumentId",
  "status": "available",
  "displayOrder": 0,
  "availableFrom": null,
  "availableUntil": null,
  "createdAt": "Firestore Timestamp",
  "updatedAt": "Firestore Timestamp",
  "createdBy": "firebaseAdminUid",
  "updatedBy": "firebaseAdminUid",
  "schemaVersion": 1
}
```

The JSON example is illustrative only. Actual timestamps must use Firestore `Timestamp`.

### `sections`

Stores curated design groups shown in the customer application.

Examples:

- New Arrivals
- Trending
- Festive Collection
- Recommended
- Staff Picks

A section may apply to one branch or all branches in a boutique.

#### Document ID

Use a Firestore-generated ID.

The `id` field must match the Firestore document ID.

#### Fields

| Field | Firestore type | Required | Description |
|---|---|---:|---|
| `id` | `string` | Yes | Firestore document ID |
| `boutiqueId` | `string` | Yes | Owning boutique document ID |
| `branchId` | `string` | No | Optional branch restriction |
| `title` | `string` | Yes | Section display title |
| `subtitle` | `string` | No | Optional supporting text |
| `type` | `string` | Yes | Section behavior type |
| `sortOrder` | `number` | Yes | Display order on the customer home screen |
| `isActive` | `boolean` | Yes | Whether the section is active |
| `startAt` | `timestamp` | No | Optional visibility start time |
| `endAt` | `timestamp` | No | Optional visibility end time |
| `createdAt` | `timestamp` | Yes | Server-generated creation timestamp |
| `updatedAt` | `timestamp` | Yes | Server-generated last update timestamp |
| `createdBy` | `string` | Yes | Firebase UID of the creating admin |
| `updatedBy` | `string` | Yes | Firebase UID of the last updating admin |
| `schemaVersion` | `number` | Yes | Starts at `1` |

#### Allowed `type` values

```text
manual
newArrivals
recommended
```

Use stable lower camel case strings.

#### Type meaning

* `manual`: Admin manually selects and orders section designs using `sectionItems`.
* `newArrivals`: Designs are resolved using creation date and branch availability.
* `recommended`: Designs are resolved using recommendation logic defined later.

Do not add automatic `trending` logic yet because no engagement-event schema has been defined.

#### Scope rules

* When `branchId` is present, the section applies only to that branch.
* When `branchId` is absent, the section applies to all active branches within the boutique.
* A section must not reference a branch from another boutique.
* Branch-specific sections may override future boutique-wide presentation behavior, but override logic will be designed later.

#### Visibility rules

A section is visible only when:

* `isActive` is `true`.
* The boutique is active.
* The selected branch is active.
* `startAt` is absent or not later than the current time.
* `endAt` is absent or later than the current time.
* The section contains or resolves at least one eligible design.

#### Validation rules

* `boutiqueId` must reference an existing boutique.
* `branchId`, when present, must belong to the same boutique.
* `title` must not be empty.
* `sortOrder` must be zero or greater.
* `endAt`, when present with `startAt`, must be later than `startAt`.
* `isActive` defaults to `true`.
* Do not embed complete design documents.
* Do not store ordered design IDs directly inside this document for manual sections.
* Manual section membership belongs in `sectionItems`.
* Do not duplicate design names, thumbnails, or availability data here.
* `createdAt` must never change after creation.
* `updatedAt` must change whenever section data changes.

#### Example

```json
{
  "id": "sectionDocumentId",
  "boutiqueId": "boutiqueDocumentId",
  "branchId": "branchDocumentId",
  "title": "Festive Collection",
  "subtitle": "Curated looks for the festive season",
  "type": "manual",
  "sortOrder": 0,
  "isActive": true,
  "startAt": null,
  "endAt": null,
  "createdAt": "Firestore Timestamp",
  "updatedAt": "Firestore Timestamp",
  "createdBy": "firebaseAdminUid",
  "updatedBy": "firebaseAdminUid",
  "schemaVersion": 1
}
```

The JSON example is illustrative only. Actual timestamps must use Firestore `Timestamp`.

### `sectionItems`

Stores manually ordered design references belonging to a curated section.

This collection is used only when the parent section has:

```text
type == manual
```

#### Document ID

Use a Firestore-generated ID.

The `id` field must match the Firestore document ID.

#### Fields

| Field | Firestore type | Required | Description |
| --- | --- | ---: | --- |
| `id` | `string` | Yes | Firestore document ID |
| `boutiqueId` | `string` | Yes | Owning boutique document ID |
| `branchId` | `string` | No | Optional branch scope copied from the parent section |
| `sectionId` | `string` | Yes | Parent section document ID |
| `designId` | `string` | Yes | Referenced design document ID |
| `sortOrder` | `number` | Yes | Manual display order inside the section |
| `isActive` | `boolean` | Yes | Whether this section item is active |
| `createdAt` | `timestamp` | Yes | Server-generated creation timestamp |
| `updatedAt` | `timestamp` | Yes | Server-generated last update timestamp |
| `createdBy` | `string` | Yes | Firebase UID of the creating admin |
| `updatedBy` | `string` | Yes | Firebase UID of the last updating admin |
| `schemaVersion` | `number` | Yes | Starts at `1` |

#### Relationship rules

* `sectionId` must reference an existing section.
* `designId` must reference an existing design.
* The section and design must belong to the same boutique.
* `branchId`, when present, must match the parent section branch scope.
* A section must not contain the same design more than once.
* Duplicate membership must be prevented using validation or trusted write logic.
* Do not embed complete design data.
* Do not duplicate design name, description, tags, or image gallery.

#### Visibility rules

A section item is eligible for customer display only when:

* The item is active.
* The parent section is active and currently visible.
* The design is active.
* The design category is active.
* The boutique is active.
* The selected branch is active.
* A matching `designAvailability` document has status `available`.
* The current time is within any availability window.

#### Validation rules

* `sortOrder` must be zero or greater.
* `isActive` defaults to `true`.
* `createdAt` must never change after creation.
* `updatedAt` must change whenever the item changes.
* Do not use `sortOrder` as a unique identifier.
* Reordering items must update only the required records.
* Do not store an array of all section items inside the parent section.

#### Example

```json
{
  "id": "sectionItemDocumentId",
  "boutiqueId": "boutiqueDocumentId",
  "branchId": "branchDocumentId",
  "sectionId": "sectionDocumentId",
  "designId": "designDocumentId",
  "sortOrder": 0,
  "isActive": true,
  "createdAt": "Firestore Timestamp",
  "updatedAt": "Firestore Timestamp",
  "createdBy": "firebaseAdminUid",
  "updatedBy": "firebaseAdminUid",
  "schemaVersion": 1
}
```

The JSON example is illustrative only. Actual timestamps must use Firestore `Timestamp`.

---

### `favourites`

Stores the relationship between one customer and one design.

A favourite does not grant access to hidden or restricted design data.

#### Document ID

Use this deterministic document ID:

```text
customerId_designId
```

The document must also store `customerId` and `designId` as explicit fields.

Do not parse the document ID for authorization.

#### Fields

| Field | Firestore type | Required | Description |
| --- | --- | ---: | --- |
| `id` | `string` | Yes | Deterministic Firestore document ID |
| `customerId` | `string` | Yes | Owner customer ID |
| `designId` | `string` | Yes | Referenced design ID |
| `boutiqueId` | `string` | Yes | Boutique owning the design |
| `branchId` | `string` | Yes | Branch selected when the favourite was created |
| `createdAt` | `timestamp` | Yes | Server-generated creation timestamp |

#### Ownership rules

* Each favourite belongs to exactly one customer.
* An authenticated customer may read only their own favourites.
* An authenticated customer may create or delete only their own favourites.
* Customers must not update ownership fields.
* Admin access will be defined later in the access matrix.
* Authorization must validate explicit `customerId` ownership.
* Do not authorize using email, phone, display name, or the deterministic ID alone.

#### Duplicate prevention

* `id` must equal `customerId_designId`.
* Only one favourite may exist for the same customer and design pair.
* Creating the same favourite again should be idempotent.
* Do not create duplicate documents with Firestore-generated IDs.

#### Design availability behavior

* A favourite may remain stored when the design becomes unavailable.
* The customer app may still show the favourite with an unavailable state.
* An inactive or deleted design must not expose restricted data.
* The current availability state must be resolved from:

  * `designs`
  * `categories`
  * `designAvailability`
  * active boutique and branch records
* Do not copy complete availability data into the favourite document.

#### Validation rules

* `customerId` must reference an existing customer.
* `designId` must reference an existing design.
* `boutiqueId` must match the design boutique.
* `branchId` must belong to the same boutique.
* `createdAt` must never change.
* This collection does not need `updatedAt`, `createdBy`, `updatedBy`, `isActive`, or `schemaVersion` because it is a simple immutable relationship document.
* Do not store design name, thumbnail, category, description, or complete design data here.
* Do not use favourites as analytics counters.

#### Example

```json
{
  "id": "customerUuid_designDocumentId",
  "customerId": "customerUuid",
  "designId": "designDocumentId",
  "boutiqueId": "boutiqueDocumentId",
  "branchId": "branchDocumentId",
  "createdAt": "Firestore Timestamp"
}
```

The JSON example is illustrative only. Actual timestamps must use Firestore `Timestamp`.

### `stitchingOrders`

Stores the current state and summary of each customer stitching order.

Admins create and manage stitching orders.

Customers may only view their own stitching orders.

#### Document ID

Use a Firestore-generated ID.

The `id` field must match the Firestore document ID.

#### Fields

| Field | Firestore type | Required | Description |
|---|---|---:|---|
| `id` | `string` | Yes | Firestore document ID |
| `boutiqueId` | `string` | Yes | Owning boutique document ID |
| `branchId` | `string` | Yes | Branch managing the stitching order |
| `customerId` | `string` | Yes | Permanent customer ID |
| `orderNumber` | `string` | Yes | Human-readable stitching reference |
| `status` | `string` | Yes | Current stitching status |
| `designReferences` | `array<map>` | Yes | Snapshot references for one or more selected designs |
| `measurementSummary` | `map` | No | Restricted measurement summary |
| `notes` | `string` | No | Internal or customer-safe notes |
| `expectedReadyAt` | `timestamp` | No | Estimated ready date and time |
| `completedAt` | `timestamp` | No | Actual completion timestamp |
| `createdAt` | `timestamp` | Yes | Server-generated creation timestamp |
| `updatedAt` | `timestamp` | Yes | Server-generated last update timestamp |
| `createdBy` | `string` | Yes | Firebase UID of the creating admin |
| `updatedBy` | `string` | Yes | Firebase UID of the last updating admin |
| `schemaVersion` | `number` | Yes | Starts at `1` |

#### Allowed `status` values

```text
received
measurements
cutting
stitching
qualityCheck
ready
completed
```

Use stable lower camel case strings.

#### Status rules

The normal progression is:

```text
received
→ measurements
→ cutting
→ stitching
→ qualityCheck
→ ready
→ completed
```

* The current `status` stores only the latest state.
* Every status change must also create a `stitchingOrderHistory` document.
* Skipping or reversing statuses should require explicit admin confirmation.
* A completed order should normally remain completed.
* `completedAt` must be set when status becomes `completed`.
* `completedAt` must be absent for non-completed orders.

#### `designReferences` structure

Each item may contain:

| Field | Firestore type | Required | Description |
| --- | --- | ---: | --- |
| `designId` | `string` | No | Linked catalogue design ID |
| `designName` | `string` | Yes | Historical display snapshot |
| `thumbnailUrl` | `string` | No | Historical thumbnail snapshot |
| `quantity` | `number` | Yes | Number of garments or pieces |
| `notes` | `string` | No | Design-specific stitching notes |

Rules:

* `quantity` must be greater than zero.
* `designId` may be absent for a custom or offline design.
* Store only minimal snapshots needed for historical display.
* Do not embed complete design documents.
* Historical snapshot values must not be used for authorization.
* Canonical ownership must use `customerId`, `boutiqueId`, and `branchId`.

#### `measurementSummary` structure

This field may contain only the minimum measurements required by the product.

Example keys may include:

```text
chest
waist
hip
shoulder
sleeveLength
garmentLength
inseam
unit
```

Rules:

* Measurement values must use numbers where applicable.
* `unit` must use a stable value such as `cm` or `in`.
* Do not store medical information.
* Do not store unnecessary personal notes.
* Customers may view only their own measurements.
* Normal customers must not read another customer’s measurements.
* Measurement writes must be restricted to authorized admins or trusted backend logic.
* Do not duplicate full measurement data into history documents.

#### Order number rules

* `orderNumber` must be human-readable.
* `orderNumber` must be unique within the branch.
* `orderNumber` must not replace the Firestore document ID.
* Do not use order numbers for authorization.
* The generation strategy will be implemented later using trusted logic.

#### Validation rules

* `boutiqueId` must reference an existing boutique.
* `branchId` must belong to the same boutique.
* `customerId` must reference an existing customer.
* `orderNumber` must not be empty.
* `designReferences` must contain at least one item.
* Only authorized admins may create stitching orders.
* Customers must not create, edit, or delete stitching orders.
* Customers may read only orders where `customerId` belongs to their authenticated identity.
* `createdAt` and `createdBy` must never change.
* `updatedAt` and `updatedBy` must change on every persistent update.
* Do not permanently delete completed or historically referenced orders.
* Soft deletion may be introduced later if cancellation or archival requires it.

#### Example

```json
{
  "id": "stitchingOrderDocumentId",
  "boutiqueId": "boutiqueDocumentId",
  "branchId": "branchDocumentId",
  "customerId": "customerUuid",
  "orderNumber": "NAV01-2026-0001",
  "status": "cutting",
  "designReferences": [
    {
      "designId": "designDocumentId",
      "designName": "Royal Maroon Bridal Lehenga",
      "thumbnailUrl": "https://example.com/design-thumbnail.jpg",
      "quantity": 1,
      "notes": "Custom sleeve length"
    }
  ],
  "measurementSummary": {
    "chest": 38,
    "waist": 32,
    "hip": 40,
    "unit": "in"
  },
  "notes": "Customer requested priority fitting.",
  "expectedReadyAt": "Firestore Timestamp",
  "completedAt": null,
  "createdAt": "Firestore Timestamp",
  "updatedAt": "Firestore Timestamp",
  "createdBy": "firebaseAdminUid",
  "updatedBy": "firebaseAdminUid",
  "schemaVersion": 1
}
```

The JSON example is illustrative only. Actual timestamps must use Firestore `Timestamp`.

---

### `stitchingOrderHistory`

Stores the append-only status timeline for stitching orders.

Each status change creates a separate history document.

#### Document ID

Use a Firestore-generated ID.

The `id` field must match the Firestore document ID.

#### Fields

| Field | Firestore type | Required | Description |
| --- | --- | ---: | --- |
| `id` | `string` | Yes | Firestore document ID |
| `stitchingOrderId` | `string` | Yes | Parent stitching order ID |
| `boutiqueId` | `string` | Yes | Owning boutique ID |
| `branchId` | `string` | Yes | Managing branch ID |
| `customerId` | `string` | Yes | Owner customer ID |
| `status` | `string` | Yes | Status recorded in this event |
| `note` | `string` | No | Optional status-change note |
| `changedAt` | `timestamp` | Yes | Server-generated event timestamp |
| `changedBy` | `string` | Yes | Firebase UID of the admin or trusted backend |
| `schemaVersion` | `number` | Yes | Starts at `1` |

#### History architecture

Use a top-level collection instead of:

* An embedded status-history array
* A nested subcollection

Reasons:

* Prevents the parent order document from growing indefinitely.
* Supports direct pagination and timeline queries.
* Supports audit and reporting queries across branches.
* Makes each history event immutable.
* Keeps the current order document small.

#### Append-only rules

* History documents must be immutable after creation.
* Clients must not update an existing history event.
* Clients must not delete history events.
* A history record must be created whenever the order status changes.
* The history `status` must match the resulting order status.
* `changedAt` must use a server timestamp.
* `changedBy` must identify the authorized actor.
* Customers must not create history events.

#### Ownership and access rules

* `stitchingOrderId` must reference an existing stitching order.
* `boutiqueId`, `branchId`, and `customerId` must match the parent order.
* Customers may read only history belonging to their own stitching orders.
* Authorized admins may read history only within their allowed boutiques and branches.
* Only authorized admins or trusted backend logic may create history events.
* History documents must not contain measurement data.
* Do not duplicate complete stitching-order or design documents.

#### Query order

Customer and admin timelines should query:

```text
where stitchingOrderId == selectedOrderId
orderBy changedAt ascending
```

Use cursor pagination if the history becomes large.

#### Example

```json
{
  "id": "historyDocumentId",
  "stitchingOrderId": "stitchingOrderDocumentId",
  "boutiqueId": "boutiqueDocumentId",
  "branchId": "branchDocumentId",
  "customerId": "customerUuid",
  "status": "cutting",
  "note": "Fabric cutting started.",
  "changedAt": "Firestore Timestamp",
  "changedBy": "firebaseAdminUid",
  "schemaVersion": 1
}
```

The JSON example is illustrative only. Actual timestamps must use Firestore `Timestamp`.

### `notifications`

Stores customer-facing announcements and transactional notifications.

Supported use cases include:

- Boutique-wide announcements
- Branch-specific announcements
- Individual customer notifications
- Stitching status updates
- General promotional or informational messages

#### Document ID

Use a Firestore-generated ID.

The `id` field must match the Firestore document ID.

#### Fields

| Field | Firestore type | Required | Description |
|---|---|---:|---|
| `id` | `string` | Yes | Firestore document ID |
| `boutiqueId` | `string` | Yes | Owning boutique document ID |
| `branchId` | `string` | No | Optional branch target |
| `customerId` | `string` | No | Optional individual customer target |
| `type` | `string` | Yes | Notification category |
| `audience` | `string` | Yes | Target audience type |
| `title` | `string` | Yes | Notification title |
| `body` | `string` | Yes | Notification message |
| `imageUrl` | `string` | No | Optional notification image |
| `data` | `map` | No | Small navigation or contextual payload |
| `isActive` | `boolean` | Yes | Whether the notification is active |
| `createdAt` | `timestamp` | Yes | Server-generated creation timestamp |
| `expiresAt` | `timestamp` | No | Optional expiration timestamp |
| `createdBy` | `string` | Yes | Firebase UID of the creating admin or trusted backend |
| `schemaVersion` | `number` | Yes | Starts at `1` |

#### Allowed `audience` values

```text
boutique
branch
customer
```

#### Allowed `type` values

```text
announcement
stitchingStatus
recommendation
reminder
system
```

Use stable lower camel case strings.

#### Audience rules

##### `boutique`

* `boutiqueId` is required.
* `branchId` must be absent.
* `customerId` must be absent.
* The notification applies to eligible customers of the boutique.

##### `branch`

* `boutiqueId` is required.
* `branchId` is required.
* `customerId` must be absent.
* The branch must belong to the boutique.

##### `customer`

* `boutiqueId` is required.
* `customerId` is required.
* `branchId` may be present when the notification relates to a branch.
* The customer notification must not be visible to another customer.

#### `data` rules

The `data` map may contain only small, non-sensitive values used for navigation or context.

Example keys may include:

```text
stitchingOrderId
designId
sectionId
route
```

Rules:

* Do not store complete documents in `data`.
* Do not store authentication tokens.
* Do not store private measurement data.
* Do not use `data` fields for authorization.
* Canonical access must use explicit top-level IDs.

#### Visibility rules

A notification is eligible for display only when:

* `isActive` is `true`.
* `expiresAt` is absent or later than the current time.
* The authenticated customer matches the audience rules.
* The boutique and related branch are active where applicable.

#### Validation rules

* `title` must not be empty.
* `body` must not be empty.
* `expiresAt`, when present, must be later than `createdAt`.
* Only authorized admins or trusted backend logic may create notifications.
* Customers must not create, update, or delete notification documents.
* Do not store FCM device tokens in this collection.
* Do not store per-customer read state in the notification document.
* Do not maintain a large array of customer IDs.
* `createdAt` and `createdBy` must never change.
* Deactivation should use `isActive` rather than deleting referenced notifications.

#### Example

```json
{
  "id": "notificationDocumentId",
  "boutiqueId": "boutiqueDocumentId",
  "branchId": "branchDocumentId",
  "customerId": "customerUuid",
  "type": "stitchingStatus",
  "audience": "customer",
  "title": "Your outfit is ready",
  "body": "Your stitching order has passed quality check and is ready.",
  "imageUrl": null,
  "data": {
    "stitchingOrderId": "stitchingOrderDocumentId",
    "route": "stitchingOrderDetails"
  },
  "isActive": true,
  "createdAt": "Firestore Timestamp",
  "expiresAt": null,
  "createdBy": "firebaseAdminUid",
  "schemaVersion": 1
}
```

The JSON example is illustrative only. Actual timestamps must use Firestore `Timestamp`.

---

### `notificationReads`

Stores the read state between one customer and one notification.

This collection prevents duplication of complete notification documents.

#### Document ID

Use this deterministic document ID:

```text
customerId_notificationId
```

The document must also store `customerId` and `notificationId` explicitly.

Do not parse the document ID for authorization.

#### Fields

| Field | Firestore type | Required | Description |
| --- | --- | ---: | --- |
| `id` | `string` | Yes | Deterministic Firestore document ID |
| `customerId` | `string` | Yes | Owner customer ID |
| `notificationId` | `string` | Yes | Referenced notification ID |
| `readAt` | `timestamp` | Yes | Server-generated first-read timestamp |

#### Ownership rules

* Each document belongs to exactly one customer.
* Customers may read only their own notification-read documents.
* Customers may create only their own read-state documents.
* Customers must not create read state for notifications they cannot access.
* Admins must not use this collection as a customer activity feed unless explicitly authorized later.

#### Duplicate prevention

* `id` must equal `customerId_notificationId`.
* Only one read document may exist for each customer and notification pair.
* Marking a notification as read must be idempotent.
* `readAt` records the first read time and should not be overwritten repeatedly.

#### Validation rules

* `customerId` must reference an existing customer.
* `notificationId` must reference an accessible notification.
* `readAt` must use a server timestamp.
* Documents are immutable after creation.
* Do not store notification title, body, type, or image here.
* Do not add `isRead`; document existence already represents the read state.
* Do not add `updatedAt`, `createdBy`, `updatedBy`, `isActive`, or `schemaVersion`.

#### Example

```json
{
  "id": "customerUuid_notificationDocumentId",
  "customerId": "customerUuid",
  "notificationId": "notificationDocumentId",
  "readAt": "Firestore Timestamp"
}
```

The JSON example is illustrative only. Actual timestamps must use Firestore `Timestamp`.

---

### `deviceTokens`

Stores Firebase Cloud Messaging registration tokens for customer and admin devices.

A user may have multiple active devices.

#### Document ID

Use a deterministic secure hash derived from:

```text
appType + firebaseUid + token
```

Do not use the raw FCM token as the Firestore document ID.

The exact hashing implementation will be defined later.

#### Fields

| Field | Firestore type | Required | Description |
| --- | --- | ---: | --- |
| `id` | `string` | Yes | Deterministic secure hash document ID |
| `firebaseUid` | `string` | Yes | Firebase Authentication UID |
| `customerId` | `string` | No | Linked customer ID for customer-app tokens |
| `adminId` | `string` | No | Linked admin ID for admin-app tokens |
| `appType` | `string` | Yes | Application owning the token |
| `platform` | `string` | Yes | Device platform |
| `token` | `string` | Yes | Raw FCM registration token |
| `isActive` | `boolean` | Yes | Whether the token should receive notifications |
| `lastSeenAt` | `timestamp` | Yes | Last successful app usage or token refresh time |
| `createdAt` | `timestamp` | Yes | Server-generated creation timestamp |
| `updatedAt` | `timestamp` | Yes | Server-generated last update timestamp |
| `schemaVersion` | `number` | Yes | Starts at `1` |

#### Allowed `appType` values

```text
customer
admin
```

#### Allowed `platform` values

```text
android
```

Android is currently the only supported platform.

#### Identity rules

For `appType == customer`:

* `customerId` is required.
* `adminId` must be absent.
* `firebaseUid` must match the Firebase UID linked to that customer.

For `appType == admin`:

* `adminId` is required.
* `customerId` must be absent.
* `adminId` must equal `firebaseUid`.

#### Token lifecycle rules

* One user may have multiple active device tokens.
* One device token may rotate or become invalid.
* On token refresh, store the new token and deactivate or remove the obsolete record safely.
* `lastSeenAt` must update when the device remains active.
* Invalid tokens returned by FCM should be deactivated or deleted by trusted backend logic.
* Logout should deactivate the token for that app session where practical.
* Do not assume one Firebase UID has only one device.

#### Security rules

* Customers may register and manage only their own customer-app tokens.
* Admins may register and manage only their own admin-app tokens.
* Customers must never read another user’s device token.
* Normal clients should not query all token documents.
* Trusted backend logic may read active tokens for notification delivery.
* Tokens must never be included in analytics, logs, URLs, or notification payloads.

#### Validation rules

* `token` must not be empty.
* `firebaseUid` must match the authenticated user.
* `isActive` defaults to `true`.
* `createdAt` must never change.
* `updatedAt` and `lastSeenAt` must update when token metadata changes.
* Do not store notification history in this collection.
* Do not use device tokens as permanent user identifiers.
* Do not expose tokens through customer-facing queries.

#### Example: Customer device

```json
{
  "id": "secureTokenHash",
  "firebaseUid": "firebaseCustomerUid",
  "customerId": "customerUuid",
  "adminId": null,
  "appType": "customer",
  "platform": "android",
  "token": "fcmRegistrationToken",
  "isActive": true,
  "lastSeenAt": "Firestore Timestamp",
  "createdAt": "Firestore Timestamp",
  "updatedAt": "Firestore Timestamp",
  "schemaVersion": 1
}
```

#### Example: Admin device

```json
{
  "id": "secureTokenHash",
  "firebaseUid": "firebaseAdminUid",
  "customerId": null,
  "adminId": "firebaseAdminUid",
  "appType": "admin",
  "platform": "android",
  "token": "fcmRegistrationToken",
  "isActive": true,
  "lastSeenAt": "Firestore Timestamp",
  "createdAt": "Firestore Timestamp",
  "updatedAt": "Firestore Timestamp",
  "schemaVersion": 1
}
```

The JSON examples are illustrative only. Actual timestamps must use Firestore `Timestamp`.

---

## Expected Firestore Queries

Document the primary read patterns required by `KC-App` and `KC-Admin`.

### Required query conventions

- Use cursor pagination.
- Do not use offset pagination.
- Use stable secondary ordering by document ID when required.
- Default page size should be documented as `20`.
- Search queries must use normalized indexed fields.
- Do not design unsupported full-text Firestore search.
- Do not query large arrays.
- Do not depend on client-side filtering for authorization.
- Queries must match future Firestore security-rule constraints.
- Clearly mark queries that may require trusted backend logic.

### KC-App queries

#### 1. Active boutiques

- App: `KC-App`
- Purpose: Fetch active boutiques for customer browsing selection
- Collection: `boutiques`
- Filters:
  - `isActive == true`
- Order:
  - `name ASC`
  - `__name__ ASC`
- Pagination:
  - Cursor pagination
  - Page size: `20`
- Expected index:
  - `isActive ASC`
  - `name ASC`
  - `__name__ ASC`
- Notes:
  - Publicly accessible by customer apps without authentication.

#### 2. Active branches by boutique

- App: `KC-App`
- Purpose: Fetch active branches belonging to the selected boutique
- Collection: `branches`
- Filters:
  - `boutiqueId == selectedBoutiqueId`
  - `isActive == true`
- Order:
  - `name ASC`
  - `__name__ ASC`
- Pagination:
  - Cursor pagination
  - Page size: `20`
- Expected index:
  - `boutiqueId ASC`
  - `isActive ASC`
  - `name ASC`
  - `__name__ ASC`
- Notes:
  - Requires parent boutique to be active.

#### 3. Active categories by boutique

- App: `KC-App`
- Purpose: Fetch active design categories for browsing within a boutique
- Collection: `categories`
- Filters:
  - `boutiqueId == selectedBoutiqueId`
  - `isActive == true`
- Order:
  - `sortOrder ASC`
  - `__name__ ASC`
- Pagination:
  - Cursor pagination
  - Page size: `20`
- Expected index:
  - `boutiqueId ASC`
  - `isActive ASC`
  - `sortOrder ASC`
  - `__name__ ASC`
- Notes:
  - Categories are shared across branches within the same boutique.

#### 4. Active designs by boutique and category

- App: `KC-App`
- Purpose: List active designs within a specific category for a boutique
- Collection: `designs`
- Filters:
  - `boutiqueId == selectedBoutiqueId`
  - `categoryId == selectedCategoryId`
  - `isActive == true`
- Order:
  - `createdAt DESC`
  - `__name__ DESC`
- Pagination:
  - Cursor pagination
  - Page size: `20`
- Expected index:
  - `boutiqueId ASC`
  - `categoryId ASC`
  - `isActive ASC`
  - `createdAt DESC`
  - `__name__ DESC`
- Notes:
  - Branch availability must be resolved through `designAvailability`.

#### 5. Available designs by selected branch

- App: `KC-App`
- Purpose: Fetch design availability documents for a specific branch
- Collection: `designAvailability`
- Filters:
  - `boutiqueId == selectedBoutiqueId`
  - `branchId == selectedBranchId`
  - `status == "available"`
- Order:
  - `displayOrder ASC`
  - `__name__ ASC`
- Pagination:
  - Cursor pagination
  - Page size: `20`
- Expected index:
  - `boutiqueId ASC`
  - `branchId ASC`
  - `status ASC`
  - `displayOrder ASC`
  - `__name__ ASC`
- Notes:
  - Links branch availability to specific design document IDs.

#### 6. Sections visible for selected boutique and branch

- App: `KC-App`
- Purpose: Fetch curated home screen sections applicable to selected boutique/branch
- Collection: `sections`
- Filters:
  - `boutiqueId == selectedBoutiqueId`
  - `isActive == true`
- Order:
  - `sortOrder ASC`
  - `__name__ ASC`
- Pagination:
  - Cursor pagination
  - Page size: `20`
- Expected index:
  - `boutiqueId ASC`
  - `isActive ASC`
  - `sortOrder ASC`
  - `__name__ ASC`
- Notes:
  - Client checks `branchId` match (null or selected branch ID) and time window (`startAt`/`endAt`).

#### 7. Manual section items ordered by `sortOrder`

- App: `KC-App`
- Purpose: Fetch ordered design references belonging to a manual section
- Collection: `sectionItems`
- Filters:
  - `sectionId == selectedSectionId`
  - `isActive == true`
- Order:
  - `sortOrder ASC`
  - `__name__ ASC`
- Pagination:
  - Cursor pagination
  - Page size: `20`
- Expected index:
  - `sectionId ASC`
  - `isActive ASC`
  - `sortOrder ASC`
  - `__name__ ASC`
- Notes:
  - Used only when parent section has `type == manual`.

#### 8. Customer favourites ordered by `createdAt`

- App: `KC-App`
- Purpose: Fetch saved favourites for the authenticated customer
- Collection: `favourites`
- Filters:
  - `customerId == authenticatedCustomerId`
- Order:
  - `createdAt DESC`
  - `__name__ DESC`
- Pagination:
  - Cursor pagination
  - Page size: `20`
- Expected index:
  - `customerId ASC`
  - `createdAt DESC`
  - `__name__ DESC`
- Notes:
  - Restricted to authenticated customer matching `customerId`.

#### 9. Customer stitching orders ordered by `updatedAt`

- App: `KC-App`
- Purpose: Fetch active and historical stitching orders for the customer
- Collection: `stitchingOrders`
- Filters:
  - `customerId == authenticatedCustomerId`
- Order:
  - `updatedAt DESC`
  - `__name__ DESC`
- Pagination:
  - Cursor pagination
  - Page size: `20`
- Expected index:
  - `customerId ASC`
  - `updatedAt DESC`
  - `__name__ DESC`
- Notes:
  - Read-only for customers. Admins manage and update stitching orders.

#### 10. Stitching order history ordered by `changedAt`

- App: `KC-App`
- Purpose: Fetch append-only status timeline for a specific stitching order
- Collection: `stitchingOrderHistory`
- Filters:
  - `stitchingOrderId == selectedOrderId`
  - `customerId == authenticatedCustomerId`
- Order:
  - `changedAt ASC`
  - `__name__ ASC`
- Pagination:
  - Cursor pagination
  - Page size: `20`
- Expected index:
  - `stitchingOrderId ASC`
  - `customerId ASC`
  - `changedAt ASC`
  - `__name__ ASC`
- Notes:
  - Append-only status timeline for customer progress view.

#### 11. Customer-visible notifications ordered by `createdAt`

- App: `KC-App`
- Purpose: Fetch targeted notifications for the customer
- Collection: `notifications`
- Filters:
  - `boutiqueId == selectedBoutiqueId`
  - `isActive == true`
- Order:
  - `createdAt DESC`
  - `__name__ DESC`
- Pagination:
  - Cursor pagination
  - Page size: `20`
- Expected index:
  - `boutiqueId ASC`
  - `isActive ASC`
  - `createdAt DESC`
  - `__name__ DESC`
- Notes:
  - Filtered client-side or by query for audience (`boutique`, `branch`, or specific `customerId`).

#### 12. Customer notification read state

- App: `KC-App`
- Purpose: Fetch read markers to determine unread status on notifications
- Collection: `notificationReads`
- Filters:
  - `customerId == authenticatedCustomerId`
- Order:
  - `readAt DESC`
  - `__name__ DESC`
- Pagination:
  - Cursor pagination
  - Page size: `20`
- Expected index:
  - `customerId ASC`
  - `readAt DESC`
  - `__name__ DESC`
- Notes:
  - Document existence indicates notification has been read by customer.

#### 13. Current customer profile by Firebase UID

- App: `KC-App`
- Purpose: Fetch authenticated customer identity document by linked Firebase UID
- Collection: `customers`
- Filters:
  - `firebaseUid == authenticatedFirebaseUid`
  - `isActive == true`
- Order:
  - None (Direct lookup / single result query)
- Pagination:
  - N/A (Expects at most 1 document)
- Expected index:
  - `firebaseUid ASC`
  - `isActive ASC`
- Notes:
  - Maps `firebaseUid` to canonical `customerId`.

---

### KC-Admin queries

#### 1. Admin profile by Firebase UID

- App: `KC-Admin`
- Purpose: Fetch admin permissions and profile after Firebase Authentication
- Collection: `admins`
- Filters:
  - `firebaseUid == authenticatedAdminFirebaseUid`
  - `isActive == true`
- Order:
  - None (Direct lookup using document ID `admins/{firebaseUid}`)
- Pagination:
  - N/A (Single document lookup)
- Expected index:
  - N/A (Primary document ID lookup)
- Notes:
  - Document ID matches `firebaseUid`. Validates active admin authorization.

#### 2. Allowed boutiques and branches

- App: `KC-Admin`
- Purpose: Fetch boutique records assigned to the logged-in admin
- Collection: `boutiques`
- Filters:
  - `isActive == true`
- Order:
  - `name ASC`
  - `__name__ ASC`
- Pagination:
  - Cursor pagination
  - Page size: `20`
- Expected index:
  - `isActive ASC`
  - `name ASC`
  - `__name__ ASC`
- Notes:
  - For super admins, lists all active boutiques; for normal admins, filtered against `admin.boutiqueIds`.

#### 3. Categories by boutique

- App: `KC-Admin`
- Purpose: Manage categories for a specific boutique
- Collection: `categories`
- Filters:
  - `boutiqueId == selectedBoutiqueId`
- Order:
  - `sortOrder ASC`
  - `__name__ ASC`
- Pagination:
  - Cursor pagination
  - Page size: `20`
- Expected index:
  - `boutiqueId ASC`
  - `sortOrder ASC`
  - `__name__ ASC`
- Notes:
  - Includes both active and inactive categories for admin management.

#### 4. Designs by boutique

- App: `KC-Admin`
- Purpose: Manage complete design catalogue for a boutique
- Collection: `designs`
- Filters:
  - `boutiqueId == selectedBoutiqueId`
- Order:
  - `updatedAt DESC`
  - `__name__ DESC`
- Pagination:
  - Cursor pagination
  - Page size: `20`
- Expected index:
  - `boutiqueId ASC`
  - `updatedAt DESC`
  - `__name__ DESC`
- Notes:
  - Shows active and inactive designs across all categories.

#### 5. Design availability by branch

- App: `KC-Admin`
- Purpose: Manage branch availability for catalogue designs
- Collection: `designAvailability`
- Filters:
  - `boutiqueId == selectedBoutiqueId`
  - `branchId == selectedBranchId`
- Order:
  - `updatedAt DESC`
  - `__name__ DESC`
- Pagination:
  - Cursor pagination
  - Page size: `20`
- Expected index:
  - `boutiqueId ASC`
  - `branchId ASC`
  - `updatedAt DESC`
  - `__name__ DESC`
- Notes:
  - Allows toggling status between `available`, `unavailable`, and `hidden`.

#### 6. Sections by boutique and optional branch

- App: `KC-Admin`
- Purpose: Manage home screen sections for a boutique/branch
- Collection: `sections`
- Filters:
  - `boutiqueId == selectedBoutiqueId`
- Order:
  - `sortOrder ASC`
  - `__name__ ASC`
- Pagination:
  - Cursor pagination
  - Page size: `20`
- Expected index:
  - `boutiqueId ASC`
  - `sortOrder ASC`
  - `__name__ ASC`
- Notes:
  - Admin view includes inactive and scheduled sections.

#### 7. Section items by section

- App: `KC-Admin`
- Purpose: Manage items inside a manual section
- Collection: `sectionItems`
- Filters:
  - `sectionId == selectedSectionId`
- Order:
  - `sortOrder ASC`
  - `__name__ ASC`
- Pagination:
  - Cursor pagination
  - Page size: `20`
- Expected index:
  - `sectionId ASC`
  - `sortOrder ASC`
  - `__name__ ASC`
- Notes:
  - Used to reorder or add/remove design items.

#### 8. Customers by boutique or branch

- App: `KC-Admin`
- Purpose: List customers associated with a boutique or branch
- Collection: `customers`
- Filters:
  - `preferredBoutiqueId == selectedBoutiqueId`
- Order:
  - `createdAt DESC`
  - `__name__ DESC`
- Pagination:
  - Cursor pagination
  - Page size: `20`
- Expected index:
  - `preferredBoutiqueId ASC`
  - `createdAt DESC`
  - `__name__ DESC`
- Notes:
  - Admin browsing of customer records.

#### 9. Customer search by normalized phone or email

- App: `KC-Admin`
- Purpose: Search customers by exact phone number or email address
- Collection: `customers`
- Filters:
  - `phone == normalizedPhone` (or `email == normalizedEmail`)
- Order:
  - `createdAt DESC`
  - `__name__ DESC`
- Pagination:
  - Cursor pagination
  - Page size: `20`
- Expected index:
  - `phone ASC`
  - `createdAt DESC`
  - `__name__ DESC`
- Notes:
  - Uses exact normalized match for search; full-text search is not supported natively.

#### 10. Stitching orders by branch and status

- App: `KC-Admin`
- Purpose: Filter stitching orders by branch and status stage
- Collection: `stitchingOrders`
- Filters:
  - `boutiqueId == selectedBoutiqueId`
  - `branchId == selectedBranchId`
  - `status == selectedStatus`
- Order:
  - `updatedAt DESC`
  - `__name__ DESC`
- Pagination:
  - Cursor pagination
  - Page size: `20`
- Expected index:
  - `boutiqueId ASC`
  - `branchId ASC`
  - `status ASC`
  - `updatedAt DESC`
  - `__name__ DESC`
- Notes:
  - Core administrative workflow query for tracking garment processing.

#### 11. Stitching orders by customer

- App: `KC-Admin`
- Purpose: View stitching order history for a specific customer
- Collection: `stitchingOrders`
- Filters:
  - `boutiqueId == selectedBoutiqueId`
  - `customerId == targetCustomerId`
- Order:
  - `createdAt DESC`
  - `__name__ DESC`
- Pagination:
  - Cursor pagination
  - Page size: `20`
- Expected index:
  - `boutiqueId ASC`
  - `customerId ASC`
  - `createdAt DESC`
  - `__name__ DESC`
- Notes:
  - Allows admins to view customer history across branches.

#### 12. Stitching order history by order

- App: `KC-Admin`
- Purpose: Audit status timeline changes for an order
- Collection: `stitchingOrderHistory`
- Filters:
  - `stitchingOrderId == selectedOrderId`
- Order:
  - `changedAt ASC`
  - `__name__ ASC`
- Pagination:
  - Cursor pagination
  - Page size: `20`
- Expected index:
  - `stitchingOrderId ASC`
  - `changedAt ASC`
  - `__name__ ASC`
- Notes:
  - Audit trail of status updates made by admins or system processes.

#### 13. Notifications by boutique, branch, or customer

- App: `KC-Admin`
- Purpose: Manage and audit sent notifications
- Collection: `notifications`
- Filters:
  - `boutiqueId == selectedBoutiqueId`
- Order:
  - `createdAt DESC`
  - `__name__ DESC`
- Pagination:
  - Cursor pagination
  - Page size: `20`
- Expected index:
  - `boutiqueId ASC`
  - `createdAt DESC`
  - `__name__ DESC`
- Notes:
  - View sent announcements and customer notifications.

#### 14. Active device tokens by user and app type

- App: `KC-Admin`
- Purpose: Retrieve active device tokens for sending push notifications via Cloud Messaging / trusted backend
- Collection: `deviceTokens`
- Filters:
  - `firebaseUid == targetFirebaseUid`
  - `appType == targetAppType`
  - `isActive == true`
- Order:
  - `lastSeenAt DESC`
  - `__name__ DESC`
- Pagination:
  - Cursor pagination
  - Page size: `20`
- Expected index:
  - `firebaseUid ASC`
  - `appType ASC`
  - `isActive ASC`
  - `lastSeenAt DESC`
  - `__name__ DESC`
- Notes:
  - Executed by trusted backend or admin messaging tools to target FCM push notifications.
