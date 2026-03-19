
-- =========================================================
-- House Sales Analysis in King County, USA
-- Author: Łukasz Trzeciak
-- Tools: PostgreSQL + DBeaver + Tableau
-- =========================================================


-- =========================================================
-- 1. DATA CLEANING
-- =========================================================

-- Check duplicate records by id and date
SELECT
    id,
    date,
    COUNT(*) AS total
FROM kc
GROUP BY id, date
HAVING COUNT(*) > 1;

-- Check houses sold multiple times
SELECT
    id,
    COUNT(*) AS total_sales
FROM kc
GROUP BY id
HAVING COUNT(*) > 1
ORDER BY total_sales DESC;

-- Replace unrealistic values
UPDATE kc
SET bathrooms = NULL
WHERE bathrooms = 0;

UPDATE kc
SET bedrooms = NULL
WHERE bedrooms = 0;

UPDATE kc
SET bedrooms = NULL
WHERE bedrooms > 20;


-- =========================================================
-- 2. MARKET OVERVIEW
-- =========================================================

-- Total sales
SELECT
    COUNT(*) AS total_sales
FROM kc;

-- Average price
SELECT
    ROUND(AVG(price), 0) AS average_price
FROM kc;

-- Median price
SELECT
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY price) AS median_price
FROM kc;

-- Revenue over month
SELECT
    EXTRACT(MONTH FROM date) AS month,
    SUM(price) AS total_revenue
FROM kc
GROUP BY month
ORDER BY month;

-- Revenue over year
SELECT
    EXTRACT(YEAR FROM date) AS year,
    SUM(price) AS total_revenue
FROM kc
GROUP BY year
ORDER BY year;

-- Average price per year
SELECT
    EXTRACT(YEAR FROM date) AS year,
    ROUND(AVG(price), 0) AS avg_price
FROM kc
GROUP BY year
ORDER BY year;

-- Price distribution
SELECT
    distribution,
    COUNT(*) AS total_houses
FROM (
    SELECT
        CASE
            WHEN price < 200000 THEN '<200k'
            WHEN price BETWEEN 200000 AND 400000 THEN '200k - 400k'
            WHEN price > 400000 AND price <= 600000 THEN '400k - 600k'
            WHEN price > 600000 AND price <= 800000 THEN '600k - 800k'
            ELSE '800k+'
        END AS distribution
    FROM kc
) t
GROUP BY distribution
ORDER BY distribution;


-- =========================================================
-- 3. PROPERTY CHARACTERISTICS
-- =========================================================

-- Average price vs bedrooms
SELECT
    bedrooms,
    COUNT(*) AS total_houses,
    ROUND(AVG(price), 0) AS avg_price,
    ROUND(
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY price)::numeric,
        0
    ) AS median_price
FROM kc
WHERE bedrooms IS NOT NULL
GROUP BY bedrooms
ORDER BY bedrooms;

-- Price vs bathrooms (rounded to 0.5)
SELECT
    ROUND(bathrooms * 2) / 2.0 AS bathrooms_group,
    COUNT(*) AS total_houses,
    ROUND(AVG(price), 0) AS avg_price
FROM kc
WHERE bathrooms IS NOT NULL
GROUP BY ROUND(bathrooms * 2) / 2.0
ORDER BY bathrooms_group;

-- Price vs sqft living
SELECT
    sqft_living,
    price
FROM kc
WHERE sqft_living IS NOT NULL
  AND price IS NOT NULL;

-- Price vs grade
SELECT
    grade,
    COUNT(*) AS total_houses,
    ROUND(AVG(price), 0) AS avg_price
FROM kc
GROUP BY grade
ORDER BY grade;

-- Price distribution by condition
SELECT
    condition,
    COUNT(*) AS total_houses,
    ROUND(AVG(price), 0) AS avg_price
FROM kc
GROUP BY condition
ORDER BY condition;


-- =========================================================
-- 4. LOCATION ANALYSIS
-- =========================================================

-- Average price by zipcode
SELECT
    zipcode,
    COUNT(*) AS total_houses,
    ROUND(AVG(price), 0) AS avg_price
FROM kc
GROUP BY zipcode
ORDER BY avg_price DESC;

-- Average price per sqft by zipcode
SELECT
    zipcode,
    ROUND(AVG(price / sqft_living), 2) AS avg_price_per_sqft
FROM kc
WHERE sqft_living IS NOT NULL
GROUP BY zipcode
ORDER BY avg_price_per_sqft DESC;

-- Top 10 most expensive areas
SELECT
    zipcode,
    ROUND(AVG(price), 0) AS avg_price
FROM kc
GROUP BY zipcode
ORDER BY avg_price DESC
LIMIT 10;

-- Map of properties
SELECT
    id,
    zipcode,
    lat,
    long,
    price
FROM kc
WHERE lat IS NOT NULL
  AND long IS NOT NULL;
