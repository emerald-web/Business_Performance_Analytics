/*
===================================================================
                   BUSINESS PERFORMANCE ANALYTICS
===================================================================
  Purpose:
  This SQL script performs data exploration 
  on curated datasets from the Gold Layer of the data warehouse. 
  The goal is to uncover patterns, performance metrics, and 
  business insights that drive strategic decision-making across teams.
  
  Target Stakeholders:
  - Finance Team → Revenue growth, profit margin, cost optimization
  - Sales Team → Sales trends, top-performing regions/products, growth rates
  - Marketing Team → Campaign performance, customer segmentation, retention
  - Product Team → Product performance, demand analysis, category insights
  - Executive Management → KPI dashboards and data-driven decisions
  
  Key Business KPIs:
  - Total Revenue and Profit Margin
  - Sales Growth Rate (YoY, MoM)
  - Top Performing Products and Categories
  - Customer Retention and Acquisition Metrics
  - Average Order Value (AOV)
  - Regional and Channel Performance
  - Marketing ROI and Conversion Rates
  
  Business Context:
  The analysis focuses on transforming clean, structured data 
  into actionable insights. These insights help various teams 
  understand performance trends, identify opportunities for 
  growth, and make informed business decisions.
  
  Technical Overview:
  - Uses SQL for data analysis and aggregation
  - Built on top of the Gold Layer (business-ready data)
  - Designed for integration with BI tools (Power BI, Tableau)
  - Provides a foundation for dashboard metrics and reporting

===================================================================
*/




/*
===================================================================
					DATABASE EXPLORATION (EDA)
===================================================================
*/

-- Explore All Objects in the Database

SELECT * FROM INFORMATION_SCHEMA.TABLES


--Explore All Columns in the Database
SELECT * FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'dim_customers'



/*
===================================================================
					DIMENSION EXPLORATION (EDA)
===================================================================
*/



-- Explore all Countries our customer come from

SELECT DISTINCT country FROM gold.dim_customers

-- Explore all categories "the major divisions"

SELECT DISTINCT category, subcategory, product_name FROM gold.dim_products
ORDER BY 1, 2, 3


/*
===================================================================
					DATE EXPLORATION (EDA)
===================================================================
*/

-- find the date of the first and last order
-- how many years of sales are available

SELECT 
	MIN(order_date) AS first_order_date,
	MAX(order_date) AS last_order_date,
	DATEDIFF(YEAR, MIN(order_date), MAX(order_date)) AS order_range_years
FROM gold.fact_sales



SELECT 
	MIN(order_date) AS first_order_date,
	MAX(order_date) AS last_order_date,
	DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) AS order_range_months
FROM gold.fact_sales



--find the youngest and the oldest customers
SELECT
	MIN(birthdate) AS oldest_birthdate,
	DATEDIFF(YEAR, MIN(birthdate), GETDATE()) AS oldest_agge,
	MAX(birthdate) AS youngest_birthdate,
	DATEDIFF(YEAR, MAX(birthdate), GETDATE()) AS youngest_age
FROM gold.dim_customers


/*
===================================================================
						MEASURE EXPLORATION
===================================================================
*/

-- Find the total sales
SELECT SUM(sales_amount) AS total_sales FROM gold.fact_sales

-- Find how many item are sold
SELECT  SUM(quantity) total_quantity FROM gold.fact_sales

-- Find the average selling price
SELECT AVG(price) avg_price FROM gold.fact_sales

-- Find the total number of orders
SELECT COUNT(order_number) total_order FROM gold.fact_sales
SELECT COUNT(DISTINCT order_number) total_order FROM gold.fact_sales

-- Find the total number of products
SELECT COUNT(product_name) AS total_products FROM gold.dim_products
SELECT COUNT(DISTINCT product_name) AS total_products FROM gold.dim_products

-- Find the total number of customers
SELECT COUNT(customer_key) AS total_customers FROM gold.dim_customers

-- Find the total number of customers that has places an order
SELECT COUNT(DISTINCT customer_key) AS total_customers FROM gold.fact_sales



-- Generate a Report that shows all key metrics of the business

