create table student_info (
  student_id varchar(8) primary key,
  first_name varchar(30) not null,
  last_name varchar(30) not null,
  date_of_birth date,
  total_fee_due numeric(8,2),
  constraint chk_student_id check(length(student_id) = 8)
);

create table lecturers(
  lecturer_id varchar(8) primary key,
  first_name varchar(30) not null,
  last_name varchar(30) not null,
  constraint chk_lect_id check(length(lecturer_id) = 8)
);

create table student_fees(
  payment_id serial primary key,
  student_id varchar(8) not null,
  amount numeric(8,2) not null,
  date_of_payment date,
  constraint chk_student_id check(length(student_id) = 8),
  constraint fk_fees_student foreign key (student_id) references student_info(student_id)
);

create table courses(
  course_id varchar(12) primary key,
  course_name varchar(50) not null,
  credits int not null
);

create table enrollment(
  enrollment_id serial primary key,
  student_id varchar(8) not null,
  course_id varchar(12) not null,
  grade varchar(2),
  constraint fk_std_id foreign key (student_id) references student_info(student_id),
  constraint fk_course_id foreign key (course_id) references courses(course_id)
);

create table teaching_assistant(
  ta_id varchar(8) primary key,
  first_name varchar(30) not null,
  last_name varchar(30) not null,
  constraint ch_ta_id check(length(ta_id) = 8)
);

create table lecturer_course(
  lecturer_id varchar(8) not null,
  course_id varchar(12) not null,
  primary key (lecturer_id, course_id),
  constraint fk_lec_id foreign key (lecturer_id) references lecturers(lecturer_id),
  constraint fk_course_id foreign key (course_id) references courses(course_id)
);

create table lecturer_ta(
  lecturer_id varchar(8) not null,
  ta_id varchar(8) not null,
  primary key (lecturer_id, ta_id),
  constraint fk_lec_id foreign key (lecturer_id) references lecturers(lecturer_id),
  constraint fk_ta_id foreign key (ta_id) references teaching_assistant(ta_id)
);


