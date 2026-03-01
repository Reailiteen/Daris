# UC-7: Screen Lock & Emergency Break

**Primary Actor:** User
**Scope:** Both

## Goal
Enforce scarcity of screen-time while providing an emergency override mechanism to prevent frustration.

## Trigger
User's screen-time balance reaches zero or the user manually requests an emergency break.

## Preconditions
- User is authenticated.
- Screen-time balance is tracked.

## Postconditions (Success)
- Lock state is activated when time is zero.
- Emergency break may grant limited override and is recorded.

## Main Flow
1. The system monitors the user's screen-time balance.
2. When the balance hits zero, a lock interface appears, preventing normal access.
3. User may attempt to request an emergency break from the lock screen.
4. If allowed (not exceeding rate limits), the system grants a short temporary allowance and records it under `emergency_overrides`.
5. Any override reduces future allowances or affects other business logic.
6. All lock and override events are logged for analytics.

## Business Rules
- Emergency breaks are rate-limited (e.g., once per day).
- Overrides reduce future allowance or count against a quota.

## Data Involved
- `screen_time_state`
- `emergency_overrides`

## Notes
- UX should clearly indicate remaining time and break history.
