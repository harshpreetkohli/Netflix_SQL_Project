# Data Analysis of Netflix Movies and TV Shows Using SQL

![Netflix_logo](https://github.com/harshpreetkohli/Netflix_SQL_Project/blob/main/logo.png)


## Overview
This project focuses on an in-depth analysis of Netflix's movie and TV show dataset using SQL. The objective is to uncover valuable insights and address key business questions through data exploration and analysis. This README outlines the project's goals, business challenges, methodologies, findings, and conclusions in detail.

## Objectives
* Examine the distribution of content types (movies vs. TV shows).
* Identify the most frequent ratings for both movies and TV shows.
* Analyze content trends based on release years, countries, and durations.
* Explore and categorize content using specific criteria and keywords.

## Dataset
The data for this project is sourced from the Kaggle dataset:
* Dataset Link: [Netflix Dataset](https://www.kaggle.com/datasets/shivamb/netflix-shows?resource=download)

## Schema 
```sql
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
```
## Business Problems and Solutions

### 1.  Count the number of Movies vs TV Shows.

```sql
SELECT
	type,
	COUNT (*) AS total_content_type
FROM netflix
GROUP BY type;
```
Objective: to determine the distribution of content types on Netflix.

###  2. Find the most common rating for movies and TV shows

```sql
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
```
Objective: To identify the most frequently occurring rating for each type of content.

### 3. List all movies released in a specific year (e.g., 2020)

```sql
SELECT 
	title,
	type,
	release_year
FROM netflix
WHERE type = 'Movie' AND release_year = '2020';
```
Objective: To retrieve all movies released in a specific year.

### 4. Find the top 5 countries with the most content on Netflix

```sql
SELECT
	UNNEST(STRING_TO_ARRAY(country,', ')) AS new_country,
	COUNT(*)AS total_content
FROM netflix
GROUP BY new_country
ORDER BY total_content DESC
LIMIT 5;
```
Objective: To identify the top 5 countries with the highest number of content items.

### 5. Identify the longest movie

```sql
SELECT 
	title,
	type,
	CAST(REPLACE(duration, 'min', '') AS int) AS duration
FROM netflix
WHERE type = 'Movie' AND duration IS NOT NULL
ORDER BY duration DESC;
```
Objective: To find the movie with the longest duration.

### 6. Find content added in the last 5 years

```sql
SELECT *
FROM netflix
WHERE TO_DATE(date_added, 'Month DD, YYYY') >= CURRENT_DATE - INTERVAL '5 years'
```
Objective: To retrieve the content added in Netflix in the last 5 years.

### 7. Find all the movies/TV shows by director 'Martin Campbell'

```sql
SELECT
	title,
	type,
	director
FROM netflix
WHERE director ILIKE '%Martin Campbell%'
```
Objective: To list all content directed by 'Martin Campbell'

### 8. List all TV shows with more than 5 seasons

```sql
SELECT 
	title,
	type,
FROM netflix
WHERE type = 'TV Show' AND SPLIT_PART(duration, ' ', 1)::numeric> 5
```
Objective: To identify the TV shows with more than 5 seasons.

### 9. Count the number of content items in each genre

```sql
SELECT
	UNNEST(STRING_TO_ARRAY(listed_in,',')) AS genre,
	COUNT(*)AS total_content
FROM netflix
GROUP BY genre
ORDER BY total_content DESC
```
Objective: To count the number of content items in each genre.

### 10.Find each year and the average numbers of content release in India on netflix and return top 5 year with highest avg content release!

```sql
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
```
Objective: To calculate and rank years by the average number of content releases in India

### 11. List all movies that are documentaries

```sql
SELECT 
	title,
	listed_in,
	type
FROM netflix
WHERE type = 'Movie' AND listed_in ILIKE '%Documentaries%'
```
Objective: To retrieve all movies classified as documentaries.

### 12. Find all content without a director

```sql
SELECT *
FROM netflix
WHERE director IS NULL
```
Objective: To list content that does not have a director.

### 13. Find how many movies actor 'Will Smith' appeared in last 10 years!

```sql
SELECT *
FROM netflix
WHERE casts ILIKE '%Will Smith%' And type = 'Movie' AND release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10
```
Objective: To count the number of movies featuring 'Will Smith' in the last 10 years.

### 14. Find the top 10 actors who have appeared in the highest number of movies produced in India.

```sql
SELECT
	UNNEST(STRING_TO_ARRAY(casts,',')) AS actors,
	COUNT(*)AS total_movies
FROM netflix
WHERE country ILIKE '%India%'
GROUP BY actors
ORDER BY total_movies DESC
LIMIT 10;
```
Objective: To identify the top 10 actors with the most appearances in Indian-produced movies.

### 15. Categorize the content based on the presence of the keywords 'kill' and 'violence' in the description field. Label content containing these keywords as 'Bad' and all other content as 'Good'. Count how many items fall into each category.

```sql
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
```
Objective: To categorize content as 'Bad' if it contains 'kill' or 'violence' and 'Good' otherwise. Count the number of items in each category.

## Findings and Conclusion

* Content Distribution: The dataset showcases a diverse collection of movies and TV shows across various ratings and genres.
* Popular Ratings: Analyzing the most common ratings offers valuable insights into the target audience for Netflix content.
* Geographical Trends: Identifying top content-producing countries and analyzing India's average content releases reveal regional distribution patterns.
* Content Classification: Categorizing content based on specific keywords provides a deeper understanding of the types of content available on Netflix.
  
This analysis offers a comprehensive overview of Netflix's content landscape, helping to inform content strategy and decision-making.
