# UC-10: Manage Blocking Configuration

**Primary Actor:** User
**Scope:** Both (app & browser extension)

## Goal
Provide a unified interface for creating, reading, updating, and deleting blocking rules for both mobile apps and web domains.

## Trigger
User accesses the blocking settings screen within the application.

## Preconditions
- User is authenticated.
- Underlying blocking data stores (`blocked_apps`, `blocked_domains`) are available.

## Postconditions (Success)
- Blocking configurations reflect the user's choices and are applied on the device or in the browser.

## Main Flow
1. System fetches existing blocking rules for apps and domains.
2. User may add a new rule:
   - Choose between app or domain.
   - Specify name, schedule (if any), and other preferences.
3. User may edit an existing rule or delete it.
4. Changes are saved to the appropriate table and propagated to enforcement modules (native service or extension).
5. UI shows confirmation of updates.

## Alternative Flows
- Changes may fail due to permission issues (e.g., lack of OS permissions). The system should inform the user.

## Data Involved
- `blocked_apps`
- `blocked_domains`

## Notes
- This use case wraps UC-8 and UC-9 to provide a single point of configuration in the app.
