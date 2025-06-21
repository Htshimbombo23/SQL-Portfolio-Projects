-- Data Exploration Analysis

-- Converting sales and score data type to INT

SELECT *
FROM sales3;

UPDATE sales3
SET total_sales = NULL
WHERE total_sales = "";

ALTER TABLE sales3
MODIFY COLUMN total_sales INT;

UPDATE sales3
SET na_sales = NULL
WHERE na_sales = "";

ALTER TABLE sales3
MODIFY COLUMN na_sales INT;

UPDATE sales3
SET jp_sales = NULL
WHERE jp_sales = "";

ALTER TABLE sales3
MODIFY COLUMN jp_sales INT;

UPDATE sales3
SET pal_sales = NULL
WHERE pal_sales = "";

ALTER TABLE sales3
MODIFY COLUMN pal_sales INT;

UPDATE sales3
SET other_sales = NULL
WHERE other_sales = "";

ALTER TABLE sales3
MODIFY COLUMN other_sales INT;

UPDATE sales3
SET critic_score = NULL
WHERE critic_score = "";

ALTER TABLE sales3
MODIFY COLUMN critic_score INT;

-- Aggregation Analysis

SELECT *
FROM sales3;

-- Highest total sales and Highest critic score

SELECT MAX(total_sales), MAX(critic_score)
FROM sales3;

-- Identifying all game titles with a perfect score

SELECT DISTINCT title, genre, publisher, critic_score
FROM sales3
WHERE critic_score = 10;

SELECT DISTINCT title,console, genre, publisher, critic_score, total_sales
FROM sales3
WHERE critic_score = 10
ORDER BY total_sales desc;

-- The highest selling game did not have a perfect score so I identified the critic score of the highest selling game

SELECT DISTINCT title,console, genre, publisher, critic_score, total_sales
FROM sales3
WHERE total_sales = 20
ORDER BY critic_score DESC;

-- Exploring total sales by genre, console, publisher, year

SELECT genre, SUM(total_sales) as genre_sales_total
FROM sales3
GROUP BY genre
ORDER BY genre_sales_total DESC;

SELECT console, SUM(total_sales) as console_sales_total
FROM sales3
GROUP BY console
ORDER BY console_sales_total DESC;

SELECT publisher, SUM(total_sales) as publisher_sales_total
FROM sales3
GROUP BY publisher
ORDER BY publisher_sales_total DESC;

SELECT YEAR(release_date) AS release_year, SUM(total_sales) AS year_sales
FROM sales3
GROUP BY release_year
ORDER BY year_sales desc;


-- How many games has rockstar released on each console

SELECT *
FROM sales3
WHERE publisher LIKE '%rockstar%';

SELECT console, COUNT(title) as count_title
FROM sales3
WHERE publisher LIKE '%rockstar%'
GROUP BY console
ORDER BY count_title desc;


-- Identifying the highest selling game each year
WITH title_year (year, title, console, total_sales) AS 
(
SELECT YEAR(release_date), title, console, SUM(total_sales)
FROM sales3
GROUP BY YEAR(release_date), title, console
), title_year_rank AS 
(
SELECT *, DENSE_RANK() OVER(
PARTITION BY year ORDER BY total_sales desc) AS title_rank
FROM title_year
WHERE total_sales > 0
)
SELECT *
FROM title_year_rank
WHERE title_rank = 1
ORDER BY year desc;

-- Taking it one step further we can also identify which games held the number 1 rank in multiple years

WITH title_year (year, title, console, total_sales) AS 
(
SELECT YEAR(release_date), title, console, SUM(total_sales)
FROM sales3
GROUP BY YEAR(release_date), title, console
), title_year_rank AS 
(
SELECT *, DENSE_RANK() OVER(
PARTITION BY year ORDER BY total_sales desc) AS title_rank
FROM title_year
WHERE total_sales > 0
), best_sellers AS 
(SELECT *
FROM title_year_rank
WHERE title_rank = 1
ORDER BY year desc)
SELECT title, COUNT(title)
FROM best_sellers
GROUP BY title
HAVING COUNT(title) > 1;

-- Avg Total Sales by Genre

SELECT *
FROM sales3;

SELECT genre, AVG(total_sales), YEAR(release_date)
FROM sales3
GROUP BY genre, YEAR(release_date);

WITH genre_avg_sales (genre, avg_sales,years) AS 
(
SELECT genre, AVG(total_sales), YEAR(release_date)
FROM sales3
GROUP BY genre, YEAR(release_date)
HAVING avg(total_sales) IS NOT NULL
), avg_ranking AS
(SELECT *, DENSE_RANK () OVER(
PARTITION BY years ORDER BY avg_sales desc) AS ranking
FROM genre_avg_sales)
SELECT *
FROM avg_ranking
WHERE ranking = 1
ORDER BY years desc;


-- Taking it a step further we can find how many times a genre had the highest avg sales for the past 10 years

WITH genre_avg_sales (genre, avg_sales,years) AS 
(
SELECT genre, AVG(total_sales), YEAR(release_date)
FROM sales3
GROUP BY genre, YEAR(release_date)
HAVING avg(total_sales) IS NOT NULL
), avg_ranking AS
(SELECT *, DENSE_RANK () OVER(
PARTITION BY years ORDER BY avg_sales desc) AS ranking
FROM genre_avg_sales), top_genre AS 
(
SELECT *
FROM avg_ranking
WHERE ranking = 1
ORDER BY years desc
)
SELECT genre, COUNT(genre)
FROM top_genre
WHERE years BETWEEN 2010 AND 2020
GROUP BY genre;


-- Which playstation console had the highest average game title score
-- Which gaming year had the highest average score? 
-- Who are the top 5 ppublishers according to critic score? 

SELECT *
FROM sales3;

SELECT console, AVG(critic_score) AS avg_score
FROM sales3
WHERE console LIKE 'PS%'
GROUP BY console
HAVING avg(critic_score) IS NOT NULL
ORDER BY AVG(critic_score) desc;

SELECT YEAR(release_date) AS years, AVG(critic_score), RANK () OVER(
ORDER BY AVG(critic_score) desc) AS ranking
FROM sales3
WHERE year(release_date) BETWEEN 2000 AND 2024
GROUP BY years
HAVING AVG(critic_score) IS NOT NULL;


WITH publisher_ranking (publisher, avg_score, ranking) AS (
SELECT publisher, AVG(critic_score), RANK () OVER(
ORDER BY AVG(critic_score) desc) AS ranking
FROM sales3
GROUP BY publisher
HAVING AVG(critic_score) IS NOT NULL)
SELECT *
FROM publisher_ranking
WHERE ranking <= 5;


-- Too many results on the first publisher ranking so we want to add a criteria for the amount of title they have published

SELECT publisher, COUNT(title)
FROM sales3
GROUP BY publisher
ORDER BY COUNT(title) DESC;

WITH one_hundred_titles (publisher, count_title) AS 
(
SELECT publisher, COUNT(title)
FROM sales3
WHERE critic_score IS NOT NULL
GROUP BY publisher
HAVING COUNT(title) >= 100
ORDER BY COUNT(title) DESC
)
SELECT COUNT(*)
FROM one_hundred_titles;


WITH publisher_ranking (publisher, count_title, avg_score, ranking) AS (
SELECT publisher, COUNT(title), AVG(critic_score), RANK () OVER(
ORDER BY AVG(critic_score) desc) AS ranking
FROM sales3
GROUP BY publisher
HAVING AVG(critic_score) IS NOT NULL
AND COUNT(title) >= 100)
SELECT *
FROM publisher_ranking
WHERE ranking <= 5;
