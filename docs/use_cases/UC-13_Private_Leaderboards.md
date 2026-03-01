# UC-13: Private Leaderboards

**Primary Actor:** User
**Scope:** Both

## Goal
Allow users to compare their performance with a selected group of friends in an opt-in, privacy-respecting way.

## Trigger
User opts into a private leaderboard from the social or dashboard screens.

## Preconditions
- User is authenticated.
- There exist friendship relationships between users.

## Postconditions (Success)
- A leaderboard snapshot is generated and visible only to opted-in participants.

## Main Flow
1. User navigates to the leaderboards section and chooses the private option.
2. System checks the user’s friendship connections (`friendships`).
3. User selects which friends to include (could default to all connected friends).
4. The system computes rankings based on recent performance metrics and stores a `leaderboard_snapshot`.
5. Participants can view the snapshot; only participants see it.

## Business Rules
- Leaderboards are strictly opt-in and not visible to non-participants.

## Data Involved
- `friendships`
- `leaderboard_snapshots`

## Notes
- Snapshots may be generated periodically or on-demand.
