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

-- Check null values at country column
SELECT
    trim(unnest(string_to_array(director, ','))) AS director,
    country
FROM netflix_raw
WHERE director <> 'Not Given'
ORDER BY director

# This query and the previous do the same thing!
# It happens because of a discouraged legacy behaviour called SRF in SELECT list 
# (Set Returning Functions in SELECT list)
# When we run the first query, Postgre does this behind the scenes:
SELECT 
    trim(d.value) AS director,
    country
FROM netflix_raw n,
LATERAL unnest(string_to_array(n.director, ',')) AS d(value)
WHERE director <> 'Not Given'
ORDER BY director;
# This is the recommended way of using set-returning functions

-- Cross lateral join to find each country is more often related to each director
# There is a need to use regexp_replace() cause trim() only remove traditional ASCII whitespaces
SELECT 
    trim(d.value) AS director,
    trim(regexp_replace(c.value, '[\x00-\x1F\x7F]', 'g')) AS country,
    COUNT(*) AS director_country_relation
FROM netflix_raw n,
LATERAL unnest(string_to_array(n.director, ',')) AS d(value),
LATERAL unnest(string_to_array(country, ',')) AS c(value)
WHERE director <> 'Not Given'
GROUP BY d.value, c.value
ORDER BY director ASC

-- Update the country column, filling NULL values with the country that most frequently appears with the cast
WITH director_country_relation AS (
    SELECT 
        trim(d.value) AS director,
        trim(regexp_replace(c.value, '[\x00-\x1F\x7F]', '', 'g')) AS country,
        COUNT(*) AS director_country_count
    FROM netflix_raw n,
    LATERAL unnest(string_to_array(n.director, ',')) AS d(value),
    LATERAL unnest(string_to_array(n.country, ',')) AS c(value)
    WHERE trim(d.value) <> 'Not Given'
    GROUP BY trim(d.value), trim(regexp_replace(c.value, '[\x00-\x1F\x7F]', '', 'g'))
), director_top_country AS (
    SELECT 
    dcr.*,
    ROW_NUMBER() OVER (PARTITION BY dcr.director ORDER BY dcr.director_country_count DESC) AS rnk
    FROM director_country_relation AS dcr
) UPDATE netflix_raw nr
SET country = (
    SELECT 
    dtc.country
    FROM director_top_country AS dtc
    WHERE EXISTS (
        SELECT 1
        FROM unnest(string_to_array(nr.director, ',')) AS dir(value)
        WHERE trim(dir.value) = dtc.director
    )
    AND dtc.rnk = 1
    LIMIT 1
)
WHERE nr.country IS NULL
AND nr.director <> 'Not Given';

-- Fill remaining null values with 'Not Given'
UPDATE netflix_raw
SET country = 'Not Given'
WHERE country IS NULL;

-- Look for null values on date_added, rating and duration
SELECT * FROM netflix_raw 
WHERE date_added IS NULL 
OR rating is NULL
OR duration is NULL

-- Correct rows where duration information were at rating column
UPDATE netflix_raw
SET 
    duration = rating,
    rating = NULL
WHERE rating LIKE '%min%';

-- Breaks 'listed_in' columns into single rows
SELECT 
    nr.title,
    nr.rating,
    trim(l.value)
FROM netflix_raw nr,
LATERAL unnest(string_to_array(listed_in, ',')) AS l(value);

-- Rank most frequent rating for each category
WITH unnested_listed_in_cte AS (
    SELECT 
        nr.rating AS rating,
        trim(l.value) category,
        COUNT(nr.rating) rating_count
    FROM netflix_raw nr,
    LATERAL unnest(string_to_array(listed_in, ',')) AS l(value)
    WHERE rating IS NOT NULL
    GROUP BY trim(l.value), nr.rating
)SELECT
    cte.*,
    ROW_NUMBER() OVER (PARTITION BY cte.category ORDER BY cte.rating_count DESC) AS rnk
FROM unnested_listed_in_cte AS cte;


WITH unnested_listed_in_cte AS (
    SELECT 
        nr.rating AS rating,
        trim(l.value) category,
        COUNT(*) rating_count
    FROM netflix_raw nr
    CROSS JOIN LATERAL unnest(string_to_array(nr.listed_in, ',')) AS l(value)
    WHERE trim(l.value) <> 'Movie'
    AND nr.rating IS NOT NULL
    GROUP BY nr.rating, trim(l.value)
), category_rank_cte AS (
    SELECT
        cte.*,
        ROW_NUMBER() OVER (PARTITION BY cte.category ORDER BY cte.rating_count DESC) AS rnk
    FROM unnested_listed_in_cte AS cte
) UPDATE netflix_raw nr
SET rating = (
    SELECT rating
    FROM category_rank_cte cr
    WHERE cr.rnk = 1
    AND EXISTS (
            SELECT 1
            FROM unnest(string_to_array(nr.listed_in, ',')) AS l(value)
            WHERE trim(l.value) <> 'Movie'
            AND trim(l.value) = cr.category
        )
    LIMIT 1
)
WHERE rating IS NULL;

UPDATE netflix_raw 
SET date_added = 'Not Given'
WHERE date_added IS NULL
