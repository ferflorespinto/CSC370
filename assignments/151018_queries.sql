/*
Consider the following schema:
Suppliers(sid:integer, sname:string, address:string)
Parts(pid:integer, pname:string, color:string)
Catalog(sid:integer, pid:integer, cost:real)
*/

/* 1. Find the average cost of each part -> pid, avg(cost). */

/* 2. Find the minimum cost at which each part is being sold. List pid, supplier
id (sid), and cost. */

select pid, min(cost) as cost from catalog group by pid;

with t as (select pid, min(cost) as cost from catalog group by pid) select *
from t natural join catalog; /* Returns a table with pid, cost and pname */


/* 3. Find the part name(s) that has the largest number of suppliers. There
might be more than one tuple in the result. */

/* List the parts for which the competitors of acme offer a better price. */


with A as (select pid, count(*) as c from catalog group by pid),
    M as (select max(c) as mx from A),
    MP as (select * from A where c in (Table M))
select pname from MP natural join Parts;

/* How many parts does every supplier supply (including those not in catalog)? */

select distinct sid from catalog;
/* == */
select sid from catalog group by sid;


select * from parts natural join catalog;
/* These two are the same, but the one below is preferable so we don't worry
about changes in the schema. */
select * from parts join catalog using (pid);
