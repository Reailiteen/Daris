-- Pasted notes are deliberately separate from local syllabus file paths.
alter table subjects add column if not exists material_notes text;

create table if not exists screen_time_spends (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references profiles(id) on delete cascade,
  minutes_spent integer not null check (minutes_spent > 0),
  week_start date not null,
  created_at timestamptz not null default now()
);

alter table screen_time_spends enable row level security;
create policy "Users manage their own screen time spends"
  on screen_time_spends for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

-- One statement makes the task completion and its reward idempotent.
create or replace function complete_study_task_and_earn(p_task_id uuid, p_week_start date)
returns json
language plpgsql
security invoker
as $$
declare task_row study_tasks%rowtype;
begin
  update study_tasks
  set is_completed = true, completed_at = now()
  where id = p_task_id and user_id = auth.uid() and is_completed = false
  returning * into task_row;

  if not found then return null; end if;

  insert into screen_time_earnings (user_id, source, minutes_earned, week_start)
  values (auth.uid(), 'task', task_row.reward_minutes, p_week_start);

  return json_build_object('task_id', task_row.id, 'reward_minutes', task_row.reward_minutes);
end;
$$;
