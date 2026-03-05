create table subjects (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users not null,
  name text not null,
  exam_date date,
  material_notes text,
  created_at timestamptz default now()
);

alter table subjects enable row level security;

create policy "Users can manage their own subjects"
  on subjects
  for all
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);
