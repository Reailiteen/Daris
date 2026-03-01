# UC-1: Register Account (Verification + Onboarding)

**Primary Actor:** User
**Scope:** Both (app & backend)

## Goal
Create a verified account and capture a baseline configuration for weekly screen-time planning.

## Trigger
User opens the app and selects **Create Account**.

## Preconditions
- User is not authenticated.

## Postconditions (Success)
- User account exists in authentication system.
- Email is verified.
- Initial weekly allocation and preferences are stored in the database.

## Main Success Flow
1. User is presented with a registration form requesting email and password.
2. System validates the format of the email and the strength/constraints of the password.
3. On successful validation, the system creates a new record in `auth.users` (or equivalent).
4. A verification email is sent to the provided address.
5. User clicks the link in the email to verify.
6. The backend marks the user as verified and creates a corresponding `profiles` record.
7. System begins onboarding flow (wizard):
   - Ask for weekly starting screen-time allocation.
   - Ask for activity focus (Workout / Study / Mixed).
   - Ask for blocking preferences (basic categories).
8. As the user answers steps, the system persists configuration to `user_settings` and related tables.
9. Onboarding completes and the user is redirected to the dashboard with full access.

## Alternative Flows
- **A1: Email not verified** – If the user logs in before verifying, they are granted limited access (e.g., cannot create plans) and shown reminder to verify.
- **A2: User exits onboarding** – Progress is saved as an incomplete profile; user may resume later but cannot access dashboard until configuration is finalized.

## Business Rules
- Onboarding is mandatory before accessing the dashboard.
- Defaults are applied if the user skips optional onboarding steps.

## Data Involved
- `auth.users`
- `profiles`
- `user_settings`

## MVP Notes
- No social login options.
- No parental account features yet.
