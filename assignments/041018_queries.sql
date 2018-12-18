select distinct attr /* ... displays all unique fields of a particular attr */

/* in command line: psql csc370 */

select * from r where a IN (select a from R);

/*
R:
    a | b
    -----
    1 | a
    2 | y
*/

select * from r where a = (select a from R limit 1);

select (select a from R limit 1) from r;

/*
    a
    --
    1
    1
*/

select * from r;

insert into r values /*...*/

/*
SQL gives us the option to set null as another value. This helps so that
instead of displaying an empty string, it displays the string NULL.
This query sets null's as a string 'NULL'. */
\pset null 'NULL'

delete from r where a = 3;

/************************ Cross-product of relations *************************/

select * from R,S;
/*
S:
    a | c
    -----
    5 | 8
    2 | 12

R,S:
    a | b | a | c
    -------------
    1 | a | 5 | 8
    2 | y | 5 | 8
    1 | a | 2 | 12
    2 | y | 2 | 12
*/

select S.a from R,S;

/*
Allows us to select the specific attribute we want. In this case there are
two 'a' attributes.
    a
    -
    5
    5
    2
    2
*/

create temp table X as select as c, c as d from S;

/* This is how we write the theta join operation: */
select * from R join S on (a < c);

alter table T add column e int;

alter table S rename column d to f;

/* use 'using' instead of 'on' */
select * from S join T using (c);

select * from S full join T using (c);

select * from S left join T using (c);

select * from S right join T using (c);
