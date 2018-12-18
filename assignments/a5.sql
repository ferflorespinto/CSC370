/* Question 1 */

with
    series as (
        select episodeof,id,season from episodes
        where episodeof in (
            select id from productions
            where attr='TV-series')),
    rated_episodes as (
        /* Why do I need select * ? Why do I need to alias? Why can't I just join
        with the inner select? */
        select * from (select id,votes,rank from ratings
        where id in (select id from series)) as all_fields
        join series using (id)
    ),
    high_rated as (
        select * from (
            select episodeof,avg(rank) as arank,avg(votes) as avotes
            from rated_episodes group by episodeof) as averages
        where arank > 8.5 and avotes >= 1000

    ),
    high_rated_series_geq4_seasons as (
        select * from (
            select episodeof,count(*) as cepisodes,max(season) as cseasons from rated_episodes
            group by episodeof) as geq4_seasons
        where cseasons > 3
    )

select episodeof,arank,avotes,cepisodes,cseasons from high_rated
join high_rated_series_geq4_seasons using (episodeof)
order by arank desc, avotes desc;

/* Output:

|          episodeof           |      arank       |        avotes         | cepisodes | cseasons
-------------------------------+------------------+-----------------------+-----------+----------
 "Person of Interest" (2011)   | 9.13980582524272 | 2047.6310679611650485 |       103 |        5
 "Breaking Bad" (2008)         | 9.01935483870968 |    11124.709677419355 |        62 |        5
 "Game of Thrones" (2011)      | 8.99833333333333 |    19718.333333333333 |        60 |        6
 "Sherlock" (2010)             | 8.94166666666667 |    15931.333333333333 |        12 |        4
 "Suits" (2011)                | 8.85357142857143 | 1318.0000000000000000 |        84 |        6
 "The Wire" (2002)             | 8.84333333333333 | 1422.1166666666666667 |        60 |        5
 "House of Cards" (2013)       | 8.72884615384615 | 2628.5000000000000000 |        52 |        4
 "Supernatural" (2005)         | 8.71611570247934 | 2059.5123966942148760 |       242 |       11
 "House M.D." (2004)           | 8.69318181818182 | 1439.4602272727272727 |       176 |        8
 "Sons of Anarchy" (2008)      | 8.69239130434783 | 1145.6195652173913043 |        92 |        7
 "Prison Break" (2005)         | 8.68395061728395 | 1629.8518518518518519 |        81 |        4
 "Lost" (2004)                 | 8.67692307692308 | 2819.5811965811965812 |       117 |        6
 "The Sopranos" (1999)         | 8.67209302325582 | 1574.4186046511627907 |        86 |        6
 "Dexter" (2006)               | 8.64166666666667 | 2802.8750000000000000 |        96 |        8
 "Luther" (2010)               | 8.59411764705882 | 1103.4705882352941176 |        17 |        4
 "Boardwalk Empire" (2010)     | 8.55087719298246 | 1095.0877192982456140 |        57 |        5
 "Friends" (1994)              | 8.54152542372881 | 1642.8898305084745763 |       236 |       10
 "Vikings" (2013)              | 8.53589743589744 | 1740.2051282051282051 |        39 |        4
 "Mad Men" (2007)              | 8.53152173913044 | 1100.8804347826086957 |        92 |        7
 "Arrow" (2012)                | 8.52717391304348 | 3053.7934782608695652 |        92 |        4
 "Once Upon a Time" (2011)     |  8.5212389380531 | 1000.0530973451327434 |       113 |        5
 "Arrested Development" (2003) | 8.51470588235294 | 1062.6176470588235294 |        68 |        4
(22 rows)
 */

/* Question 2 */

with
    movies as (select id,title,year from productions where attr is NULL),
    many_votes as (
        select id,rank,votes from ratings
        where id in (select id from movies) and votes >= 50000
    ),
    highest as (
        select * from many_votes where rank in (select max(rank) as rank from many_votes)
    )

select title,year,rank,votes from highest
join movies using (id);

/* Output:
|          title          | year | rank |  votes
--------------------------+------+------+---------
 The Shawshank Redemption | 1994 |  9.3 | 1698604
(1 row)
*/

