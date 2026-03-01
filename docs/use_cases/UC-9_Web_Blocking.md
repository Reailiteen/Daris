# UC-9: Web Blocking

**Primary Actor:** User
**Scope:** Web (browser extension + server rules)

## Goal
Block access to specified domains when user is attempting to browse the web.

## Trigger
User defines or modifies a list of domains to block in the app or via a browser extension.

## Preconditions
- User has installed the companion browser extension.

## Postconditions (Success)
- Requests to blocked domains are intercepted and denied.

## Main Flow
1. User selects domains to block in either mobile/desktop app or directly within the extension UI.
2. System stores the list under `blocked_domains`.
3. The browser extension monitors navigation events and prevents loading of any matching domain by showing a block page or redirecting.
4. Optionally, server-side rules may also enforce blocking (e.g., via network proxy).

## Data Involved
- `blocked_domains`

## Notes
- Implementation should keep rules synchronized between app and extension.
