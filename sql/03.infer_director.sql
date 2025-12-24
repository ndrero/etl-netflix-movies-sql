CREATE TEMP TABLE movie_top_director AS
WITH director_actor_collabs AS (
    SELECT
        trim(d.value) AS director,
        trim(c.value) AS actor,
        COUNT(*) AS collabs_count
    FROM raw.movies,
    LATERAL unnest(string_to_array("cast" ,',')) AS c(value),
    LATERAL unnest(string_to_array(director, ',')) AS d(value)
    GROUP BY trim(c.value), trim(d.value)
), 
target_cast AS (
    SELECT 
        show_id,
        trim(c.value) AS actor
    FROM raw.movies,
    LATERAL unnest(string_to_array("cast", ',')) AS c(value)
    WHERE director IS NULL
), 
votes AS (
    SELECT
        tc.show_id,
        dac.director,
        SUM(dac.collabs_count) AS frequency
    FROM target_cast tc
    INNER JOIN director_actor_collabs dac USING(actor)
    GROUP BY tc.show_id,  dac.director
),
rank_collabs AS (
    SELECT 
        show_id,
        director,
        frequency,
        ROW_NUMBER() OVER (PARTITION BY show_id ORDER BY frequency DESC) AS rnk
    FROM votes
    WHERE frequency > 1
) SELECT 
    show_id,
    director
FROM rank_collabs
WHERE rnk = 1;
