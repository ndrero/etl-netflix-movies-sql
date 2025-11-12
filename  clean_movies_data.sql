-- Show database 
SELECT * FROM netflix_raw;

--The show_id column is the unique id for the dataset, therefore we are going to check for duplicates
SELECT
    COUNT(show_id) AS total_show_id,
    COUNT(DISTINCT(show_id)) AS distinct_show_id
FROM netflix_raw;


-- Check null values across columns 
SELECT 
    COUNT(*) FILTER (WHERE show_id IS NULL) AS showid_null,
    COUNT(*) FILTER (WHERE type IS NULL) AS type_null,
    COUNT(*) FILTER (WHERE title IS NULL) AS title_null,
    COUNT(*) FILTER (WHERE director IS NULL) AS director_null,
    COUNT(*) FILTER (WHERE "cast" IS NULL) AS cast_null,
    COUNT(*) FILTER (WHERE country IS NULL) AS country_null,
    COUNT(*) FILTER (WHERE date_added IS NULL) AS date_added_null,
    COUNT(*) FILTER (WHERE release_year IS NULL) AS release_year_null,
    COUNT(*) FILTER (WHERE rating IS NULL) AS rating_null,
    COUNT(*) FILTER (WHERE duration IS NULL) AS duration_null,
    COUNT(*) FILTER (WHERE listed_in IS NULL) AS listed_in_null,
    COUNT(*) FILTER (WHERE description IS NULL) AS description_null
FROM netflix_raw;

--  Find out if there is relationship between movie_cast column and director column
SELECT 
    director, 
    COUNT(director)
FROM netflix_raw
GROUP BY director

-- Verify if the same director appears with different casts 
SELECT 
    director,
    COUNT(DISTINCT "cast") AS distinct_cast
FROM netflix_raw
WHERE "cast" IS NOT NULL
GROUP BY director;

-- Verify if the same casts appears with different directors 
SELECT 
    "cast",
    COUNT(DISTINCT director) AS distinct_director
FROM netflix_raw
WHERE director IS NOT NULL 
GROUP BY "cast"
HAVING COUNT(DISTINCT director) > 1;

-- Show how many colabs a certain actor has with the same director
WITH director_actor AS (
    SELECT 
    director,
    unnest(string_to_array("cast", ',')) AS actor
    FROM netflix_raw
) 
SELECT 
    director,
    actor,
    COUNT(*) AS colabs
FROM director_actor
GROUP BY actor, director
ORDER BY actor;


-- Update table, filling null director values with the director who most frequently works with the listed actors
WITH top_directors AS (
    SELECT 
        director,
        unnest(string_to_array("cast", ',')) AS actor,
        COUNT(*) AS colab,
        ROW_NUMBER() OVER (PARTITION BY unnest(string_to_array("cast", ',')) ORDER BY COUNT(*) DESC) AS rnk
    FROM netflix_raw
    WHERE director IS NOT NULL
    GROUP BY actor, director
)
UPDATE netflix_raw nr
SET director = td.director
FROM top_directors td
WHERE td.actor = ANY(string_to_array("cast", ','))
AND td.rnk = 1
AND nr.director IS NULL;

-- Update table, filling remaining null director values with 'Not Given'
UPDATE netflix_raw
SET director = 'Not Given'
WHERE director IS NULL;
