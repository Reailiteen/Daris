# UC-2: Login

**Primary Actor:** User
**Scope:** Both (app & backend)

## Goal
Authenticate a returning user and restore their session.

## Trigger
User opens the app and selects **Login** or attempts to access a protected resource.

## Preconditions
- User has an existing account in the system.

## Postconditions (Success)
- User is authenticated.
- Session token is issued and stored client-side (e.g. secure storage).
- User is redirected to the dashboard.

## Main Flow
1. The user enters their email and password.
2. System validates the credentials against `auth.users`.
3. If credentials are valid and the email is verified, the system issues a session or JWT token.
4. Client stores the token and navigates to the dashboard.

## Alternative Flows
- **Invalid credentials** – system rejects the login attempt and displays an error message.
- **Unverified email** – system informs the user that they need to verify their email before logging in; may resend verification.

## Data Involved
- `auth.users` (for credential lookup)

## Notes
- Session management may involve refresh tokens depending on architecture.
