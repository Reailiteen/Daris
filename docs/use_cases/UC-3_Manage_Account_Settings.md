# UC-3: Manage Account Settings (CRUD)

**Primary Actor:** User
**Scope:** Both

## Goal
Allow the user to view and modify their identity information and security settings.

## Trigger
User navigates to **Account Settings** in the app.

## Preconditions
- User is authenticated.

## Postconditions (Success)
- Changes to profile or security information are saved.
- Soft-deletion requests are recorded.

## Main Flow
1. System retrieves the current profile details (`profiles`) and settings (`user_settings`) for display.
2. User views their information.
3. User may update personal details such as name or preferences.
4. User may change password by providing current password and new password.
5. User may request account deletion; confirm the action.
6. System applies updates to the database.
7. For deletion, the system marks the account as soft-deleted but retains data for recovery.

## Business Rules
- Password changes require re-authentication or current password confirmation.
- Account deletion is a soft-delete; user data is retained but flagged.

## Data Involved
- `profiles`
- `user_settings`

## Notes
- Additional security features (2FA, email updates) may be added later.
