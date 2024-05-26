--queries
--3.1. mesos oros aksiologiseon ana mafeira kai ethniki kouzina

select cook.cook_ID,avg(rating_1+rating_2+rating_3) avgrating
from cook 
inner join ep_info on ep_info.cook_id = cook.cook_id
group by cook.cook_ID



select national_cuisine.national_cuisine_ID, national_cuisine.cuisine_name, avg(rating_1+rating_2+rating_3) 
from ep_info 
inner join recipe on recipe.recipe_id = ep_info.recipe_id
inner join national_cuisine on national_cuisine.national_cuisine_ID = recipe.national_cuisine_ID
group by national_cuisine.national_cuisine_ID, national_cuisine.cuisine_name


--==========================================
--3.2 gia dedomeni ethniki kouzina kai etos poioi mageires anikoun se autin kai 
--poioi mageires simetixan se episodeia?

--!! auto to ana etos pou leei den vgazei noima giati 
--gia na paro to ana etos prepei na exoun simetasxei oi mageires se ep
select national_cuisine.cuisine_name, cook.cook_id, concat(cook.firstname,' ',cook.lastname),season
from cook 
left join expertise on expertise.cook_id = cook.cook_id
left join national_cuisine on recipe_id.national_cuisine_ID = expertise.national_cuisine_ID
left join ep_info on ep_info.cook_id = cook.cook_id
inner join episode on episode.episode_id = ep_info.episode_id
group by cook.cook_id, concat(cook.firstname,' ',cook.lastname),national_cuisine.cuisine_name, season


--===========================================
--3.3 ------------------------------------------------------------------------
--vreite tous neous mageieres OK
select cook.cook_id , CONCAT(cook.firstname, ' ', cook.lastname) AS full_name , count(*)
from cook 
inner join ep_info on ep_info.cook_id = cook.cook_id
where  (year(now()) - year(cast(cook.date_of_birth as datetime))) <=30
group by cook.cook_id

--!! mipos thelei poies sintafes exoun ftiaksei? 
--===========================================
--3.4 ------------------------------------------------------------------------
--vreite tous mageires pou den exoun simetasxei pote san krites se kapoio episodeio

SELECT 
    cook.cook_ID,  
    CONCAT(cook.firstname, ' ', cook.lastname) AS full_name
FROM 
    cook 
LEFT JOIN 
    episode ep1 ON ep1.judge_1 = cook.cook_ID 
LEFT JOIN 
    episode ep2 ON ep2.judge_2 = cook.cook_ID 
LEFT JOIN 
    episode ep3 ON ep3.judge_3 = cook.cook_ID 
WHERE 
    ep1.judge_1 IS NULL AND ep2.judge_2 IS NULL AND ep3.judge_3 IS NULL;

-- second one better 
SELECT 
    cook.cook_ID,  
    CONCAT(cook.firstname, ' ', cook.lastname) AS full_name
FROM 
    cook
WHERE 
    NOT EXISTS (
        SELECT 1
        FROM episode e
        WHERE e.judge_1 = cook.cook_ID 
           OR e.judge_2 = cook.cook_ID 
           OR e.judge_3 = cook.cook_ID
    );

--3.5 ------------------------------------------------------------------------
SELECT 
    e.season,
    CONCAT(c.firstname, ' ', c.lastname) AS judge_name,
    COUNT(*) AS appearances
FROM 
    episode e
JOIN 
    cook c ON e.judge_1 = c.cook_ID
        OR e.judge_2 = c.cook_ID
        OR e.judge_3 = c.cook_ID
GROUP BY 
    e.season, c.cook_ID
HAVING 
    appearances > 3
ORDER BY 
    e.season, appearances DESC;



--poioi krites exoun simmetasxei ston idio arithmo episodeion se diastima enos etous
--me perisoteres apo 3 emfaniseis 

--!!!!!!!! na to ksanakoitakso mia

