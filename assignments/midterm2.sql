/* Midterm 2 (1) Solutions */

/* 1. (a) */
with
    courses_with_students as (select cid from Enrolled)

select cid,dept from Courses where cid in courses_with_students;

/* (b) */
with
    370students as (select sid from Enrolled where cid='csc370'),
    360students as (select sid from Enrolled where cid='seng360')
select * from 370students where sid in (Table 360students)

/* (c) */
select cid from Enrolled
where not exists (select cid from Enrolled where grade is NULL);

/* 2. (a) */
with
    courses_atleastone as (select cid from Enrolled),
    crs_inst as (select cid,dept,iit from Courses where cid in courses_atleastone),
    inst as (select dept as instDept,iit from Instructors where iit in crs_inst),
    final as (select * from crs_inst join inst using(iit))

select cid,dept from final where dept=instDept;

/* (b) */
with
    grades_only as (
        select sid,grade from Enrolled
        where grade is not NULL)
select * from grades_only where grade >= grade;

SELECT * FROM Test t1
WHERE NOT EXISTS (SELECT 1 FROM Test t2 WHERE t2.grade > t1.grade);

with t1 as (select * from Enrolled), t2 as (select * from Enrolled)
select * from t1 where not exists (select * from t2 where t2.grade > t1.grade);

/* (c) */

with
    notcsc_courses as (select cid,dept from Courses where dept!='CSC'),
    students_notcsc as (
        select sid from Enrolled
        where cid in (Table notcsc_courses))
    not_enrolled as (
        select sid,sname from Students
        where sid not in (select sid from Enrolled))
select sid,sname from Students where sid in students_notcsc
union not_enrolled;

/* 3. (a) */
select cid,count(*) as scount from Enrolled group by cid
union (select cid,0 from Courses where cid not in Enrolled);

/* (b) */
with
    course_averages as (
        select cid,avg(grade) as allavgs from Enrolled
        where grade is not null
        group by cid
    )
select cid,max(asllavgs) as avg from course_averages;
