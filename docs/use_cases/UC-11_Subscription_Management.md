# UC-11: Subscription Management

**Primary Actor:** User
**Scope:** Both (frontend & backend)

## Goal
Enable users to view and manage their subscription status, including payments and plan upgrades.

## Trigger
User navigates to the **Subscription** or **Billing** section of the app.

## Preconditions
- User is authenticated.
- Payment integration (Stripe) is configured.

## Postconditions (Success)
- User’s subscription status is updated.
- Billing records are stored.

## Main Flow
1. The system displays the current subscription tier and renewal date.
2. User may choose to upgrade, downgrade, or cancel the subscription.
3. When performing a change, the system interacts with Stripe to create/modify the subscription.
4. Backend records events in `billing_events` and updates `subscriptions` table.
5. If VIP is enabled, the user gains access to additional features like AI assistance and higher caps.

## Business Rules
- VIP subscription unlocks premium functionalities.
- Billing events are logged for audit and customer support.

## Data Involved
- `subscriptions`
- `billing_events`

## Notes
- Implement webhooks for Stripe to keep server state in sync.
