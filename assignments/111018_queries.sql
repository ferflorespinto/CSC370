/*
Assume the following schema: (_attr_ indicates primary key)
    Classes(_class_, type, country, numGuns, bore, displacement)
    Ships(_ship_, class, launched)
    Battles(_battle_, bdate)
    Outcomes(_ship_, _battle_, result)

a) List the ship, type, country, battle and result for all ships.
*/

with T1 as (select * from S natural join c)
     T2 as (select ship,type,country from t1)
select * from t2 natural join O;

/*
b) For every ship that survived a battle (result = 'ok'), and for every ship
that was sunk in that battle (result = 'sunk'), list the name of the battle,
the surviving ship, and the sunk ship.
*/

select o.ship as survived, o2.ship as sunk, o.battle
    from (o as o2, o where p, with o2 as (table o) select...)

/*
List the ship name and class of ships that were sunk (result = 'sunk'). Answer
this question with and without a join.
*/
/* Without join: */
with sunk as (select ship from O where result='sunk')
select ship, class from ships where ship in (sunk);

/* With join: */
with sunk as (select ship from O where result='sunk')
select ship,class from S natural join sunk;

/*
Let's say we have classes A, B or C.
Which ships are in either class A or class B?
*/
(select ship from ships where class='A') union (select ship from ships where
class='B');

/* Ships that have two classes... */
(select ship from ships where class='A') intersect (select ship from ships where
class='B');


/****************************** Aggregations **********************************/
select count(*) from ships;

select class,type,count(*) from ships group by class,type;

/*Class count of the classes that have at least 5 ships*/
with atleast5 as (
    select class from (
        select class,count(*) as c from class group by ships
    )
    where c >= 5
);

with atleast5 as (
    select class from ships group by class having count(*) >= 5
)

with atleast5 as (
    select class from ships where <condition> group by class having count(*) >= 5
)