-- select * into # temp from 
-- (select judge_1 judge, count(*) c, season 
-- from episode 
-- group by judge_1, season
-- having count(*) >3
-- union
-- select judge_2, count(*) , season
-- from episode 
-- group by judge_2, season
-- having count(*) >3
-- union
-- select judge_3, count(*) , season
-- from episode 
-- group by judge_3,  season
-- having count(*) >3
-- )xx

-- SELECT judge, season, participation_count
-- FROM judge_participations
-- WHERE participation_count IN (
--     SELECT participation_count
--     FROM judge_participations
--     GROUP BY season, participation_count
--     HAVING COUNT(*) > 1
-- )
-- ORDER BY season, participation_count DESC, judge;


----======================================================

-- Create the temporary table
CREATE TEMPORARY TABLE temp_judge_participations (
    judge VARCHAR(255),
    c INT,
    season INT
);

-- Insert data into the temporary table
INSERT INTO temp_judge_participations (judge, c, season)
SELECT judge, c, season
FROM (
    SELECT judge_1 AS judge, COUNT(*) AS c, season
    FROM episode 
    GROUP BY judge_1, season
    HAVING COUNT(*) > 3
    UNION ALL
    SELECT judge_2 AS judge, COUNT(*) AS c, season
    FROM episode 
    GROUP BY judge_2, season
    HAVING COUNT(*) > 3
    UNION ALL
    SELECT judge_3 AS judge, COUNT(*) AS c, season
    FROM episode 
    GROUP BY judge_3, season
    HAVING COUNT(*) > 3
) AS xx;

-- Query the temporary table
SELECT judge, season, c
FROM temp_judge_participations
WHERE c IN (
    SELECT c
    FROM temp_judge_participations
    GROUP BY season, c
    HAVING COUNT(*) > 1
)
ORDER BY season, c DESC, judge;

----======================================================

----------

--3.6. ------------------------------------------------------------------------
--- 3.6

SELECT l1.label_description AS label1, l2.label_description AS label2, COUNT(*) AS count
FROM label_recipe lr1
JOIN label_recipe lr2 ON lr1.recipe_ID = lr2.recipe_ID AND lr1.label_ID < lr2.label_ID
JOIN ep_info ei ON lr1.recipe_ID = ei.recipe_ID
JOIN label l1 ON lr1.label_ID = l1.label_ID
JOIN label l2 ON lr2.label_ID = l2.label_ID
GROUP BY l1.label_description, l2.label_description
ORDER BY count DESC
LIMIT 3;


-- 3.6 Alternative Query Plan

SELECT STRAIGHT_JOIN l1.label_description AS label1, l2.label_description AS label2, COUNT(*) AS count
FROM label_recipe lr1
FORCE INDEX (recipe_label_idx)
JOIN label_recipe lr2 FORCE INDEX (recipe_label_idx)
ON lr1.recipe_ID = lr2.recipe_ID AND lr1.label_ID < lr2.label_ID
JOIN ep_info ei FORCE INDEX (fk_recipe_ID_idx)
ON lr1.recipe_ID = ei.recipe_ID
JOIN label l1 ON lr1.label_ID = l1.label_ID
JOIN label l2 ON lr2.label_ID = l2.label_ID
GROUP BY l1.label_description, l2.label_description
ORDER BY count DESC
LIMIT 3;



-- 3.6 Traces

EXPLAIN SELECT l1.label_description AS label1, l2.label_description AS label2, COUNT(*) AS count
FROM label_recipe lr1
JOIN label_recipe lr2 ON lr1.recipe_ID = lr2.recipe_ID AND lr1.label_ID < lr2.label_ID
JOIN ep_info ei ON lr1.recipe_ID = ei.recipe_ID
JOIN label l1 ON lr1.label_ID = l1.label_ID
JOIN label l2 ON lr2.label_ID = l2.label_ID
GROUP BY l1.label_description, l2.label_description
ORDER BY count DESC
LIMIT 3;


-- 3.6 Traces

