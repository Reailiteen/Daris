-- =============================================================================
-- Daris Database Schema
-- Supabase / PostgreSQL
-- Covers: UC-1 through UC-15
-- =============================================================================

-- Enable necessary extensions
create extension if not exists "uuid-ossp";
create extension if not exists "pgcrypto";

-- =============================================================================
-- ENUMS
-- =============================================================================

create type activity_type      as enum ('workout', 'study', 'mixed');
create type validation_status  as enum ('pending', 'approved', 'rejected');
create type plan_status        as enum ('active', 'paused', 'completed', 'deleted');
create type session_status     as enum ('active', 'completed', 'cancelled');
create type friendship_status  as enum ('pending', 'accepted', 'declined', 'blocked');
create type subscription_tier  as enum ('free', 'vip');
create type sub_status         as enum ('active', 'cancelled', 'past_due', 'trialing');
create type notification_type  as enum ('reminder', 'lock_event', 'reward', 'streak', 'friend_request', 'system');
create type override_reason    as enum ('emergency', 'manual');
create type blocking_platform  as enum ('ios', 'android', 'web', 'desktop');

-- =============================================================================
-- UC-1 / UC-2 / UC-3 — AUTH, PROFILES & SETTINGS
-- =============================================================================

-- profiles: one row per auth.users record, created after email verification
create table profiles (
  id                  uuid primary key references auth.users(id) on delete cascade,
  display_name        text,
  avatar_url          text,
  onboarding_complete boolean    not null default false,
  deleted_at          timestamptz,                         -- soft-delete (UC-3)
  created_at          timestamptz not null default now(),
  updated_at          timestamptz not null default now()
);

-- user_settings: preferences captured during onboarding (UC-1) and editable later (UC-3)
create table user_settings (
  id                        uuid primary key default gen_random_uuid(),
  user_id                   uuid not null references profiles(id) on delete cascade,
  weekly_screen_time_minutes integer  not null default 120,   -- base weekly allocation
  activity_focus            activity_type not null default 'mixed',
  notifications_enabled     boolean  not null default true,
  focus_reminders_enabled   boolean  not null default true,
  blocking_categories       text[]   not null default '{}',   -- e.g. ['social','gaming']
  created_at                timestamptz not null default now(),
  updated_at                timestamptz not null default now(),
  unique (user_id)
);

-- =============================================================================
-- UC-4 — ACTIVITY PLANS
-- =============================================================================

-- sports lookup table (used by workout plans)
create table sports (
  id          uuid primary key default gen_random_uuid(),
  name        text not null unique,
  category    text not null,                               -- e.g. 'cardio', 'strength'
  created_at  timestamptz not null default now()
);

-- activity_plans: scheduled workout or study plans
create table activity_plans (
  id              uuid primary key default gen_random_uuid(),
  user_id         uuid not null references profiles(id) on delete cascade,
  type            activity_type not null,
  title           text not null,
  description     text,
  status          plan_status not null default 'active',
  -- schedule
  scheduled_days  integer[] not null default '{}',         -- 0=Sun … 6=Sat
  start_time      time,
  duration_minutes integer not null default 30,
  -- workout-specific (UC-4 business rule)
  sport_id        uuid references sports(id),
  intensity_level text,                                    -- 'low','medium','high'
  -- study-specific (UC-4 business rule)
  subject         text,
  topic           text,
  -- screen-time reward for completing this plan
  reward_minutes  integer not null default 15,
  -- VIP AI generation flag
  ai_generated    boolean not null default false,
  created_at      timestamptz not null default now(),
  updated_at      timestamptz not null default now()
);

-- =============================================================================
-- UC-5 — ACTIVITY LOGS & SCREEN-TIME LEDGER
-- =============================================================================

