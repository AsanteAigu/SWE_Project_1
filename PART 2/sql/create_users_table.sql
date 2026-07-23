-- Auth table for the department web app.
-- Run this once against the existing Neon database before using /register.
-- Does not modify any pre-existing table (student_info, lecturers, student_fees,
-- courses, enrollment, teaching_assistant, lecturer_course, lecturer_ta).

create table if not exists users (
  user_id serial primary key,
  student_id varchar(8) not null references student_info(student_id),
  email varchar(50) unique not null,
  password_hash varchar(100) not null
);
