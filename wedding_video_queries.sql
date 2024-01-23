USE wedding_video_company_db;

-- 1. 
-- Calculate total revenue by month over the latest year, sorted by revenue in descending order

WITH CTE AS (
	SELECT
		booked_date,
		order_amount
	FROM orders
	WHERE
		YEAR(booked_date) = (SELECT MAX(YEAR(booked_date)) FROM orders)
)

SELECT
	SUM(order_amount) AS 'Total Revenue',
    DATE_FORMAT(booked_date, "%M") AS month,
    YEAR(booked_date) AS year
FROM CTE
GROUP BY MONTH(booked_date), Year(booked_date), month
ORDER BY 1 DESC;



-- 2.
-- Calculate total revenue for each package type over the past 12 months, sorted by revenue in descending order

WITH CTE AS
(
	SELECT
		booked_date,
		order_amount,
		package_type
	FROM orders
	WHERE booked_date >= DATE_SUB((SELECT MAX(booked_date) FROM orders), INTERVAL 12 Month)
)

SELECT package_type, SUM(order_amount) AS 'Total Revenue'
FROM CTE
GROUP BY package_type
ORDER BY 2 DESC;

-- 3.
-- Identify videographers who shot the most weddings for each of the past 3 years (based on wedding_date),
-- along with their number of weddings and total videographer pay

WITH CTE AS (
	SELECT
		t.first_name, t.last_name, o.videographer_id, 
		COUNT(o.order_id) AS wedding_count,
		YEAR(o.wedding_date) AS year,
		SUM(o.videographer_amount) AS videographer_total_amount,
		RANK() OVER (PARTITION BY YEAR(o.wedding_date) ORDER BY COUNT(o.order_id) DESC) AS wedding_count_rank
	FROM orders o
	JOIN team t USING (videographer_id)
	WHERE YEAR(o.wedding_date) >= YEAR((SELECT MAX(wedding_date) FROM orders)) - 2
	GROUP BY videographer_id, YEAR(o.wedding_date)
)

SELECT year, first_name, last_name, videographer_id, wedding_count, videographer_total_amount
FROM CTE
WHERE wedding_count_rank = 1
ORDER BY year;

-- 4.
-- Compare the number of weddings held in Q1 (January-March) and Q4 (October-December) for each year
SELECT 
	YEAR(wedding_date) AS 'Year',
	SUM(CASE WHEN MONTH(wedding_date) IN (1,2,3) THEN 1 ELSE 0 END) AS 'Q1 Wedding Count',
	SUM(CASE WHEN MONTH(wedding_date) IN (10,11,12) THEN 1 ELSE 0 END) AS 'Q4 Wedding Count'
FROM
	orders
GROUP BY YEAR(wedding_date)
ORDER BY 1;

-- 5.
-- Identify the month with the most weddings for each year

WITH CTE AS (
	SELECT 
		COUNT(order_id) AS wedding_count,
		RANK() OVER (PARTITION BY YEAR(wedding_date) ORDER BY COUNT(order_id) DESC) AS count_ranking,
		MONTH(wedding_date) AS month,
		YEAR(wedding_date) AS year
	FROM
	orders
	GROUP BY MONTH(wedding_date), YEAR(wedding_date)
)

SELECT wedding_count AS "Wedding Count", month AS "Month", year AS "Year"
FROM CTE
WHERE count_ranking = 1;

-- 6.
-- For each year, 
-- find the month with the highest and lowest number of bookings
-- include the average package price for the selected months
WITH CTE AS (
	SELECT
		DATE_FORMAT(booked_date, '%M') AS month,
		YEAR(booked_date) AS year,
		RANK() OVER (PARTITION BY YEAR(booked_date) ORDER BY COUNT(order_id) DESC) as count_ranking,
		AVG(order_amount) AS avg_order_amount,
		COUNT(order_id) AS booking_count
	FROM orders
	GROUP BY month, YEAR(booked_date)
)

SELECT 
	year,
	MAX(booking_count) OVER (PARTITION BY year) AS max_month_bookings,
	MIN(booking_count) OVER (PARTITION BY year) AS min_month_bookings,
	CASE WHEN count_ranking = 1 THEN month END AS highest_booking_month,
	CASE WHEN count_ranking = 12 THEN month END AS lowest_booking_month,
	ROUND(avg_order_amount, 2) AS avg_package_price
FROM CTE
WHERE count_ranking IN (1, 12);

-- 7.
-- Show email, phone number, full name, and wedding date for clients with Florida or Pennsylvania weddings
-- sorted by state then name (ascending)

SELECT c.first_name, c.last_name, c.email, c.phone_number, o.wedding_date, o.venue_state
FROM orders o
JOIN customers c USING (customer_id)
WHERE o.venue_state IN ('Florida', 'Pennsylvania')
ORDER BY o.venue_state, c.first_name;

-- 8.
-- Identify the most popular wedding video package for each year 
-- display the package name instead of the package_type
-- package key: 
-- if package_type = 1 then package name = The Memoir
-- if package_type = 2 then package name = The Standard
-- if package_type = 3 then package name = The Luxury

WITH CTE AS (
	SELECT 
		COUNT(order_id) AS wedding_count,
		CASE 
			WHEN package_type = 1 THEN 'The Memoir'
			WHEN package_type = 2 THEN 'The Standard'
			WHEN package_type = 3 THEN 'The Luxury'
			END AS package_name,
		RANK() OVER (PARTITION BY YEAR(booked_date) ORDER BY COUNT(order_id) DESC) AS package_rank,
		YEAR(booked_date) AS year
	FROM orders
	GROUP BY package_type, YEAR(booked_date)
	ORDER BY YEAR(booked_date) DESC
)
SELECT package_name AS 'Package Name', wedding_count AS 'Number of Weddings', year AS 'Year'
FROM CTE
WHERE package_rank = 1;

-- 9.
-- Identify the month with the highest MoM increase for each year
-- MoM formula: month_total_package_amount - previous_month_total_package_amount


WITH MonthlyTotalAmount AS (
	SELECT
		SUM(order_amount) total_month_amount, 
		month(booked_date) AS month,
		year(booked_date) AS year
	FROM orders
	GROUP BY year(booked_date), month(booked_date)
	ORDER BY year(booked_date), month(booked_date)
),
MoMComparison AS (
	SELECT
		total_month_amount AS month_total,
		lag(total_month_amount) OVER () AS previous_month_total,
		year, month,
		total_month_amount-lag(total_month_amount) OVER () AS mom
	FROM MonthlyTotalAmount
)

SELECT month, year, mom AS 'MoM Increase', month_total, previous_month_total
FROM 
	(SELECT
		RANK() OVER (PARTITION BY year ORDER BY mom DESC) as mom_rank,
		mom, year, month, month_total, previous_month_total
	FROM MoMComparison) as subquery
WHERE mom_rank = 1



