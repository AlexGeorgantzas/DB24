select cook.cook_id , CONCAT(cook.firstname, ' ', cook.lastname) AS full_name , count(*)
from cook 
inner join ep_info on ep_info.cook_id = cook.cook_id
where  (year(now()) - year(cast(cook.date_of_birth as datetime))) <=30
group by cook.cook_id

select cook_id, ep_id
from ep_info

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

SELECT 
r.carbs
FROM 
    episode e
JOIN 
    ep_info ei ON e.ep_ID = ei.ep_ID
JOIN 
    recipe r ON ei.recipe_ID = r.recipe_ID
WHERE 
    e.season = 1;




select ep_info.cook_id, episode.episode,cuisine_name,season  , national_cuisine.national_cuisine_ID
from ep_info 
inner join recipe on ep_info.recipe_id = recipe.recipe_id
inner join national_cuisine on recipe.national_cuisine_ID = national_cuisine.national_cuisine_ID
inner join episode on ep_info.ep_id = episode.ep_id
where ep_info.cook_id = 2;

select * from expertise where cook_id = 2;

select national_cuisine_ID 
FROM expertise
WHERE cook_ID = 2