EXPLAIN SELECT STRAIGHT_JOIN l1.label_description AS label1, l2.label_description AS label2, COUNT(*) AS count
FROM label_recipe lr1
FORCE INDEX (recipe_label_idx)
JOIN label_recipe lr2 FORCE INDEX (recipe_label_idx)
ON lr1.recipe_ID = lr2.recipe_ID AND lr1.label_ID < lr2.label_ID
JOIN ep_info ei FORCE INDEX (fk_recipe_ID_idx)
ON lr1.recipe_ID = ei.recipe_ID
JOIN label l1 ON lr1.label_ID = l1.label_ID
JOIN label l2 ON lr2.label_ID = l2.label_ID
GROUP BY l1.label_description, l2.label_description
ORDER BY count DESC
LIMIT 3

--3.7. ------------------------------------------------------------------------
--vreite olous tous mageires pou simetixan toulaxiston 5 ligoteres fores 
--apo ton mageira me tis perisoteres simmetohes se episodeia
---AUTO MALLON
SELECT cook_ID
FROM (
    SELECT cook_ID, COUNT(*) AS cook_count
    FROM ep_info 
    GROUP BY cook_ID
) AS cook_participations
WHERE cook_count <= (
    SELECT MAX(cook_count) - 5
    FROM (
        SELECT cook_ID, COUNT(*) AS cook_count
        FROM ep_info 
        GROUP BY cook_ID
    ) AS max_cook_participations
);

----------
SELECT 
    c1.cook_ID AS cook_id,
    CONCAT(c1.firstname, ' ', c1.lastname) AS cook_name,
    COUNT(e.ep_ID) AS appearances
FROM 
    cook c1
JOIN 
    ep_info ei ON c1.cook_ID = ei.cook_ID
JOIN 
    episode e ON ei.ep_ID = e.ep_ID
GROUP BY 
    c1.cook_ID, c1.firstname, c1.lastname
HAVING 
    COUNT(e.ep_ID) < (SELECT COUNT(ei2.ep_ID)
                      FROM ep_info ei2
                      JOIN cook c2 ON ei2.cook_ID = c2.cook_ID
                      GROUP BY c2.cook_ID
                      ORDER BY COUNT(ei2.ep_ID) DESC
                      LIMIT 1) - 5;

--3.8. ------------------------------------------------------------------------
SELECT e.ep_ID, e.season, e.episode, COUNT(re.eq_ID) AS equipment_count
FROM episode e
JOIN ep_info ei ON e.ep_ID = ei.ep_ID
JOIN recipe_eq re ON ei.recipe_ID = re.recipe_ID
GROUP BY e.ep_ID, e.season, e.episode
ORDER BY equipment_count DESC
LIMIT 1;


-- 3.8 Alternative Query Plan

SELECT STRAIGHT_JOIN e.ep_ID, e.season, e.episode, COUNT(re.eq_ID) AS equipment_count
FROM episode e
JOIN ep_info ei FORCE INDEX (ep_ID_idx)
ON e.ep_ID = ei.ep_ID
JOIN recipe_eq re FORCE INDEX (fk_recipe_ID_idx)
ON ei.recipe_ID = re.recipe_ID
GROUP BY e.ep_ID, e.season, e.episode
ORDER BY equipment_count DESC
LIMIT 1;


-- 3.8 Traces

EXPLAIN SELECT e.ep_ID, e.season, e.episode, COUNT(re.eq_ID) AS equipment_count
FROM episode e
JOIN ep_info ei ON e.ep_ID = ei.ep_ID
JOIN recipe_eq re ON ei.recipe_ID = re.recipe_ID
GROUP BY e.ep_ID, e.season, e.episode
ORDER BY equipment_count DESC
LIMIT 1;


-- 3.8 Alternative Query Plan Traces

