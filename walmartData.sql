CREATE DATABASE IF NOT EXISTS salesDataWalmart;

CREATE TABLE IF NOT EXISTS sales(
	invoice_id VARCHAR(30) NOT NULL PRIMARY KEY,
    branch VARCHAR(5) NOT NULL,
    city VARCHAR(30) NOT NULL,
    customer_tpe VARCHAR(30) NOT NULL,
    gender VARCHAR(10) NOT NULL,
    product_line VARCHAR(100) NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    quantity INT NOT NULL,
    VAT FLOAT(6,4) NOT NULL,
    total DECIMAL(10,2) NOT NULL,
    date DATETIME NOT NULL,
    time TIME NOT NULL,
    payment_method VARCHAR(15) NOT NULL,
    cogs DECIMAL(10,2) NOT NULL,
    gross_margin_pct FLOAT(11,9),
    gross_income DECIMAL(12,2) NOT NULL,
    rating FLOAT(2,1) NOT NULL
);


-- ------------------------------------------------------------------------------------------------
-- -------------------------------- Feature Engineering -------------------------------------------

-- time_of_day

SELECT 
	time,
	(CASE
		WHEN TIME(time) BETWEEN "00:00:00" AND "12:00:00" THEN "Morning"
        WHEN TIME(time) BETWEEN "12:01:00" AND "16:00:00" THEN "Afternoon"
        ELSE "Evening"
	 END
     ) AS time_of_day
FROM sales;

ALTER TABLE sales ADD COLUMN time_of_day VARCHAR(20);

UPDATE sales
SET time_of_day = (
	CASE
		WHEN TIME(time) BETWEEN "00:00:00" AND "12:00:00" THEN "Morning"
        WHEN TIME(time) BETWEEN "12:01:00" AND "16:00:00" THEN "Afternoon"
        ELSE "Evening"
	 END
);


-- day_name 

SELECT
	date,
    DAYNAME(date) as day_name
FROM sales;

ALTER TABLE sales ADD COLUMN day_name VARCHAR(10);

UPDATE 
	sales
SET day_name = DAYNAME(date);


-- month_name

SELECT 
	date,
    monthname(date) as month_name
FROM sales;

ALTER TABLE sales ADD COLUMN month_name VARCHAR(20);

UPDATE 
	sales
SET month_name = monthname(date);

-- -------------------------------------------------------------------------------------------------
-- ------------------------------------- Generic Questions -------------------------------------

-- What are the unique cities?
SELECT 
	DISTINCT CITY
FROM sales;

-- What are the unique branchs?
SELECT
	DISTINCT branch
FROM sales;

-- In which city is each branch?
SELECT 
	DISTINCT city,
    branch
FROM sales;

-- -------------------------------------------------------------------------------------------
-- ------------------------------------ Product ----------------------------------------------

-- How many unique product lines does the data have?
SELECT 
	COUNT(DISTINCT product_line)
FROM sales;

-- What is the most common payment method?
SELECT
	payment_method,
	count(payment_method) AS cnt
FROM sales
GROUP BY payment_method
ORDER BY cnt DESC;

-- What is the most selling product line?
SELECT
	product_line,
    COUNT(product_line) as cnt
FROM sales
GROUP BY product_line
ORDER BY cnt DESC;

-- What is the total revenue by month
SELECT 
	month_name AS month,
    SUM(total) AS total_sales
FROM sales
GROUP BY month
ORDER BY total_sales DESC;

-- What month as the largest COGS
SELECT
	month_name AS month,
    SUM(COGS) as sum_cogs
FROM sales
GROUP BY month
ORDER BY sum_cogs DESC;

-- What product line had the largest revenue?
SELECT
	product_line,
    SUM(total) as revenue
FROM sales
GROUP BY product_line
ORDER BY revenue DESC;

-- What is the city with the largest revenue?
SELECT 
	branch,
	city,
    SUM(total) AS total_revenue
FROM sales
GROUP BY city, branch
ORDER BY total_revenue DESC;

-- What product line had the largest VAT?
SELECT
	product_line,
    AVG(VAT) AS avg_tax
FROM sales
GROUP BY product_line
ORDER BY avg_tax DESC;

