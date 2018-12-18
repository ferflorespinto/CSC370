/* Assignment 4
   CSC370
   Fall 2018
   Name: Jorge Fernando Flores Pinto
   ID: V00880059
 */

/* Question 1 */
with
    got as (
        select id from productions where title='Game of Thrones' and attr='TV-series'
    ),
    goteps as (
        select id from episodes where episodeof in (Table got)
    ),
    gotcountries as (
        select country from locations where id in (Table goteps)
    )
select distinct country from gotcountries order by country asc;

/*
Output:

country
------------------
Canada
Croatia
Iceland
Malta
Morocco
Northern Ireland
Spain
UK
USA
(9 rows)
*/

/* Question 2 */
with
    mvs as (
        select id,year from productions where attr is NULL
    ),
    ah_movies as (
        select id from directors
        where id in (select id from mvs)
            and pid~'Hitchcock, Alfred'
    ),
    ratings_for_ah_movies as (
        select id,ratings.rank from ratings where id in (select id from ah_movies)
        and votes > 50000
    )
select * from ah_movies
join mvs using (id)
join ratings_for_ah_movies using (id)
order by rank desc;

/*
Output:

id              | year | rank
-----------------------------+------+------
Rear Window (1954)          | 1954 |  8.5
Psycho (1960)               | 1960 |  8.5
North by Northwest (1959)   | 1959 |  8.4
Vertigo (1958)              | 1958 |  8.4
Rebecca (1940)              | 1940 |  8.2
Dial M for Murder (1954)    | 1954 |  8.2
Strangers on a Train (1951) | 1951 |  8.1
Rope (1948)                 | 1948 |    8
Notorious (1946)            | 1946 |    8
The Birds (1963)            | 1963 |  7.7
(10 rows)
*/

/* Question 3 */
with
    mvs as (
        select id,year from productions where attr is NULL
    ),
    pnewman_mvs as (
        select id, character as paulchar, billing as paulbilling from roles
        where id in (select id from mvs)
        and pid='Newman, Paul (I)' and character!~'Himself'
    ),
    rredford_mvs as (
        select id, character as robchar, billing as robbilling from roles
        where id in (select id from mvs)
        and pid='Redford, Robert (I)' and character!~'Himself'
    ),
    both_mvs as (
        select id from pnewman_mvs
        where id in (select id from rredford_mvs)
    ),
    both_mvs_ratings as (
        select id,rank from ratings where id in (Table both_mvs)
    )
select * from both_mvs
join mvs using (id)
join both_mvs_ratings using (id)
join pnewman_mvs using (id)
join rredford_mvs using (id);

/*
Output:

id                     | year | rank |    paulchar    | paulbilling |     robchar      | robbilling
-------------------------------------------+------+------+----------------+-------------+------------------+------------
Butch Cassidy and the Sundance Kid (1969) | 1969 |  8.1 | Butch Cassidy  |           1 | The Sundance Kid |          2
Mickybo and Me (2004)                     | 2004 |  7.3 | Butch Cassidy  |             | The Sundance Kid |
The Sting (1973)                          | 1973 |  8.3 | Henry Gondorff |           1 | Johnny Hooker    |          2
(3 rows)
*/

/* Question 4 */
with
    HM_directors as (
        select distinct pid from directors where id in (
            select id from episodes where id~'\"Hora Marcada\" \(1986\)'
        )
    ),
    mvs_dirs as (
        select id,pid from directors
        where pid in (Table HM_directors)
        and id in (select id from productions where attr is NULL)
    ),
    mvs_English_dirs as (
        select id,pid from languages
        join mvs_dirs using (id)
        where id in (select id from mvs_dirs)
        and language='English'
    ),
    mv_ratings as (
        select id,rank from ratings
        where id in (select id from mvs_English_dirs)
    )

select * from HM_directors
join mvs_English_dirs using (pid)
left outer join mv_ratings using (id)
order by rank desc nulls last;

/*
Output:

id                        |           pid            | rank
-------------------------------------------------+--------------------------+------
Children of Men (2006)                          | Cuarón, Alfonso          |  7.9
Gravity (2013)                                  | Cuarón, Alfonso          |  7.8
Harry Potter and the Prisoner of Azkaban (2004) | Cuarón, Alfonso          |  7.8
A Little Princess (1995)                        | Cuarón, Alfonso          |  7.7
Vengeance Is Mine (1983)                        | Cuarón, Alfonso          |  7.4
Paris, je t'aime (2006)                         | Cuarón, Alfonso          |  7.3
Sólo con tu pareja (1991)                       | Cuarón, Alfonso          |  7.1
Pacific Rim (2013)                              | del Toro, Guillermo      |    7
Hellboy II: The Golden Army (2008)              | del Toro, Guillermo      |    7
Hellboy (2004)                                  | del Toro, Guillermo      |  6.8
(25 rows)

*/

/* Question 5 */
with
    lucas_mvs as (
        select id from productions
        where attr is NULL
        and id in (
            select id from directors where pid='Lucas, George (I)'
        )
    ),
    kurosawa_mvs as (
        select id from productions
        where attr is NULL
        and id in (
            select id from directors where pid='Kurosawa, Akira'
        )
    ),
    relationships as (
        select id as lucas, idlinkedto as kurosawa, relationship from links
        where id in (Table lucas_mvs) and idlinkedto in (Table kurosawa_mvs)
    )
select * from relationships
order by lucas asc;

/*
Output:

lucas                        |              kurosawa            | relationship
-----------------------------------------------------+-------------------------------------+--------------

Star Wars (1977)                                    | Kakushi-toride no san-akunin (1958) | references
Star Wars (1977)                                    | Shichinin no samurai (1954)         | references
Star Wars (1977)                                    | Yôjinbô (1961)                      | references
Star Wars (1977)                                    | Dersu Uzala (1975)                  | references
Star Wars: Episode II - Attack of the Clones (2002) | Kagemusha (1980)                    | references
Star Wars: Episode II - Attack of the Clones (2002) | Shichinin no samurai (1954)         | references
Star Wars: Episode III - Revenge of the Sith (2005) | Shichinin no samurai (1954)         | references
Star Wars: Episode I - The Phantom Menace (1999)    | Kagemusha (1980)                    | references
Star Wars: Episode I - The Phantom Menace (1999)    | Kakushi-toride no san-akunin (1958) | references
Star Wars: Episode I - The Phantom Menace (1999)    | Kumonosu-jô (1957)                  | references
(11 rows)
*/