-- activity_logs: one entry per logged completion
create table activity_logs (
  id                uuid primary key default gen_random_uuid(),
  user_id           uuid not null references profiles(id) on delete cascade,
  plan_id           uuid references activity_plans(id) on delete set null,
  type              activity_type not null,
  logged_at         timestamptz not null default now(),
  duration_minutes  integer not null,
  -- workout validation
  sport_id          uuid references sports(id),
  intensity_value   numeric(4,2),
  source            text not null default 'manual',        -- 'manual','healthkit','gfit'
  validation_status validation_status not null default 'pending',
  -- study validation
  subject           text,
  assessment_score  numeric(5,2),                          -- mini-assessment result
  -- reward result
  awarded_minutes   integer not null default 0,
  notes             text,
  created_at        timestamptz not null default now()
  -- UC-5 business rule enforced via unique index below
);

-- screen_time_ledger: append-only credit/debit log
create table screen_time_ledger (
  id            uuid primary key default gen_random_uuid(),
  user_id       uuid not null references profiles(id) on delete cascade,
  delta_minutes integer not null,                          -- positive = earned, negative = used
  reason        text not null,                             -- 'activity_reward','session_used','override','admin'
  reference_id  uuid,                                      -- FK to activity_log, focus_session, etc.
  created_at    timestamptz not null default now()
);

-- screen_time_state: current running balance per user (derived, kept in sync via triggers)
create table screen_time_state (
  user_id           uuid primary key references profiles(id) on delete cascade,
  balance_minutes   integer not null default 0,
  is_locked         boolean not null default false,
  lock_triggered_at timestamptz,
  updated_at        timestamptz not null default now()
);

-- =============================================================================
-- UC-6 — FOCUS / POMODORO SESSIONS (dashboard data)
-- =============================================================================

create table focus_sessions (
  id                     uuid primary key default gen_random_uuid(),
  user_id                uuid not null references profiles(id) on delete cascade,
  status                 session_status not null default 'active',
  duration_minutes       integer not null,
  break_interval_minutes integer not null default 0,
  break_duration_minutes integer not null default 0,
  started_at             timestamptz not null default now(),
  ended_at               timestamptz,
  completed_successfully boolean not null default false,
  blocked_apps_count     integer not null default 0,
  notes                  text,
  created_at             timestamptz not null default now()
);

-- =============================================================================
-- UC-7 — EMERGENCY OVERRIDES
-- =============================================================================

create table emergency_overrides (
  id              uuid primary key default gen_random_uuid(),
  user_id         uuid not null references profiles(id) on delete cascade,
  reason          override_reason not null default 'emergency',
  granted_minutes integer not null default 15,
  deducted_future_minutes integer not null default 15,     -- future allowance penalty
  requested_at    timestamptz not null default now(),
  expires_at      timestamptz not null
);

-- =============================================================================
-- UC-8 — BLOCKED APPS (mobile)
-- =============================================================================

create table blocked_apps (
  id           uuid primary key default gen_random_uuid(),
  user_id      uuid not null references profiles(id) on delete cascade,
  platform     blocking_platform not null,
  bundle_id    text not null,                              -- iOS bundle / Android package
  display_name text not null,
  icon_url     text,
  is_enabled   boolean not null default true,
  schedule_days integer[] not null default '{0,1,2,3,4,5,6}',
  schedule_start time,
  schedule_end   time,
  created_at   timestamptz not null default now(),
  updated_at   timestamptz not null default now(),
  unique (user_id, platform, bundle_id)
);

-- =============================================================================
-- UC-9 — BLOCKED DOMAINS (web)
-- =============================================================================

create table blocked_domains (
  id           uuid primary key default gen_random_uuid(),
  user_id      uuid not null references profiles(id) on delete cascade,
  domain       text not null,
  display_name text not null,
  icon_name    text not null default 'globe',
  category     text not null default 'other',
  is_enabled   boolean not null default true,
  schedule_days integer[] not null default '{0,1,2,3,4,5,6}',
  schedule_start time,
  schedule_end   time,
  created_at   timestamptz not null default now(),
  updated_at   timestamptz not null default now(),
  unique (user_id, domain)
);

-- =============================================================================
-- UC-11 — SUBSCRIPTIONS & BILLING
-- =============================================================================

