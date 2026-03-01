# UC-12: Notifications

**Primary Actor:** System (secondary user)
**Scope:** Both

## Goal
Send timely reminders and alerts to the user.

## Trigger
Various events such as:
- Upcoming scheduled activity.
- Screen-time lock events.
- Reward or streak milestones.

## Preconditions
- User has granted notification permissions.

## Postconditions (Success)
- Notifications are delivered and, where appropriate, logged for analytics.

## Main Flow
1. System detects a trigger event (e.g., activity start time approaching).
2. A notification payload is composed based on templates and user preferences.
3. Push notification services (APNs, FCM) send the message to the device.
4. Clicking a notification navigates the user to the relevant screen.

## Data Involved
- `notifications` (for history and preferences)

## Notes
- May require scheduling background tasks to generate reminders.
