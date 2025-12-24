CREATE TEMP TABLE movie_top_rating AS
WITH 
rating_category_relation AS (
    SELECT
        rating,
        trim(c.value) AS category,
        COUNT(*) AS relation
    FROM raw.movies,
    LATERAL unnest(string_to_array(listed_in, ',')) AS c(value)
    WHERE rating IS NOT NULL
    GROUP BY 1,2
), 
target_category AS (
    SELECT 
        show_id,
        trim(c.value) AS category
    FROM raw.movies,
    LATERAL unnest(string_to_array(listed_in, ',')) AS c(value)
    WHERE rating IS NULL
), 
votes AS (
    SELECT 
        t.show_id,
        r.rating,
        SUM(r.relation) AS frequency
    FROM rating_category_relation r
    INNER JOIN target_category t USING(category)
    GROUP BY 1,2
), 
rank AS (
    SELECT
        v.*,
        ROW_NUMBER() OVER (PARTITION BY show_id ORDER BY frequency DESC) AS rnk
    FROM votes v
    WHERE frequency > 1
) SELECT 
    show_id,
    rating
    FROM rank
    WHERE rnk = 1