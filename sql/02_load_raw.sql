COPY raw.movies
FROM '/data/netflix_titles.csv'
DELIMITER ','
CSV HEADER;
