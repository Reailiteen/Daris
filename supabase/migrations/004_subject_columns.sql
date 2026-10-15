alter table subjects
  add column if not exists syllabus_book text,
  add column if not exists num_quizzes int not null default 0,
  add column if not exists num_assignments int not null default 0,
  add column if not exists num_midterms int not null default 0,
  add column if not exists num_finals int not null default 0,
  add column if not exists num_projects int not null default 0;
