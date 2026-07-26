# Product Rules - Kapada Creation Admin App

## Product Identity

- **Brand**: Kapada Creation
- **Tagline**: We Care What You Wear.

## Product Purpose

Kapada Creation Admin App exists to enable boutique operators to:
- Manage designs and design availability
- Manage categories and home sections
- Manage customer profiles and contacts
- Create and manage stitching orders
- Send push notifications to customers
- View business analytics
- Manage boutique and branch information

## Scope Exclusions

The Admin App must **NOT** contain:
- Complex staff hierarchy roles or sub-operator permission engines
- Manager roles or enterprise access control matrices
- Accounting / ledger / bookkeeping systems
- E-commerce order processing / shipping management

## Multi-Boutique and Branch Rules

- Backend models and data architecture must remain ready for multiple boutiques.
- A boutique may have multiple branches.
- Important records must contain `boutiqueId`.
- Branch-owned records must contain `branchId`.
- Designs are separate per branch and are never automatically shared between branches. The same design in another branch is a separate record.
- Admin manages branch context from the profile or app bar.

## Data Terminology

Use domain terms:
- Design
- Collection
- Section
- Stitching
- Boutique
- Branch

Avoid generic e-commerce terms:
- Product cart
- Buy now
- Checkout
- Shipping status

## Stitching Module Rules

- Admin creates stitching records linked using `customerId`.
- Admin updates stitching progress status (e.g. Received, Pattern Cut, Stitching, Trial Ready, Completed).
- Admin status updates can trigger customer notifications.

## Availability Rules

- Admin manages design availability per branch (Available vs Unavailable).
- Out-of-stock designs are hidden from normal customer browsing.
