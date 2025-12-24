-- Query for movies with null values in raw table
SELECT 
    show_id, 
    title, 
    director,
    country,
    rating
FROM raw.movies 
WHERE show_id = 's3'
OR show_id = 's5990'

-- Query for movies with null values in cleaned table
SELECT 
    show_id, 
    title, 
    director,
    country,
    rating
FROM cleaned.movies 
WHERE show_id = 's3'
OR show_id = 's5990'

-- Query to find null values
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
FROM cleaned.movies;