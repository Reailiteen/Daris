create table screen_time_earnings (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users not null,
  source text not null check (source in ('task', 'ai_question')),
  minutes_earned int not null,
  earned_at timestamptz default now(),
  week_start date not null
);

alter table screen_time_earnings enable row level security;

create policy "Users can manage their own earnings"
  on screen_time_earnings
  for all
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);