create table subscriptions (
  id                  uuid primary key default gen_random_uuid(),
  user_id             uuid not null references profiles(id) on delete cascade,
  tier                subscription_tier not null default 'free',
  status              sub_status not null default 'active',
  stripe_customer_id  text unique,
  stripe_sub_id       text unique,
  current_period_start timestamptz,
  current_period_end   timestamptz,
  cancelled_at        timestamptz,
  created_at          timestamptz not null default now(),
  updated_at          timestamptz not null default now(),
  unique (user_id)
);

create table billing_events (
  id             uuid primary key default gen_random_uuid(),
  user_id        uuid not null references profiles(id) on delete cascade,
  stripe_event_id text unique,
  event_type     text not null,                            -- 'invoice.paid','subscription.cancelled', etc.
  amount_cents   integer,
  currency       text not null default 'usd',
  payload        jsonb,
  created_at     timestamptz not null default now()
);

-- =============================================================================
-- UC-12 — NOTIFICATIONS
-- =============================================================================

create table notifications (
  id          uuid primary key default gen_random_uuid(),
  user_id     uuid not null references profiles(id) on delete cascade,
  type        notification_type not null,
  title       text not null,
  body        text not null,
  deep_link   text,
  is_read     boolean not null default false,
  delivered_at timestamptz,
  created_at  timestamptz not null default now()
);

-- =============================================================================
-- UC-13 / UC-14 — FRIENDSHIPS & LEADERBOARDS
-- =============================================================================

create table friendships (
  id          uuid primary key default gen_random_uuid(),
  requester_id uuid not null references profiles(id) on delete cascade,
  addressee_id uuid not null references profiles(id) on delete cascade,
  status      friendship_status not null default 'pending',
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now(),
  unique (requester_id, addressee_id),
  check (requester_id <> addressee_id)
);

create table leaderboard_snapshots (
  id              uuid primary key default gen_random_uuid(),
  owner_id        uuid not null references profiles(id) on delete cascade,  -- creator of board
  snapshot_date   date not null default current_date,
  participant_ids uuid[] not null default '{}',
  rankings        jsonb not null default '[]',             -- [{user_id, display_name, score, rank}]
  metric          text not null default 'weekly_activity_minutes',
  created_at      timestamptz not null default now()
);

-- =============================================================================
-- UC-15 — STREAKS & REWARDS
-- =============================================================================

create table streaks (
  user_id          uuid primary key references profiles(id) on delete cascade,
  current_streak   integer not null default 0,
  longest_streak   integer not null default 0,
  last_activity_date date,
  updated_at       timestamptz not null default now()
);

create table rewards (
  id          uuid primary key default gen_random_uuid(),
  code        text not null unique,                        -- e.g. 'streak_7','streak_30'
  title       text not null,
  description text,
  icon_url    text,
  milestone   integer not null,                            -- streak days required
  created_at  timestamptz not null default now()
);

create table user_rewards (
  id         uuid primary key default gen_random_uuid(),
  user_id    uuid not null references profiles(id) on delete cascade,
  reward_id  uuid not null references rewards(id) on delete cascade,
  earned_at  timestamptz not null default now(),
  unique (user_id, reward_id)
);

-- =============================================================================
-- FOCUS CYCLES (weekly budget wrapper — from core_models.dart)
-- =============================================================================

create table focus_cycles (
  id          uuid primary key default gen_random_uuid(),
  user_id     uuid not null references profiles(id) on delete cascade,
  week_start  date not null,
  week_end    date not null,
  status      text not null default 'active',              -- 'active','completed','expired'
  created_at  timestamptz not null default now(),
  unique (user_id, week_start)
);

create table screen_budgets (
  id                  uuid primary key default gen_random_uuid(),
  cycle_id            uuid not null references focus_cycles(id) on delete cascade,
  user_id             uuid not null references profiles(id) on delete cascade,
  base_allowance_mins integer not null default 120,
  maximum_cap_mins    integer,
  earned_credits_mins integer not null default 0,
  remaining_balance_mins integer not null default 120,
  expires_at          timestamptz,
  created_at          timestamptz not null default now(),
  updated_at          timestamptz not null default now(),
  unique (cycle_id, user_id)
);

-- =============================================================================
-- INDEXES
-- =============================================================================

