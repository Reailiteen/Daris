create table study_tasks (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users not null,
  subject_id uuid references subjects,
  title text not null,
  difficulty text not null check (difficulty in ('small', 'medium', 'hard')),
  reward_minutes int not null,
  is_completed boolean default false,
  completed_at timestamptz,
  created_at timestamptz default now()
);

alter table study_tasks enable row level security;

create policy "Users can manage their own tasks"
  on study_tasks
  for all
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);
