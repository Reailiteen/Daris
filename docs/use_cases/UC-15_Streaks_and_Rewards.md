# UC-15: Streaks & Rewards

**Primary Actor:** User
**Scope:** Both

## Goal
Track continuous engagement and provide rewards to reinforce behavior.

## Trigger
User completes daily activities and the system evaluates streaks.

## Preconditions
- User has activity logs.

## Postconditions (Success)
- Streak counters are updated.
- Rewards are issued or updated.

## Main Flow
1. After each valid activity log, the system checks whether it continues the user’s current streak (no missed days).
2. If the streak continues, increment the streak count; if a day is missed, reset the streak.
3. At certain milestones (e.g., 7 days, 30 days), the system awards rewards which may be cosmetic.
4. Record rewards in `user_rewards` and update the UI to show earned items.

## Business Rules
- Missing a day resets the streak count to zero.
- Rewards are primarily cosmetic for MVP and do not affect core functionality.

## Data Involved
- `streaks`
- `rewards`
- `user_rewards`

## Notes
- Future enhancements may include streak protection or redemption systems.
