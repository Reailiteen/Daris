-- FocusFlow: Full Core Schema (Refined)

-- Enable necessary extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 1. Identity & User Foundation

-- User: Auth anchor. Boring. Sacred.
CREATE TABLE IF NOT EXISTS public.users (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT UNIQUE NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    last_active_at TIMESTAMPTZ DEFAULT NOW(),
    timezone TEXT DEFAULT 'UTC',
    locale TEXT DEFAULT 'en'
);

-- Profile: Human-facing identity.
CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID PRIMARY KEY REFERENCES public.users(id) ON DELETE CASCADE,
    display_name TEXT,
    avatar_url TEXT,
    onboarding_status TEXT DEFAULT 'pending',
    app_mode TEXT DEFAULT 'casual', -- 'casual' or 'athlete'
    is_beta BOOLEAN DEFAULT FALSE,
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Account State: Because people get banned, leave, or regret things.
CREATE TABLE IF NOT EXISTS public.account_states (
    user_id UUID PRIMARY KEY REFERENCES public.users(id) ON DELETE CASCADE,
    status TEXT DEFAULT 'active', -- 'active', 'suspended', 'deleted'
    reason TEXT,
    effective_date TIMESTAMPTZ DEFAULT NOW(),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. Sports & Activity System (Sport-agnostic by design)

-- Sport: Config layer.
CREATE TABLE IF NOT EXISTS public.sports (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL UNIQUE,
    category TEXT NOT NULL, -- 'endurance', 'strength', 'mixed', 'mobility'
    supported_metrics TEXT[] DEFAULT '{}', -- e.g., ['time', 'distance', 'reps', 'laps']
    intensity_model TEXT, -- e.g., 'RPE', 'Heart Rate Zones'
    is_enabled BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Activity Session: Event layer.
CREATE TABLE IF NOT EXISTS public.activity_sessions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    sport_id UUID NOT NULL REFERENCES public.sports(id),
    start_time TIMESTAMPTZ NOT NULL,
    end_time TIMESTAMPTZ NOT NULL,
    duration INTERVAL GENERATED ALWAYS AS (end_time - start_time) STORED,
    intensity_value FLOAT, -- user or system
    source TEXT DEFAULT 'manual', -- 'manual', 'device'
    validation_status TEXT DEFAULT 'pending', -- 'pending', 'confirmed', 'flagged'
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Activity Metrics: Flexible measurement store.
CREATE TABLE IF NOT EXISTS public.activity_metrics (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    session_id UUID NOT NULL REFERENCES public.activity_sessions(id) ON DELETE CASCADE,
    metric_key TEXT NOT NULL, -- distance, reps, laps
    metric_value FLOAT NOT NULL,
    unit TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3. Weekly Focus System (Opal DNA)

-- Focus Cycle (Weekly): Defines the time window.
CREATE TABLE IF NOT EXISTS public.focus_cycles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    week_start TIMESTAMPTZ NOT NULL,
    week_end TIMESTAMPTZ NOT NULL,
    status TEXT DEFAULT 'active', -- 'active', 'completed', 'expired'
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Focus Commitment: What the user promised themselves.
CREATE TABLE IF NOT EXISTS public.focus_commitments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    cycle_id UUID NOT NULL REFERENCES public.focus_cycles(id) ON DELETE CASCADE,
    commitment_type TEXT NOT NULL, -- 'sessions', 'minutes', 'mixed'
    target_value FLOAT NOT NULL,
    preferred_sport_categories TEXT[] DEFAULT '{}',
    locked_at TIMESTAMPTZ DEFAULT NOW(),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 4. Screen-Time Economy

-- Screen Budget: Weekly allowance container.
CREATE TABLE IF NOT EXISTS public.screen_budgets (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    cycle_id UUID NOT NULL REFERENCES public.focus_cycles(id) ON DELETE CASCADE,
    base_allowance INTERVAL NOT NULL,
    maximum_cap INTERVAL,
    earned_credits INTERVAL DEFAULT '0 seconds',
    remaining_balance INTERVAL NOT NULL,
    expires_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Credit Rules: Config, not logic.
CREATE TABLE IF NOT EXISTS public.credit_rules (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    sport_category TEXT NOT NULL,
    intensity_min FLOAT,
    intensity_max FLOAT,
    duration_threshold INTERVAL,
    screen_credit_reward INTERVAL NOT NULL,
    daily_caps INTERVAL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Screen Usage Event: Tracks consumption.
CREATE TABLE IF NOT EXISTS public.screen_usage_events (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    budget_id UUID REFERENCES public.screen_budgets(id) ON DELETE SET NULL,
    app_category TEXT, -- 'social', 'video', 'neutral'
    duration_used INTERVAL NOT NULL,
    occurred_at TIMESTAMPTZ DEFAULT NOW(),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 5. Notifications

-- Notification: Represents intent, not delivery.
CREATE TABLE IF NOT EXISTS public.notifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    type TEXT NOT NULL, -- 'reminder', 'warning', 'unlock', 'summary', 'system'
    title TEXT NOT NULL,
    body TEXT NOT NULL,
    priority TEXT DEFAULT 'normal',
    context_reference UUID, -- e.g., cycle_id, budget_id
    expires_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Notification Delivery: Tracks how it was sent.
CREATE TABLE IF NOT EXISTS public.notification_deliveries (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    notification_id UUID NOT NULL REFERENCES public.notifications(id) ON DELETE CASCADE,
    channel TEXT NOT NULL, -- 'push', 'email', 'in-app'
    status TEXT DEFAULT 'queued', -- 'queued', 'sent', 'failed', 'opened'
    attempt_count INTEGER DEFAULT 0,
    provider_metadata JSONB DEFAULT '{}',
    sent_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Notification Preferences: User controls.
CREATE TABLE IF NOT EXISTS public.notification_preferences (
    user_id UUID PRIMARY KEY REFERENCES public.users(id) ON DELETE CASCADE,
    preferences JSONB DEFAULT '{}',
    quiet_hours_start TIME,
    quiet_hours_end TIME,
    frequency_limits JSONB DEFAULT '{}',
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 6. Subscriptions & Billing

-- Subscription Plan: Static configuration.
CREATE TABLE IF NOT EXISTS public.subscription_plans (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL UNIQUE,
    feature_flags TEXT[] DEFAULT '{}',
    weekly_screen_cap INTERVAL,
    max_commitments INTEGER,
    external_price_id TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- User Subscription: Current entitlement.
CREATE TABLE IF NOT EXISTS public.user_subscriptions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    plan_id UUID NOT NULL REFERENCES public.subscription_plans(id),
    status TEXT DEFAULT 'trialing', -- 'trialing', 'active', 'canceled'
    start_date TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    end_date TIMESTAMPTZ,
    auto_renew BOOLEAN DEFAULT TRUE,
    provider_subscription_id TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Subscription Event: Immutable billing history.
CREATE TABLE IF NOT EXISTS public.subscription_events (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    event_type TEXT NOT NULL, -- 'created', 'renewed', 'failed', 'canceled'
    provider_payload JSONB DEFAULT '{}',
    occurred_at TIMESTAMPTZ DEFAULT NOW()
);

-- 7. Feature Flags & Experiments

-- Feature Flag: Defines a toggle.
CREATE TABLE IF NOT EXISTS public.feature_flags (
    key TEXT PRIMARY KEY,
    description TEXT,
    is_enabled_globally BOOLEAN DEFAULT FALSE,
    rollout_percentage INTEGER DEFAULT 0,
    environment TEXT DEFAULT 'production',
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- User Feature Override: Exceptions for testing or emergencies.
CREATE TABLE IF NOT EXISTS public.user_feature_overrides (
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
    flag_key TEXT REFERENCES public.feature_flags(key) ON DELETE CASCADE,
    enabled_state BOOLEAN NOT NULL,
    reason TEXT,
    expires_at TIMESTAMPTZ,
    PRIMARY KEY (user_id, flag_key)
);

-- 8. Devices, Sessions & Security

-- User Device: Represents a physical device.
CREATE TABLE IF NOT EXISTS public.user_devices (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    platform TEXT, -- 'ios', 'android', 'web'
    push_token TEXT,
    last_active_at TIMESTAMPTZ DEFAULT NOW(),
    trust_level INTEGER DEFAULT 1,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Auth Session Metadata: Lightweight session tracking.
CREATE TABLE IF NOT EXISTS public.auth_session_metadata (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    device_id UUID REFERENCES public.user_devices(id) ON DELETE SET NULL,
    session_start TIMESTAMPTZ DEFAULT NOW(),
    session_end TIMESTAMPTZ,
    ip_hash TEXT,
    coarse_location TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 9. Audit & Safety Net

-- Audit Log: Who changed what.
CREATE TABLE IF NOT EXISTS public.audit_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    actor_id UUID REFERENCES public.users(id), -- system if null
    action_type TEXT NOT NULL,
    target_entity_type TEXT NOT NULL,
    target_entity_id UUID NOT NULL,
    before_snapshot JSONB,
    after_snapshot JSONB,
    occurred_at TIMESTAMPTZ DEFAULT NOW()
);

-- App Configuration: Global knobs.
CREATE TABLE IF NOT EXISTS public.app_configurations (
    key TEXT PRIMARY KEY,
    value TEXT NOT NULL,
    environment TEXT DEFAULT 'production',
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Automated Functions & Triggers

-- Trigger to update updated_at
CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_profiles_updated_at BEFORE UPDATE ON public.profiles FOR EACH ROW EXECUTE PROCEDURE public.update_updated_at_column();
CREATE TRIGGER update_notification_preferences_updated_at BEFORE UPDATE ON public.notification_preferences FOR EACH ROW EXECUTE PROCEDURE public.update_updated_at_column();

-- Trigger to sync user from auth.users (Optional but recommended for the sacred users table)
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.users (id, email)
    VALUES (NEW.id, NEW.email);
    
    INSERT INTO public.profiles (id, display_name)
    VALUES (NEW.id, NEW.raw_user_meta_data->>'display_name');
    
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Note: You need to manually enable this trigger in the Supabase Dashboard if you want auto-sync:
-- CREATE TRIGGER on_auth_user_created
--   AFTER INSERT ON auth.users
--   FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();