/* Question 3 */
with
    movies as (select id from productions where attr is NULL),
    good_movies as (
        select id,rank,votes from ratings
        where id in (Table movies) and rank >= 8  and votes >= 50000
    ),
    actors_in_gm as (
        select pid,id,rank from good_movies
        join roles using (id)
    ),
    count_actors_avg_ranks as (
        select * from (
            select pid,count(*) as cmovies,avg(rank) arank from actors_in_gm
            group by pid)
        as result where cmovies >= 10
    )
select * from count_actors_avg_ranks
order by arank asc;

/* Output:
|          pid          | cmovies |      arank
------------------------+---------+------------------
 Tovey, Arthur          |      11 | 8.21818181818182
 McGowan, Mickie        |      10 |             8.23
 Lynn, Sherry (I)       |      12 | 8.25833333333333
 Flowers, Bess          |      12 | 8.25833333333333
 Ratzenberger, John (I) |      12 | 8.28333333333333
 Oliveira, Joseph (III) |      10 |             8.38
(6 rows)
*/

/* Question 4 */
with
    movies as (select id from productions where attr is NULL),
    good_movies as (
        select id,rank,votes from ratings
        where id in (Table movies) and rank >= 8  and votes >= 50000
    ),
    actors_in_gm as (
        select pid,id,rank,billing,character from good_movies
        join roles using (id)
    ),
    count_actors as (
        select pid,count(*) as cmovies from actors_in_gm
        group by pid
    ),
    actors_with_max_appearances as (
        select pid from count_actors
        where cmovies in (select max(cmovies) from count_actors)
    )
select pid,id,billing,character from actors_with_max_appearances
join actors_in_gm using (pid)
order by pid asc;

/* Output:
|          pid          |                          id                           | billing |                        character
------------------------+-------------------------------------------------------+---------+----------------------------------------------------------
 Flowers, Bess          | Dial M for Murder (1954)                              |         | Woman Departing Ship
 Flowers, Bess          | Notorious (1946)                                      |         | Party Guest
 Flowers, Bess          | Double Indemnity (1944)                               |         | Norton's Secretary
 Flowers, Bess          | North by Northwest (1959)                             |         | Hotel Lounge Patron
 Flowers, Bess          | The Big Sleep (1946)                                  |         | Woman with Bumped Man
 Flowers, Bess          | Vertigo (1958)                                        |         | Diner at Ernie's
 Flowers, Bess          | Rear Window (1954)                                    |         | Songwriter's Party Guest with Poodle
 Flowers, Bess          | All About Eve (1950)                                  |         | Sarah Siddons Awards Well-Wisher
 Flowers, Bess          | Witness for the Prosecution (1957)                    |         | Courtroom Spectator
 Flowers, Bess          | Singin' in the Rain (1952)                            |         | Audience Member
 Flowers, Bess          | The Manchurian Candidate (1962)                       |         | Gomel's Lady Counterpart
 Flowers, Bess          | It Happened One Night (1934)                          |         | Agnes - Gordon's Secretary
 Lynn, Sherry (I)       | Toy Story (1995)                                      |      27 | Mom
 Lynn, Sherry (I)       | Inside Out (2015/I)                                   |      46 | Additional Voices
 Lynn, Sherry (I)       | Sen to Chihiro no kamikakushi (2001)                  |      59 |
 Lynn, Sherry (I)       | The Iron Giant (1999)                                 |      23 | Additional Voices
 Lynn, Sherry (I)       | Aladdin (1992)                                        |      18 | Additional Voices
 Lynn, Sherry (I)       | Mononoke-hime (1997)                                  |      13 | Woman in Iron Town/Emishi Village Girl/Additional voices
 Lynn, Sherry (I)       | Oldeuboi (2003)                                       |         | Mi-do
 Lynn, Sherry (I)       | Beauty and the Beast (1991)                           |      40 |
 Lynn, Sherry (I)       | Toy Story 3 (2010)                                    |         |
 Lynn, Sherry (I)       | WALL·E (2008)                                         |      17 | Axiom Passenger #5
 Lynn, Sherry (I)       | Monsters, Inc. (2001)                                 |      34 | Additional Voices
 Lynn, Sherry (I)       | Up (2009)                                             |      25 | Additional Voices
 Ratzenberger, John (I) | Ratatouille (2007)                                    |      12 | Mustafa
 Ratzenberger, John (I) | Toy Story (1995)                                      |       6 | Hamm
 Ratzenberger, John (I) | Inside Out (2015/I)                                   |      17 | Fritz
 Ratzenberger, John (I) | Toy Story 3 (2010)                                    |       8 | Hamm
 Ratzenberger, John (I) | Star Wars: Episode V - The Empire Strikes Back (1980) |      31 | Rebel Force Major Derlin
 Ratzenberger, John (I) | Up (2009)                                             |       7 | Construction Foreman Tom
 Ratzenberger, John (I) | Gandhi (1982)                                         |     124 | American Lieutenant
 Ratzenberger, John (I) | Sen to Chihiro no kamikakushi (2001)                  |      56 | Assistant Manager
 Ratzenberger, John (I) | Monsters, Inc. (2001)                                 |       8 | The Abominable Snowman
 Ratzenberger, John (I) | The Incredibles (2004)                                |      21 | Underminer
 Ratzenberger, John (I) | Finding Nemo (2003)                                   |      24 | Fish School
 Ratzenberger, John (I) | WALL·E (2008)                                         |       6 | John
(36 rows)
*/

