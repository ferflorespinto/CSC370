create function ferflorespinto_directedby(pidd text)
returns Table(id text, year int, rank double precision, votes int) as $$
    with movies as (select id,year from productions where id is not null),
         bydirector as (select * from movies
                        where id in (select id from directors where pid= $1))
    select id,year,rank,votes
    from bydirector left join ratings using (id)
    order by year;
$$ language sql;

select * from ferflorespinto_directedby('Nolan, Christopher (I)');

/* Output:
              id               | year | rank |  votes
-------------------------------+------+------+---------
 Doodlebug (1997)              | 1997 |  7.1 |   11415
 Following (1998)              | 1998 |  7.6 |   66121
 Memento (2000)                | 2000 |  8.5 |  849849
 Insomnia (2002)               | 2002 |  7.2 |  219782
 Batman Begins (2005)          | 2005 |  8.3 |  986936
 The Prestige (2006)           | 2006 |  8.5 |  849119
 The Exec (2006) {{SUSPENDED}} | 2006 |      |
 The Dark Knight (2008)        | 2008 |    9 | 1685825
 Inception (2010)              | 2010 |  8.8 | 1476746
 The Dark Knight Rises (2012)  | 2012 |  8.5 | 1151061
 Interstellar (2014)           | 2014 |  8.6 |  937348
 Quay (2015)                   | 2015 |    8 |     357
 Dunkirk (2017)                | 2017 |      |
 (13 rows)
*/


/* Part 2 */
create table parts (
    pid integer,
    pname varchar(40),
    color varchar(20)
);
create table partshistory (
    pid integer,
    pname varchar(40),
    color varchar(20),
    operation char,
    opwhen timestamp,
    opuser char(20)
);

create or replace function logparts()
returns trigger as $$
    declare
        op text := TG_OP;
    begin
        if op = 'INSERT' then
            insert into partshistory(pid, pname, color, operation, opwhen, opuser) values (new.pid, new.pname, new.color, 'I', now(), current_user);
        end if;
        if op = 'UPDATE' then
            insert into partshistory(pid, pname, color, operation, opwhen, opuser) values (new.pid, new.pname, new.color, 'U', now(), current_user);
        end if;
        if op = 'DELETE' then
            insert into partshistory(pid, pname, color, operation, opwhen, opuser) values (old.pid, old.pname, old.color, 'D', now(), current_user);
        end if;
        return new;
    end;
$$ language plpgsql;

create trigger logging_parts
after insert or update or delete on parts
for each row
execute procedure logparts();
