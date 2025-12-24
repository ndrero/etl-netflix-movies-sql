CREATE TABLE cleaned.movies AS 
SELECT 
    rm.show_id,
    rm.type,
    rm.title,
    COALESCE(rm.director, td.director, 'Not Given') AS director,
    rm."cast",
    COALESCE(rm.country, tc.country, 'Not Given') AS country,
    rm.date_added,
    rm.release_year,
    CASE
        WHEN rm.rating LIKE '%min%' THEN NULL 
        ELSE COALESCE(rm.rating, tr.rating, 'Not Given') 
    END AS rating,
    CASE 
        WHEN rm.rating LIKE '%min%' 
        THEN rm.rating 
        ELSE COALESCE(rm.duration, 'Not Given') 
    END AS duration,
    rm.listed_in,
    rm.description
FROM raw.movies rm
LEFT JOIN movie_top_director td USING (show_id)
LEFT JOIN movie_top_country tc USING(show_id)
LEFT JOIN movie_top_rating tr USING (show_id)