/* Question 5 */
with
    movies as (select id from productions where attr is NULL),
    good_movies as (
        select id,rank,votes from ratings
        where id in (Table movies) and rank > 8.4  and votes >= 40000
    ),
    directors_goodmovies as (
        select * from (
            select pid,count(pid) as goodones from directors
            where id in (select id from good_movies) group by pid)
        as tempdirs
        join (select pid,id from directors) as temp1 using(pid)
        join ratings using (id)
    ),
    directors_count_atleast8_movies as (
        select * from (
            select pid,count(pid) as total from directors
            where id in (Table movies) group by pid)
        as dirs where total > 7
    ),
    dirs_good_atleast8 as (
        select * from directors_count_atleast8_movies
        where pid in (select pid from directors_goodmovies)
    ),
    avgsgood as (
        select pid,avg(rank) as avggoodones from directors_goodmovies group by pid
    )

select pid,total,goodones, (total - goodones) as rest,avggoodones from dirs_good_atleast8
join directors_goodmovies using(pid)
join avgsgood using (pid);

/*
pid                | cmov | count
-----------------------------------+------+-------
Benigni, Roberto                  |    9 |     1
Besson, Luc                       |   20 |     1
Cameron, James (I)                |   19 |     1
Capra, Frank                      |   55 |     1
Chaplin, Charles                  |   72 |     3
Coppola, Francis Ford             |   30 |     3
Curtiz, Michael                   |  174 |     1
Demme, Jonathan                   |   37 |     1
Fincher, David                    |   14 |     2
Forman, Milos                     |   19 |     1
Henckel von Donnersmarck, Florian |    8 |     1
Hitchcock, Alfred (I)             |   63 |     2
Jackson, Peter (I)                |   17 |     3
Kapadia, Asif                     |   18 |     1
Kaye, Tony (I)                    |   11 |     1
Kershner, Irvin                   |   15 |     1
Kubrick, Stanley                  |   16 |     2
Kurosawa, Akira                   |   33 |     1
Leone, Sergio (I)                 |    9 |     2
Lucas, George (I)                 |   17 |     1
Lumet, Sidney                     |   48 |     1
Lund, Kátia                       |    8 |     1
Meirelles, Fernando (I)           |   12 |     1
Minkoff, Rob                      |   13 |     1
Miyazaki, Hayao                   |   25 |     1
Nakache, Olivier                  |   10 |     1
Nolan, Christopher (I)            |   13 |     6
Polanski, Roman (I)               |   36 |     1
Scorsese, Martin (I)              |   58 |     2
Scott, Ridley                     |   35 |     2
Singer, Bryan                     |   16 |     1
Spielberg, Steven                 |   46 |     3
Takahata, Isao                    |   14 |     1
Tarantino, Quentin                |   15 |     2
Toledano, Eric                    |    9 |     1
Tornatore, Giuseppe               |   17 |     1

*/