SELECT 'Total Sales ' as measure_name, SUM(sales_amount) AS measure_value FROM gold.fact_sales
UNION ALL
SELECT 'Total Quantity', SUM(quantity)  FROM gold.fact_sales
UNION ALL
SELECT 'Average Price', AVG(price)  FROM gold.fact_sales
UNION ALL
SELECT 'Total Nr. Orders', COUNT(DISTINCT order_number)  FROM gold.fact_sales
UNION ALL
SELECT 'Total Nr. Products', COUNT(product_name)  FROM gold.dim_products
UNION ALL
SELECT 'Total Nr. Customers', COUNT(customer_key)  FROM gold.dim_customers 



/*
===================================================================
						MAGNITUDE ANALYSIS
===================================================================
*/

-- Find the total customers by countries
SELECT
	country,
	COUNT(customer_key) AS total_customers
FROM gold.dim_customers
GROUP BY country
ORDER BY total_customers DESC

-- Find the total customer by gender
SELECT
	gender,
	COUNT(customer_key) AS total_customers
FROM gold.dim_customers
GROUP BY gender
ORDER BY total_customers DESC

--Find the total customer by marital status
SELECT
	marital_status,
	COUNT(customer_key) AS total_customers
FROM gold.dim_customers
GROUP BY marital_status
ORDER BY total_customers DESC

--Find total products by category
SELECT
	category,
	COUNT(product_key) total_products
FROM gold.dim_products
GROUP BY category
ORDER BY total_products DESC

-- What is the average cost of each category?
SELECT
	category,
	AVG(cost) avg_costs
FROM gold.dim_products
GROUP BY category
ORDER BY avg_costs DESC

--What is the total revenue generated for each category?
SELECT
	P.category,
	SUM(f.sales_amount) total_revenue
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p
ON f.product_key = p.product_key
GROUP BY p.category
ORDER BY total_revenue DESC


-- What is the total revenue generated by each customers
SELECT
	c.customer_key,
	c.first_name,
	c.last_name,
	SUM(f.sales_amount) AS total_revenue
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
ON c.customer_key = f.customer_key
GROUP BY
	c.customer_key,
	c.first_name,
	c.last_name
ORDER BY total_revenue DESC


-- What is the distribution of sold items across countries
SELECT
	c.country,
	SUM(f.quantity) AS total_sold_items
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
ON c.customer_key = f.customer_key
GROUP BY
	c.country
ORDER BY total_sold_items DESC



/*
===================================================================
						RANKING ANALYSIS
===================================================================
*/

-- WHich 5 products generate the highest revenue?

SELECT TOP 5
	p.product_name,
	SUM(f.sales_amount) total_revenue
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p
ON p.product_key = f.product_key
GROUP BY p.product_name
ORDER BY total_revenue DESC

-- using windows functions to get the same result and it is good for complex situations
SELECT *
FROM
(
	SELECT  
		p.product_name,
		SUM(f.sales_amount) total_revenue,
		ROW_NUMBER() OVER (ORDER BY SUM(f.sales_amount) DESC) AS rank_products
	FROM gold.fact_sales f
	LEFT JOIN gold.dim_products p
	ON p.product_key = f.product_key
	GROUP BY p.product_name
)t
WHERE rank_products <= 5


-- What are the 5 worst-performing products in terms of sales
SELECT TOP 5
	p.product_name,
	SUM(f.sales_amount) total_revenue
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p
ON p.product_key = f.product_key
GROUP BY p.product_name
ORDER BY total_revenue 


-- Find the top 10 customers that have generated the highest revenue
SELECT TOP 10
	c.customer_key,
	c.first_name,
	c.last_name,
	SUM(f.sales_amount) AS total_revenue
	FROM gold.fact_sales f
	LEFT JOIN gold.dim_customers c
	ON c.customer_key = f.customer_key
GROUP BY
	c.customer_key,
	c.first_name,
	c.last_name
ORDER BY total_revenue DESC

-- The 3 customers with the fewest orders placed
SELECT TOP  3
	c.customer_key,
	c.first_name,
	c.last_name,
	COUNT(DISTINCT order_number) AS total_orders
	FROM gold.fact_sales f
	LEFT JOIN gold.dim_customers c
	ON c.customer_key = f.customer_key
GROUP BY
	c.customer_key,
	c.first_name,
	c.last_name
ORDER BY total_orders 

