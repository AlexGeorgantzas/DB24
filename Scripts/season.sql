CREATE PROCEDURE AssignCooksAndJudges()
BEGIN

drop table if exists  temp_cuisines;
CREATE TEMPORARY TABLE temp_cuisines AS
SELECT DISTINCT national_cuisine_ID
FROM expertise
ORDER BY RAND()
limit 10;

drop table if exists  eps;
CREATE TEMPORARY TABLE eps AS
SELECT 
row_number() over(order by random_cook_id) id1,

    tc.national_cuisine_ID,
    (SELECT e.cook_ID
     FROM expertise e
     WHERE e.national_cuisine_ID = tc.national_cuisine_ID
     ORDER BY RAND()
     LIMIT 1) AS random_cook_ID,
    (SELECT r.recipe_ID
     FROM recipe r
     WHERE r.national_cuisine_ID = tc.national_cuisine_ID
     ORDER BY RAND()
     LIMIT 1) AS random_recipe_ID,
     0 judge_1, 0 judge_2, 0 judge_3
FROM 
    temp_cuisines tc
HAVING 
  random_recipe_ID IS NOT NULL;


/*checks for cooks */
drop table if exists eps2;
CREATE TEMPORARY TABLE eps2 AS
 SELECT 
    ROW_NUMBER() OVER (PARTITION BY random_cook_ID ORDER BY id1) as rank, 
    eps.*
FROM 
    eps
order by id1;



update eps2 set random_cook_id = (select cook_id from cook where cook_id <> eps2.random_cook_id order by rand() limit 1 ) 
where  rank in(2,4,6,8,10) and (select max(rank) from eps2 e where e.random_cook_ID = eps2.random_cook_ID) >2;

UPDATE eps
JOIN eps2 ON eps.id1 = eps2.id1
SET eps.random_cook_ID = eps2.random_cook_ID;


/*checks for recipes */
drop table if exists  eps2;
CREATE TEMPORARY TABLE eps2 AS
 SELECT 
    ROW_NUMBER() OVER (PARTITION BY random_recipe_id ORDER BY id1) as rank, 
    eps.*
FROM 
    eps
order by id1;

update eps2 set random_recipe_id = (select recipe_id from recipe where recipe_id <> eps2.random_recipe_id order by rand() limit 1 ) 
where  rank in(2,4,6,8,10) and (select max(rank) from eps2 e where e.random_recipe_ID = eps2.random_recipe_ID) >2;

UPDATE eps
JOIN eps2 ON eps.id1 = eps2.id1
SET eps.random_recipe_id = eps2.random_recipe_id;



drop table if exists  judges;
CREATE TEMPORARY TABLE judges AS
select rank() over(order by cook_id )id,0 ep,x.* from 
(select cook_id from cook  where cook_id not in (select random_cook_ID from eps) order by rand() limit 30 
)x;


update judges set ep =1 where id in (1,2,3);
update judges set ep =2 where id in (4,5,6);
update judges set ep =3 where id in (7,8,9);
update judges set ep =4 where id in (10,11,12);
update judges set ep =5 where id in (13,14,15);
update judges set ep =6 where id in (16,17,18);
update judges set ep =7 where id in (19,20,21);
update judges set ep =8 where id in (22,23,24);
update judges set ep =9 where id in (25,26,27);
update judges set ep =10 where id in (28,29,30);


update eps 
join judges on judges.ep = eps.id1
set eps.judge_1 = judges.cook_id where id in(1,4,7,10,13,16,19,22,25,28);

update eps 
join judges on judges.ep = eps.id1
set eps.judge_2 = judges.cook_id where id in(2,5,8,11,14,17,20,23,26,29);

update eps 
join judges on judges.ep = eps.id1
set eps.judge_3 = judges.cook_id where id in(3,6,9,12,15,18,21,24,27,30);


/* insert into episode*/
insert into episode(ep_id ,image_id,judge_1,judge_2,judge_3,season,episode)
select rank() over(order by id1) + ifnull((select max(ep_id) from episode),0) ep_id,1  image_id, judge_1, judge_2, judge_3, (select ifnull(max(season),0)+1  from episode) season, id1 episode from  eps;

/*insert into ep_info*/
insert into ep_info (ep_id,cook_id,recipe_id,rating_1,rating_2,rating_3,avg_rating)

SELECT 
    CASE 
        WHEN (SELECT MAX(ep_id) FROM episode) = 10 THEN id1 
        ELSE (SELECT MAX(ep_id)-10 FROM episode) + id1
    END AS ep_id,
    
    random_cook_ID AS cook_id,
    random_recipe_ID,
    FLOOR(1 + (RAND() * 5)) AS rating_1,
    FLOOR(1 + (RAND() * 5)) AS rating_2,
    FLOOR(1 + (RAND() * 5)) AS rating_3,
    0 AS avg_rating
FROM 
    eps;


END