EXPLAIN SELECT STRAIGHT_JOIN e.ep_ID, e.season, e.episode, COUNT(re.eq_ID) AS equipment_count
FROM episode e
JOIN ep_info ei FORCE INDEX (ep_ID_idx)
ON e.ep_ID = ei.ep_ID
JOIN recipe_eq re FORCE INDEX (fk_recipe_ID_idx)
ON ei.recipe_ID = re.recipe_ID
GROUP BY e.ep_ID, e.season, e.episode
ORDER BY equipment_count DESC
LIMIT 1;
--3.9. ------------------------------------------------------------------------
SELECT 
    e.season,
    AVG(r.carbs) AS average_carbs
FROM 
    episode e
JOIN 
    ep_info ei ON e.ep_ID = ei.ep_ID
JOIN 
    recipe r ON ei.recipe_ID = r.recipe_ID
GROUP BY 
    e.season;

--3.10. ------------------------------------------------------------------------
SELECT 
    CONCAT(e1.season, '-', e2.season) AS consecutive_seasons,
    nc.cuisine_name AS national_cuisine,
    COUNT(*) AS appearances
FROM 
    episode e1
JOIN 
    episode e2 ON e1.season + 1 = e2.season AND e1.episode = e2.episode
JOIN 
    ep_info ei1 ON e1.ep_ID = ei1.ep_ID
JOIN 
    ep_info ei2 ON e2.ep_ID = ei2.ep_ID
JOIN 
    national_cuisine nc ON ei1.recipe_ID = ei2.recipe_ID
WHERE 
    ei1.rating_1 + ei1.rating_2 + ei1.rating_3 > 3
    AND ei2.rating_1 + ei2.rating_2 + ei2.rating_3 > 3
GROUP BY 
    consecutive_seasons, nc.national_cuisine_ID
ORDER BY 
    consecutive_seasons, appearances DESC;
--3.11. ------------------------------------------------------------------------
SELECT 
    CONCAT(j.firstname, ' ', j.lastname) AS judge_name,
    CONCAT(c.firstname, ' ', c.lastname) AS cook_name,
    SUM(
        CASE
            WHEN e.judge_1 = j.cook_ID THEN ei.rating_1
            WHEN e.judge_2 = j.cook_ID THEN ei.rating_2
            WHEN e.judge_3 = j.cook_ID THEN ei.rating_3
            ELSE 0
        END
    ) AS total_rating
FROM 
    ep_info ei
JOIN 
    cook c ON ei.cook_ID = c.cook_ID
JOIN 
    episode e ON ei.ep_ID = e.ep_ID
JOIN 
    cook j ON e.judge_1 = j.cook_ID OR e.judge_2 = j.cook_ID OR e.judge_3 = j.cook_ID
GROUP BY 
    j.cook_ID, j.firstname, j.lastname, c.cook_ID, c.firstname, c.lastname
ORDER BY 
    total_rating DESC
LIMIT 5;
--3.12. ------------------------------------------------------------------------
SELECT e.ep_ID
FROM (
    SELECT e.ep_ID, SUM(r.difficulty_level) AS total_difficulty
    FROM episode e
    INNER JOIN ep_info ei ON e.ep_ID = ei.ep_ID
    INNER JOIN recipe r ON ei.recipe_ID = r.recipe_ID
    GROUP BY e.ep_ID
) AS episode_difficulty
ORDER BY total_difficulty DESC
LIMIT 1;

--3.13. ------------------------------------------------------------------------
--poio episodeio sigentrose 
--ton xamilitero vathmo epaggelmatikis katartisis(krites kai mageires)
SELECT episode, season
FROM (
    SELECT e.ep_ID AS episode, e.season,
           (SUM(j.rank) + SUM(c.rank)) / 13 AS avg_rank_level
    FROM episode e
    INNER JOIN cook j ON e.judge_1 = j.cook_ID OR e.judge_2 = j.cook_ID OR e.judge_3 = j.cook_ID
    INNER JOIN ep_info c ON e.ep_ID = c.ep_ID
    GROUP BY e.ep_ID, e.season
) AS avg_ranks_per_episode
ORDER BY avg_rank_level ASC
LIMIT 1;

