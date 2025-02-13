-- Netflix Project

CREATE TABLE netflix 
( 
	show_id VARCHAR(6),
    type	VARCHAR(10),
    title VARCHAR(150),
	director VARCHAR(220),
	casts	VARCHAR(1000),
    country VARCHAR(150),
	date_added VARCHAR(50),
	release_year INT,
	rating VARCHAR (15),
	duration VARCHAR(15),
	listed_in VARCHAR(100),
	description VARCHAR(300)
);

SELECT * FROM netflix;

-- 1. Count the number of Movies vs TV Shows

SELECT
	type,
	COUNT (*) AS total_content_type
FROM netflix
GROUP BY type;

-- 2. Find the most common rating for movies and TV shows

SELECT
	type,
	rating
FROM
(
SELECT 
	type,
	rating,
	COUNT (*),
	RANK() OVER(PARTITION BY type ORDER BY COUNT(*)DESC) AS ranking
FROM netflix
GROUP BY type, rating
) AS t1
WHERE ranking = 1;

-- 3. List all movies released in a specific year (e.g., 2020)

SELECT 
	title,
	type,
	release_year
FROM netflix
WHERE type = 'Movie' AND release_year = '2020';

-- 4. Find the top 5 countries with the most content on Netflix

SELECT
	UNNEST(STRING_TO_ARRAY(country,', ')) AS new_country,
	COUNT(*)AS total_content
FROM netflix
GROUP BY new_country
ORDER BY total_content DESC
LIMIT 5;

-- 5. Identify the longest movie

SELECT 
	title,
	type,
	CAST(REPLACE(duration, 'min', '') AS int) AS duration
FROM netflix
WHERE type = 'Movie' AND duration IS NOT NULL
ORDER BY duration DESC;

-- 6. Find content added in the last 5 years

SELECT *
FROM netflix
WHERE TO_DATE(date_added, 'Month DD, YYYY') >= CURRENT_DATE - INTERVAL '5 years'

-- 7. Find all the movies/TV shows by director 'Martin Campbell'!

SELECT
	title,
	type,
	director
FROM netflix
WHERE director ILIKE '%Martin Campbell%'

-- 8. List all TV shows with more than 5 seasons

SELECT 
	title,
	type,
FROM netflix
WHERE type = 'TV Show' AND SPLIT_PART(duration, ' ', 1)::numeric> 5

-- 9. Count the number of content items in each genre

SELECT
	UNNEST(STRING_TO_ARRAY(listed_in,',')) AS genre,
	COUNT(*)AS total_content
FROM netflix
GROUP BY genre
ORDER BY total_content DESC

-- 10.Find each year and the average numbers of content release in India on netflix. 
-- return top 5 year with highest avg content release!

SELECT
	EXTRACT(YEAR FROM TO_DATE(date_added, 'Month, DD, YYYY')) AS year,
	COUNT(*) AS total_content_per_year,
	ROUND(
	COUNT(*)::numeric/(SELECT 
	COUNT (*) AS total_content
	FROM netflix
	WHERE country ILIKE '%India%')::numeric * 100,2) AS avg_content_per_year
FROM netflix
WHERE country ILIKE '%India%'
GROUP BY 1
ORDER BY avg_content_per_year DESC
LIMIT 5;

-- 11. List all movies that are documentaries

SELECT 
	title,
	listed_in,
	type
FROM netflix
WHERE type = 'Movie' AND listed_in ILIKE '%Documentaries%'

-- 12. Find all content without a director

SELECT *
FROM netflix
WHERE director IS NULL

-- 13. Find how many movies actor 'Will Smith' appeared in last 10 years!

SELECT *
FROM netflix
WHERE casts ILIKE '%Will Smith%' And type = 'Movie' AND release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10

-- 14. Find the top 10 actors who have appeared in the highest number of movies produced in India.

SELECT
	UNNEST(STRING_TO_ARRAY(casts,',')) AS actors,
	COUNT(*)AS total_movies
FROM netflix
WHERE country ILIKE '%India%'
GROUP BY actors
ORDER BY total_movies DESC
LIMIT 10;

-- 15. Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
--the description field. Label content containing these keywords as 'Bad' and all other 
--content as 'Good'. Count how many items fall into each category.

SELECT 
    category,
	TYPE,
    COUNT(*) AS content_count
FROM (
    SELECT 
		*,
        CASE 
            WHEN description ILIKE '%kill%' OR description ILIKE '%violence%' THEN 'Bad'
            ELSE 'Good'
        END AS category
    FROM netflix
) AS categorized_content
GROUP BY category,type
ORDER BY type