# UC-5: Log Activity & Earn Screen-Time

**Primary Actor:** User
**Scope:** Both

## Goal
Convert real-world effort into digital screen-time permission.

## Trigger
User indicates that they have completed a planned activity (via the app).

## Preconditions
- User is authenticated.
- There exists at least one activity plan or manual entry available.

## Postconditions (Success)
- Logged activity is recorded.
- Screen-time balance is increased accordingly.

## Main Flow
1. User selects the relevant activity plan or enters details manually.
2. System validates the submission:
   - For workouts (Nashad): may be manual with optional trust level.
   - For studies (Doris): may require a mini-assessment or confirmation questions.
3. If validation passes, the system calculates awarded screen-time based on plan rules.
4. Update `activity_logs` with the entry and append a corresponding record to `screen_time_ledger`.
5. Display updated balance to the user.

## Alternative Flows
- **Validation fails** – system rejects the log and informs the user; no reward is granted.

## Business Rules
- Only one log per activity per specified time window (e.g., once per day per plan).

## Data Involved
- `activity_logs`
- `screen_time_ledger`
