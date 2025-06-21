-- Data Cleaning

SELECT *
FROM sales;

-- Preserving Raw data

CREATE TABLE sales2
LIKE sales;

INSERT sales2
SELECT *
FROM sales;

-- Dropping img column as it is not a required column for analysis

ALTER TABLE sales2
DROP COLUMN img;

SELECT *
FROM sales2;

-- Searching for duplicate values

SELECT *, ROW_NUMBER() OVER (
PARTITION BY title, console,genre,publisher,developer,critic_score,total_sales,na_sales,jp_sales,other_sales,release_date,last_update) AS row_num
FROM sales2;

WITH duplicate_cte AS (
SELECT *, ROW_NUMBER() OVER (
PARTITION BY title, console,genre,publisher,developer,critic_score,total_sales,na_sales,jp_sales,other_sales,release_date,last_update) AS row_num
FROM sales2)
SELECT *
FROM duplicate_cte
WHERE row_num > 1;

CREATE TABLE `sales3` (
  `title` text,
  `console` text,
  `genre` text,
  `publisher` text,
  `developer` text,
  `critic_score` text,
  `total_sales` text,
  `na_sales` text,
  `jp_sales` text,
  `pal_sales` text,
  `other_sales` text,
  `release_date` text,
  `last_update` text,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT INTO sales3
SELECT *, ROW_NUMBER() OVER (
PARTITION BY title, console,genre,publisher,developer,critic_score,total_sales,na_sales,jp_sales,other_sales,release_date,last_update) AS row_num
FROM sales2;

SELECT *
FROM sales3;

SELECT *
FROM sales3
WHERE row_num > 1;

DELETE
FROM sales3
WHERE row_num > 1;

SELECT *
FROM sales3
WHERE title = 'g-police';

SELECT DISTINCT console
FROM sales3
ORDER BY console;


-- Null/Blank Values

SELECT COUNT(*)
FROM sales3;

SELECT *
FROM sales3
WHERE critic_score = ""
AND total_sales = "";

DELETE 
FROM sales3
WHERE critic_score = ""
AND total_sales = "";

ALTER TABLE sales3
DROP COLUMN row_num;

SELECT *
FROM sales3;

-- Example of standardising data

-- Stanardising Publisher Names

SELECT DISTINCT publisher
FROM sales3
ORDER BY publisher;

SELECT DISTINCT publisher
FROM sales3
WHERE publisher LIKE '%namco%';

UPDATE sales3
SET publisher = 'Bandai Namco'
WHERE publisher LIKE '%namco%';

SELECT release_date,
STR_TO_DATE (release_date, '%m/%d/%Y')
FROM sales3
WHERE release_date = '';

UPDATE sales3
SET release_date = NULL
WHERE release_date = "";

ALTER TABLE sales3
MODIFY COLUMN release_date DATE;





