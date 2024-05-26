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


--3.7. ------------------------------------------------------------------------
--vreite olous tous mageires pou simetixan toulaxiston 5 ligoteres fores 
--apo ton mageira me tis perisoteres simmetohes se episodeia

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

--3.8. ------------------------------------------------------------------------

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

--3.11. ------------------------------------------------------------------------

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
SELECT e.episode, e.season
FROM (
    SELECT ep_ID AS episode, season,
           AVG((SUM(j.rank_value) + SUM(c.rank_value)) / 13) AS avg_rank_level
    FROM episode e
    INNER JOIN cook j ON e.judge_1 = j.cook_ID OR e.judge_2 = j.cook_ID OR e.judge_3 = j.cook_ID
    INNER JOIN ep_info c ON e.ep_ID = c.ep_ID
    GROUP BY ep_ID, season
) AS avg_ranks_per_episode
ORDER BY avg_rank_level ASC
LIMIT 1;


--3.14. poia thematiki ennotita exei emfanistei tis perisoteres fores ston diagonismo
--!!test it

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
LIMIT 1;

--=========================================================================
--3.15. poies omades trofimon den exoun emfanistei pote ston diagonismo
select food_group.food_group_id , food_group_name from food_group
left join ingredient on ingredient.food_group_ID =  food_group.food_group_ID
left join recipe_ingr on recipe_ingr.ingredient_id = ingredient.ingredient_id
left join recipe on recipe.recipe_id = recipe_ingr.recipe_id
left join ep_info on ep_info.recipe_id = recipe.recipe_id
where ep_info.recipe_id is null








