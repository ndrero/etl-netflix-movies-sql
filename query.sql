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