# UC-8: Mobile App Blocking

**Primary Actor:** User
**Scope:** Mobile platforms

## Goal
Prevent access to specific applications on the device as configured by the user.

## Trigger
User updates their blocking configuration to include apps or a scheduled block.

## Preconditions
- User is on a supported mobile platform.
- App has necessary permissions (e.g., usage access on Android, Screen Time API on iOS if possible).

## Postconditions (Success)
- Specified applications are blocked according to rules.

## Main Flow
1. User navigates to blocking settings and selects mobile apps to block.
2. System stores the list under `blocked_apps` with any schedule preferences.
3. A background service or OS integration monitors active applications.
4. When a blocked app is launched during a blocked period, the system intervenes (e.g., overlays a lock screen, kills the app if permitted).

## Business Rules
- Implementation is OS-dependent and kept simple for MVP.

## Data Involved
- `blocked_apps`

## Notes
- Full enforcement may vary; might rely on external native modules. Plan for future expansions.