create index on activity_logs        (user_id, logged_at desc);
create index on activity_logs        (plan_id);
-- UC-5 business rule: one log per plan per calendar day
create unique index activity_logs_one_per_day
  on activity_logs (user_id, plan_id, (timezone('utc', logged_at)::date))
  where plan_id is not null;
create index on screen_time_ledger   (user_id, created_at desc);
create index on focus_sessions       (user_id, started_at desc);
create index on emergency_overrides  (user_id, requested_at desc);
create index on blocked_apps         (user_id);
create index on blocked_domains      (user_id);
create index on notifications        (user_id, is_read, created_at desc);
create index on friendships          (addressee_id, status);
create index on leaderboard_snapshots(owner_id, snapshot_date desc);
create index on user_rewards         (user_id);
create index on focus_cycles         (user_id, week_start desc);
create index on screen_budgets       (user_id);
create index on billing_events       (user_id, created_at desc);

-- =============================================================================
-- ROW-LEVEL SECURITY (RLS)
-- =============================================================================

alter table profiles              enable row level security;
alter table user_settings         enable row level security;
alter table activity_plans        enable row level security;
alter table activity_logs         enable row level security;
alter table screen_time_ledger    enable row level security;
alter table screen_time_state     enable row level security;
alter table focus_sessions        enable row level security;
alter table emergency_overrides   enable row level security;
alter table blocked_apps          enable row level security;
alter table blocked_domains       enable row level security;
alter table subscriptions         enable row level security;
alter table billing_events        enable row level security;
alter table notifications         enable row level security;
alter table friendships           enable row level security;
alter table leaderboard_snapshots enable row level security;
alter table streaks                enable row level security;
alter table user_rewards          enable row level security;
alter table focus_cycles          enable row level security;
alter table screen_budgets        enable row level security;

-- Users can only read/write their own data
create policy "own data only" on profiles
  using (id = auth.uid());

create policy "own data only" on user_settings
  using (user_id = auth.uid());

create policy "own data only" on activity_plans
  using (user_id = auth.uid());

create policy "own data only" on activity_logs
  using (user_id = auth.uid());

create policy "own data only" on screen_time_ledger
  using (user_id = auth.uid());

create policy "own data only" on screen_time_state
  using (user_id = auth.uid());

create policy "own data only" on focus_sessions
  using (user_id = auth.uid());

create policy "own data only" on emergency_overrides
  using (user_id = auth.uid());

create policy "own data only" on blocked_apps
  using (user_id = auth.uid());

create policy "own data only" on blocked_domains
  using (user_id = auth.uid());

create policy "own data only" on subscriptions
  using (user_id = auth.uid());

create policy "own data only" on billing_events
  using (user_id = auth.uid());

create policy "own data only" on notifications
  using (user_id = auth.uid());

create policy "own data only" on streaks
  using (user_id = auth.uid());

create policy "own data only" on user_rewards
  using (user_id = auth.uid());

create policy "own data only" on focus_cycles
  using (user_id = auth.uid());

create policy "own data only" on screen_budgets
  using (user_id = auth.uid());

-- Friendships: visible to either party
create policy "friendship participants" on friendships
  using (requester_id = auth.uid() or addressee_id = auth.uid());

-- Leaderboards: visible to participants
create policy "leaderboard participants" on leaderboard_snapshots
  using (owner_id = auth.uid() or auth.uid() = any(participant_ids));

-- Sports & rewards are public read-only
create policy "public read" on sports   for select using (true);
create policy "public read" on rewards  for select using (true);

-- =============================================================================
-- HELPER FUNCTION: auto-create profile + settings on sign-up
-- =============================================================================

create or replace function handle_new_user()
returns trigger language plpgsql security definer as $$
begin
  insert into public.profiles (id)
  values (new.id);

  insert into public.user_settings (user_id)
  values (new.id);

  insert into public.screen_time_state (user_id)
  values (new.id);

  insert into public.streaks (user_id)
  values (new.id);

  insert into public.subscriptions (user_id)
  values (new.id);

  return new;
end;
$$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure handle_new_user();