-- Fetch each product line and add a column to those product line showing "Good", "Bad".
-- Good if its greater than average sales


-- Which branch sold more products than average product sold
SELECT
	branch,
    SUM(quantity) as sum_quantity
FROM sales
GROUP BY branch
HAVING (sum_quantity) > (SELECT AVG(quantity) FROM sales);

-- What is the most common product line by gender
SELECT
	gender,
    product_line,
    COUNT(gender) AS total_gender
FROM sales
GROUP BY gender, product_line
ORDER BY total_gender DESC;

-- What is the average rating of each product line?
SELECT
	product_line,
	ROUND(AVG(rating),2) as avg_rating
FROM sales
GROUP BY product_line
ORDER BY avg_rating DESC;

-- -----------------------------------------------------------------------------------------
-- ---------------------------------------- Sales ------------------------------------------

-- Number of sales made in each time of the day per weekday
SELECT
	time_of_day,
    COUNT(*) AS total_sales
FROM sales
WHERE day_name = 'Sunday'
GROUP BY time_of_day
ORDER BY total_sales DESC;

-- Which of the customer types brings the most revenue?
SELECT
	customer_tpe,
    SUM(total) AS total_sales
FROM sales
GROUP BY customer_tpe
ORDER BY total_sales DESC;
    
-- Which city has the largest VAT or Tax?
SELECT
	city,
    AVG(VAT) as tax
FROM sales
GROUP BY city
ORDER BY tax DESC;

-- Which customer type pays the most in VAT?
SELECT
	customer_tpe,
    SUM(VAT) as tax
FROM sales
GROUP BY customer_tpe
ORDER BY tax DESC;

-- ---------------------------------------------------------------------------
-- ------------------------- Customer ----------------------------------------

-- How many unique customer type does the data have?
SELECT
	COUNT(DISTINCT(customer_tpe)) AS Number_Of_Customer_Type
FROM sales;

-- How many unique payment methods does the data have?
SELECT
	COUNT(DISTINCT(payment_method))
FROM sales;

-- What is the most common customer type?
SELECT
	customer_tpe,
    COUNT(customer_tpe) AS total_customer_type
FROM sales
GROUP BY customer_tpe
ORDER BY total_customer_type DESC;

-- Which customer type buys the most?
SELECT
	customer_tpe,
    COUNT(*) AS customer_count
FROM sales
GROUP BY customer_tpe
ORDER BY customer_count DESC;

-- What gender of most of the customers?
SELECT
	gender,
    COUNT(*) AS total
FROM sales
GROUP BY gender
ORDER BY total DESC;

-- What is the gender distribution for branch A?
SELECT
	gender,
    COUNT(*) AS total
FROM sales
WHERE branch = 'A'
GROUP BY gender, branch
ORDER BY total DESC;

-- What is the gender distribution per branch?
SELECT
	branch,
	SUM(CASE WHEN gender ='Male' THEN 1 ELSE 0 END) AS male_count,
	SUM(CASE WHEN gender ='Female' THEN 1 ELSE 0 END) AS female_count
FROM sales
GROUP BY branch;

-- What time of day do customers give most ratings?
SELECT
	time_of_day,
	COUNT(rating) as rating_cnt
FROM sales
GROUP BY time_of_day
ORDER BY rating_cnt DESC;

-- What time of day do customers give most ratings per branch?
SELECT
	branch,
	time_of_day,
    AVG(rating) as avg_rating
FROM sales
GROUP BY time_of_day, branch
ORDER BY branch, time_of_day DESC;

-- Which day of the week has the best avg ratings?
SELECT
	day_name,
    AVG(rating) as avg_rating
FROM sales
GROUP BY day_name
ORDER BY avg_rating DESC;
    
-- Which day of the week has the best average ratings per branch?
SELECT
	branch,
	day_name,
    AVG(rating) as avg_rating
FROM sales
GROUP BY day_name, branch
ORDER BY avg_rating DESC;

-- Which day of the week has the best average ratings for branch C?
SELECT
	day_name,
    AVG(rating) as avg_rating
FROM sales
WHERE branch = 'C'
GROUP BY day_name
ORDER BY avg_rating DESC;
    







