SELECT * FROM walmart;
DROP TABLE walmart;

SELECT COUNT(*) FROM walmart;


-- In which payment method is most used for transaction?

SELECT 
	DISTINCT payment_method,
	COUNT(*)
FROM walmart
GROUP BY payment_method;

-- How many numbers of stores are there?

SELECT COUNT(DISTINCT branch)
FROM walmart;

-- BUSINESS PROBLEMS:

/* Question-1: What are the different payment methods, and 
how many transactions and items were sold with each method? */

SELECT 
	DISTINCT payment_method,
	COUNT(*) AS no_payments,
	SUM(quantity) AS no_qty_sold
FROM walmart
GROUP BY payment_method;

/* Question-2: Which category received the highest average 
rating in each branch? */

SELECT * 
FROM
(	SELECT 
		branch,
		category,
		AVG(rating) AS avg_rating,
		RANK() OVER(PARTITION BY branch ORDER BY AVG(rating) DESC) AS rank
	FROM walmart
	GROUP BY 1,2
)
WHERE rank = 1
LIMIT 5;

/* Question-3: Question: What is the busiest day of the week for each branch 
based on transaction volume? */

SELECT date FROM walmart;

SELECT *
FROM
    (SELECT
        branch,
        TO_CHAR(TO_DATE(date, 'DD/MM/YY'), 'Day') AS day_name,
        COUNT(*) AS no_transactions,
        RANK() OVER(PARTITION BY branch ORDER BY COUNT(*) DESC) AS rank
    FROM walmart
    GROUP BY 1, 2
    ) subquery
WHERE rank = 1
LIMIT 5;

/* Question-4: How many items were sold through each payment method? */

SELECT 
	DISTINCT payment_method,
	SUM(quantity) AS no_qty_sold
FROM walmart
GROUP BY payment_method;

/* Question-5: What are the average, minimum, and maximum ratings for each 
category in each city? */

SELECT
	city, category,
	MIN(rating) AS min_rating,
	MAX(rating) AS max_rating,
	AVG(rating) AS avg_rating
FROM walmart
GROUP BY 1, 2
LIMIT 5;

/* Question-6: What is the total profit for each category, ranked from 
highest to lowest? */

SELECT
	category,
	SUM(total) AS total_revenue,
	SUM(total * profit_margin) AS profit
FROM walmart
GROUP BY 1;

/* Question-7: What is the most frequently used payment method 
in each branch? */

WITH cte
AS 
(SELECT 
	branch,
	payment_method,
	COUNT(*) AS total_trans,
	RANK() OVER(PARTITION BY branch ORDER BY COUNT(*) DESC) AS rank
FROM walmart
GROUP BY 1, 2
)
SELECT *
FROM cte
WHERE rank =1 
LIMIT 5;

/* Question-8: How many transactions occur in each shift (Morning, Afternoon, Evening)
across branches? */

SELECT 
	branch,
CASE
		WHEN EXTRACT (HOUR FROM(time::time)) < 12 THEN 'Morning'
		WHEN EXTRACT (HOUR FROM(time::time)) BETWEEN 12 AND 17 THEN 'Afternoon'
		ELSE 'Evening'
	END day_time,
	COUNT(*)
FROM walmart
GROUP BY 1, 2
ORDER BY 1, 3 DESC;

/* Question-9: Question: Which branches experienced the largest decrease in revenue compared to
the previous year? */
--> Revenue_Decrease_Ratio == (Last_Year_Revenue - Current_Year_Revenue)/Last_Year_Revenue * 100
-- For solve this problem firstly fromat the date and then extract the year from fornated date. 
SELECT *,
EXTRACT(YEAR FROM TO_DATE(date, 'DD/MM/YY')) as formated_date
FROM walmart

-- 2022 sales
WITH revenue_2022
AS
(
	SELECT 
		branch,
		SUM(total) as revenue
	FROM walmart
	WHERE EXTRACT(YEAR FROM TO_DATE(date, 'DD/MM/YY')) = 2022 
	GROUP BY 1
),
revenue_2023
AS
(
	SELECT 
		branch,
		SUM(total) as revenue
	FROM walmart
	WHERE EXTRACT(YEAR FROM TO_DATE(date, 'DD/MM/YY')) = 2023
	GROUP BY 1
)
SELECT 
	ls.branch,
	ls.revenue as last_year_revenue,
	cs.revenue as cr_year_revenue,
	ROUND(
		(ls.revenue - cs.revenue)::numeric/
		ls.revenue::numeric * 100, 
		2) as rev_dec_ratio
FROM revenue_2022 as ls
JOIN
revenue_2023 as cs
ON ls.branch = cs.branch
WHERE 
	ls.revenue > cs.revenue
ORDER BY 4 DESC
LIMIT 5;

