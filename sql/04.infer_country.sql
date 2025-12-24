CREATE TEMP TABLE movie_top_country AS
WITH 
director_actor_relation AS (
    SELECT
        trim(c.value) AS country,
        director,
        COUNT(*) AS relation
    FROM raw.movies,
    LATERAL unnest(string_to_array(country, ',')) AS c(value)
    WHERE director IS NOT NULL
    GROUP BY 1,2
), 
target_director AS (
    SELECT
        show_id,
        trim(d.value) AS director
    FROM raw.movies,
    LATERAL unnest(string_to_array(director, ',')) AS d(value)
    WHERE country IS NULL
), 
votes AS (
    SELECT
        td.show_id, 
        dr.country,
        SUM(dr.relation) AS frequency
    FROM director_actor_relation dr
    INNER JOIN target_director td USING (director)
    GROUP BY 1, 2
), 
rank_relation AS (
    SELECT 
        v.*,
        ROW_NUMBER() OVER (PARTITION BY show_id ORDER BY frequency DESC) AS rnk
    FROM votes v
    WHERE frequency > 1
) SELECT
    country,
    show_id
FROM rank_relation 
WHERE rnk = 1;