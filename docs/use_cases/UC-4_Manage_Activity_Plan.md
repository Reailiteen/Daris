# UC-4: Manage Activity Plan (Workout / Study)

**Primary Actor:** User
**Scope:** Both

## Goal
Define and maintain planned activities that can earn screen-time when completed.

## Trigger
User selects the option to create or edit an activity plan from the dashboard or menu.

## Preconditions
- User is authenticated.

## Postconditions (Success)
- A new activity plan is created, or an existing plan is updated or deleted.

## Main Flow
1. User chooses to create a new plan and selects the type (`workout` or `study`).
2. System prompts for schedule details (days, times, duration).
3. Depending on the type, additional metadata is required:
   - Workout: specify activity type (e.g., running, yoga).
   - Study: specify subject or topic.
4. (VIP) The system may offer AI-assisted generation of a plan based on goals.
5. User saves the plan.
6. Plans are listed in the UI; user can select one to edit or delete.

## Business Rules
- Study plans require subject metadata.
- Workout plans require activity metadata.

## Data Involved
- `activity_plans`

## MVP Notes
- No calendar synchronization.
- No adaptive difficulty or dynamic adjustments yet.
