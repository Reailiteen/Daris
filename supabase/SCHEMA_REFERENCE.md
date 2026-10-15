# Daris — Database Schema Reference

All tables live in the `public` schema on Supabase (PostgreSQL).  
`auth.users` is managed by Supabase Auth and is never touched directly.

---

## Entity Map by Use Case

| Use Case | Tables |
|---|---|
| UC-1 Register | `profiles`, `user_settings` |
| UC-2 Login | `auth.users` (Supabase Auth) |
| UC-3 Account Settings | `profiles`, `user_settings` |
| UC-4 Activity Plans | `activity_plans`, `sports` |
| UC-5 Log Activity / Earn Screen-Time | `activity_logs`, `screen_time_ledger`, `screen_time_state` |
| UC-6 Dashboard | `focus_sessions`, `screen_budgets`, `focus_cycles`, `streaks` |
| UC-7 Screen Lock / Emergency Break | `screen_time_state`, `emergency_overrides` |
| UC-8 Mobile App Blocking | `blocked_apps` |
| UC-9 Web Blocking | `blocked_domains` |
| UC-10 Blocking Configuration | `blocked_apps`, `blocked_domains` |
| UC-11 Subscriptions | `subscriptions`, `billing_events` |
| UC-12 Notifications | `notifications` |
| UC-13 Leaderboards | `leaderboard_snapshots`, `friendships` |
| UC-14 Friends | `friendships` |
| UC-15 Streaks & Rewards | `streaks`, `rewards`, `user_rewards` |

---

## Table Descriptions

### `profiles`
One row per authenticated user. Created automatically via trigger on `auth.users` insert.  
Holds display name, avatar, onboarding completion flag, and soft-delete timestamp.

### `user_settings`
Onboarding preferences: weekly screen-time allocation, activity focus type, notification preferences, and blocking category preferences.

### `sports`
Read-only lookup table of sport/activity types (e.g. Running, Yoga, Cycling) used to tag workout plans and logs.

### `activity_plans`
User-defined workout or study plans with schedule, type-specific metadata, and the screen-time reward for completion.  
- Workout plans require `sport_id` + `intensity_level`.  
- Study plans require `subject` + `topic`.

### `activity_logs`
Records each completed activity. Enforces one log per plan per calendar day via a unique constraint.  
Contains validation status and the final `awarded_minutes` credited to the user.

### `screen_time_ledger`
Append-only debit/credit log. Every earned reward, spent minute, or override writes a row here. The balance is always derivable from `SUM(delta_minutes)`.

### `screen_time_state`
Denormalised current balance and lock state per user. Updated via triggers or background jobs for fast reads.

### `focus_sessions`
Pomodoro-style focus timer sessions. Tracks duration, breaks, completion status, and how many apps were blocked during the session.

### `focus_cycles`
Weekly wrapper grouping a user's activity within a calendar week. Used to calculate weekly budgets.

### `screen_budgets`
The actual weekly screen-time budget per cycle: base allowance, earned credits, remaining balance, and optional cap.

### `emergency_overrides`
Records each emergency break granted when screen-time hits zero. Stores the granted minutes, the future-allowance penalty, and expiry time.

### `blocked_apps`
Per-user list of mobile apps (by platform bundle ID) to block, with optional daily schedule.

### `blocked_domains`
Per-user list of web domains to block, with optional daily schedule and category tag.

### `subscriptions`
Stripe-linked subscription record per user. Holds tier (`free`/`vip`), status, and billing period dates.

### `billing_events`
Webhook event log from Stripe. Each event (invoice paid, subscription cancelled, etc.) is stored with its full payload for audit purposes.

### `notifications`
In-app notification history. Stores type, title, body, deep-link target, and delivery/read state.

### `friendships`
Social graph edges. Each row represents a directional friend request with status (`pending`, `accepted`, `declined`, `blocked`).

### `leaderboard_snapshots`
Point-in-time leaderboard snapshots scoped to a group of opted-in participants. Rankings are stored as a JSONB array.

### `streaks`
Rolling daily-activity streak per user. Tracks current streak, all-time longest streak, and the date of last logged activity.

### `rewards`
Catalogue of cosmetic rewards that can be unlocked at streak milestones.

### `user_rewards`
Junction table recording which rewards a user has earned and when.

---

## Automatic Bootstrapping

When Supabase Auth creates a new user, the `on_auth_user_created` trigger fires `handle_new_user()` which inserts default rows into:

- `profiles`
- `user_settings`
- `screen_time_state`
- `streaks`
- `subscriptions` (free tier)

This ensures every user has a complete, valid record set immediately after sign-up without any extra client calls.

---

## Row-Level Security Summary

Every table has RLS enabled.  
- Most tables use `user_id = auth.uid()` — users see and modify only their own data.  
- `friendships` is visible to both the requester and the addressee.  
- `leaderboard_snapshots` is visible to the owner and all `participant_ids`.  
- `sports` and `rewards` are public read-only (no authentication required).

---

## Applying the Schema

In the Supabase dashboard → **SQL Editor**, paste and run `supabase/schema.sql`.  
Or via the CLI:

```bash
supabase db reset          # local dev
# or
supabase db push           # push to hosted project
```
