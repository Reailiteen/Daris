# UC-6: Personal Performance Dashboard

**Primary Actor:** User
**Scope:** Both

## Goal
Provide a read-only view of the user's aggregated progress, balances, and rankings.

## Trigger
User navigates to the dashboard from the main menu.

## Preconditions
- User is authenticated.
- Relevant data (logs, screen time, etc.) exist.

## Postconditions (Success)
- Dashboard displays up-to-date information.

## Main Flow
1. System gathers data from multiple sources:
   - Weekly progress (activity logs aggregated).
   - Screen-time balance.
   - Streaks information.
   - Rewards earned.
   - Leaderboard rank (if applicable).
2. Data may be obtained from raw tables or pre-calculated materialized views depending on performance.
3. The dashboard renders charts, numbers, and visual indicators to the user.

## Data Involved
- Various tables and materialized views; for MVP, direct queries to raw tables are acceptable.

## Notes
- No write operations; purely display.