SELECT episode, season,avg_rank_level
FROM (
    SELECT e.ep_ID AS episode, e.season,
           (SUM(CASE j.rank 
                    WHEN 'cook C' THEN 1 
                    WHEN 'cook B' THEN 2 
                    WHEN 'cook A' THEN 3 
                    WHEN 'assistant chef' THEN 4 
                    WHEN 'chef' THEN 5 
                    ELSE 0
                END) + 
                SUM(CASE c.rank 
                    WHEN 'cook C' THEN 1 
                    WHEN 'cook B' THEN 2 
                    WHEN 'cook A' THEN 3 
                    WHEN 'assistant chef' THEN 4 
                    WHEN 'chef' THEN 5 
                    ELSE 0
                END)) / 13 AS avg_rank_level
    FROM episode e
    INNER JOIN cook j ON e.judge_1 = j.cook_ID OR e.judge_2 = j.cook_ID OR e.judge_3 = j.cook_ID
    INNER JOIN ep_info ei ON e.ep_ID = ei.ep_ID
    INNER JOIN cook c ON ei.cook_ID = c.cook_ID
    GROUP BY e.ep_ID, e.season
) AS avg_ranks_per_episode
ORDER BY avg_rank_level ASC
LIMIT 1;

SELECT e.ep_ID AS episode_id,
       c_j1.rank AS judge1_rank,
       c_j2.rank AS judge2_rank,
       c_j3.rank AS judge3_rank,
       ei.cook_ID AS cook_id,
       c_cook.firstname AS cook_firstname,
       c_cook.lastname AS cook_lastname,
       c_cook.rank AS cook_rank
FROM episode e
JOIN ep_info ei ON e.ep_ID = ei.ep_ID
JOIN cook c_j1 ON e.judge_1 = c_j1.cook_ID
JOIN cook c_j2 ON e.judge_2 = c_j2.cook_ID
JOIN cook c_j3 ON e.judge_3 = c_j3.cook_ID
JOIN cook c_cook ON ei.cook_ID = c_cook.cook_ID
WHERE e.ep_ID = 4;

--3.14. poia thematiki ennotita exei emfanistei tis perisoteres fores ston diagonismo
--1st test ok , need second one

SELECT theme_ID, theme_name, c
FROM (
    SELECT theme.theme_ID, theme_name, COUNT(DISTINCT ep_id) AS c
    FROM theme
    INNER JOIN theme_recipe ON theme_recipe.theme_ID = theme.theme_ID
    INNER JOIN recipe ON theme_recipe.recipe_id = recipe.recipe_id
    INNER JOIN ep_info ON ep_info.recipe_id = recipe.recipe_id
    GROUP BY theme_ID, theme_name
    ORDER BY c DESC
) AS xx


--=========================================================================
--3.15. poies omades trofimon den exoun emfanistei pote ston diagonismo

-- List all food groups that are not included in any episode
SELECT fg.food_group_name
FROM food_group fg
WHERE fg.food_group_ID NOT IN (
    SELECT DISTINCT i.food_group_ID
    FROM ingredient i
    JOIN recipe_ingr ri ON i.ingredient_ID = ri.ingredient_ID
    JOIN recipe r ON ri.recipe_ID = r.recipe_ID
    JOIN ep_info ei ON r.recipe_ID = ei.recipe_ID
);








SELECT e.ep_ID AS episode_ID,
       e.judge_1 AS judge_1_ID,
       e.judge_2 AS judge_2_ID,
       e.judge_3 AS judge_3_ID,
       ei.cook_ID AS cook_ID,
       c.firstname AS cook_firstname,
       c.lastname AS cook_lastname
FROM episode e
INNER JOIN ep_info ei ON e.ep_ID = ei.ep_ID AND e.ep_ID = 4
INNER JOIN cook c ON ei.cook_ID = c.cook_ID
WHERE ei.ep_ID = 4
ORDER BY e.ep_ID, ei.cook_ID;


select * from ep_info where ep_id = 5
