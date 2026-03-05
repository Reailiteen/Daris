-- Add syllabus_file_path column to subjects table
alter table subjects add column if not exists syllabus_file_path text;
