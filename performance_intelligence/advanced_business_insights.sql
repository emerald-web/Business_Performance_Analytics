/*
===================================================================
                   ADVANCED BUSINESS INSIGHTS ANALYSIS
===================================================================
  Purpose:
  This SQL script delivers advanced analytical insights on curated 
  datasets from the Gold Layer of the data warehouse. It focuses on 
  evaluating business performance trends, growth metrics, 
  segmentation patterns, and proportional contributions across 
  products, customers, and time periods.

  Target Stakeholders:
  - Finance Team → Revenue growth, YoY comparisons, and profitability tracking
  - Sales Team → Trend analysis, customer value segmentation, and regional impact
  - Marketing Team → Customer behavior segmentation and retention insights
  - Product Team → Product lifecycle, contribution analysis, and cost-based performance
  - Executive Management → Strategic performance overview and long-term growth evaluation

  Key Business KPIs:
  - Year-over-Year (YoY) and Month-over-Month (MoM) Growth Rates
  - Cumulative Sales and Average Order Value (AOV) Over Time
  - Product and Category Contribution to Total Revenue
  - Customer Segmentation by Lifetime Value and Engagement
  - Performance vs. Average Benchmarks (Above/Below Avg Analysis)
  - Market Share Distribution (Part-to-Whole Analysis)

  Business Context:
  This analysis advances from foundational EDA to uncover deeper 
  performance intelligence. It identifies growth opportunities, 
  high-value customer groups, top-performing categories, and 
  product efficiency. The results guide strategic decision-making 
  across departments and enhance forecasting accuracy.

  Technical Overview:
  - Built on the Gold Layer of the Medallion Architecture
  - Utilizes SQL window functions (LAG, AVG, SUM OVER) for trend & cumulative analysis
  - Implements CTEs for segmentation, proportional contribution, and performance tracking
  - Designed for integration into BI dashboards (Power BI, Tableau)
  - Provides ready-to-use datasets for strategic reporting and forecasting

===================================================================
*/



/*
==========================================================
			      Change Over Time
==========================================================
*/

--Analyze the sales perfromance over time--

SELECT 
	YEAR(order_date) as order_year,
	SUM(sales_amount) AS total_sales,
	COUNT(DISTINCT customer_key) as total_customers,
	SUM(quantity) as total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY YEAR(order_date)
ORDER BY YEAR(order_date)


--Analyze the sales perfromance over time by month--

SELECT 
	MONTH(order_date) as order_year,
	SUM(sales_amount) AS total_sales,
	COUNT(DISTINCT customer_key) as total_customers,
	SUM(quantity) as total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY MONTH(order_date)
ORDER BY MONTH(order_date)


--Analyze the sales perfromance over time by month of specific year--
SELECT 
	YEAR(order_date) as order_year,
	MONTH(order_date) as order_month,
	SUM(sales_amount) AS total_sales,
	COUNT(DISTINCT customer_key) as total_customers,
	SUM(quantity) as total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY YEAR(order_date), MONTH(order_date)
ORDER BY YEAR(order_date), MONTH(order_date)



--Analyze the sales perfromance over time by month of specific year(datetrunc())--
SELECT 
	DATETRUNC(month, order_date) as order_year,
	SUM(sales_amount) AS total_sales,
	COUNT(DISTINCT customer_key) as total_customers,
	SUM(quantity) as total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY DATETRUNC(month, order_date)
ORDER BY DATETRUNC(month, order_date)



/*
==========================================================
			     Culmulative Analysis
==========================================================
*/

--calculate the total sales per month 
-- and the running total of sales over time
-- average running total

SELECT
	order_date,
	total_sales,
	SUM(total_sales) OVER(ORDER BY order_date) AS running_total_sales,
	AVG(avg_price) OVER(ORDER BY order_date) AS moving_average_price
FROM(
SELECT
	DATETRUNC(year,order_date) AS order_date,
	SUM(sales_amount) AS total_sales,
	AVG(price) AS avg_price
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY DATETRUNC(year, order_date)
)t


/*
==========================================================
			     Performance Analysis
==========================================================
*/

--Analyze the yearly performance of products by comparing their sales
--To both the average sales performance of the product and the previous year's sales

WITH yearly_product_sales AS
(
SELECT
	YEAR(f.order_date) AS order_year,
	p.product_name,
	SUM(f.sales_amount) AS current_sales
FROM gold.fact_sales f
LEFT JOIN gold.dim_products P
ON f.product_key = p.product_key
WHERE f.order_date IS NOT NULL
GROUP BY
	YEAR(f.order_date),
	p.product_name
)
SELECT 
	order_year,
	product_name,
	current_sales,
	AVG(current_sales) OVER(PARTITION BY product_name) AS avg_sales,
	current_sales - AVG(current_sales) OVER(PARTITION BY product_name) AS diff_avg,
	CASE WHEN current_sales - AVG(current_sales) OVER(PARTITION BY product_name) > 0 THEN 'Above Avg'
		   WHEN current_sales - AVG(current_sales) OVER(PARTITION BY product_name) < 0 THEN 'Below Avg'
		   ELSE 'Avg'
	END avg_change,
	-- Year-over-year Analysis 
	LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) AS py_sales,
	current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) AS diff_py,
	CASE WHEN current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) > 0 THEN 'Increase'
		   WHEN current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) < 0 THEN 'Decrease'
		   ELSE 'No change'
	END py_change
FROM yearly_product_sales
ORDER BY product_name, order_year


/*
==========================================================
		Part-to-whole(proportional analysis)
==========================================================
*/

-- Which categories contribute the most to overall sales?
WITH category_sales AS
(
SELECT
	p.category,
	SUM(f.sales_amount) total_sales
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p
ON p.product_key = f.product_key
GROUP BY category
)
SELECT
	category,
	total_sales,
	SUM(total_sales) OVER () overall_sales,
	CONCAT(ROUND((CAST(total_sales AS FLOAT) / SUM(total_sales) OVER ()) * 100, 2), '%') AS percentage_of_total
FROM category_sales
ORDER BY total_sales DESC



/*
==========================================================
				 Data Segmaentation
==========================================================
*/

-- Segment Products into cost ranges and
-- Count how many products fall into each segment

WITH product_segment  AS 
(
	SELECT
		product_key,
		product_name,
		cost,
		CASE WHEN cost < 100 THEN 'Below 100'
  			 WHEN cost BETWEEN 100 AND 500 THEN '100 - 500'
  			 WHEN cost BETWEEN 500 AND 1000 THEN '500 - 1000'
  			 ELSE 'Above 1000'
		END AS cost_range
	FROM gold.dim_products
)
SELECT
	cost_range,
	COUNT(product_key) AS total_products
FROM product_segment
GROUP BY cost_range
ORDER BY total_products DESC




/*
Group Customers into three segments based on their spending behaviour:

- Vip:at least 12 month of history and spending more than 5000 euros
- Regular: at least 12 months of history but speding 5000 euros or less.
- New: lifespan less than 12 months.

And find the total number of customers by each group .

*/

WITH customer_spending AS -- second step customer segmentation
(
SELECT -- first step total spending and life span
	c.customer_key,
	SUM(f.sales_amount) AS total_spending,
	MIN(order_date) AS first_order,
	MAX(order_date) AS last_customer,
	DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) AS life_span
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
ON f.customer_key = c.customer_key
GROUP BY c.customer_key
)
SELECT -- third step counting the total number of customer
customer_segment,
COUNT(customer_key) total_customer
FROM
(
	SELECT 
		customer_key,
		total_spending,
		life_span,
		CASE WHEN life_span >= 12 AND total_spending > 5000 THEN 'VIP'
  			 WHEN life_span >= 12 AND total_spending <= 5000 THEN 'Regular'
  			 ELSE 'New'
		END AS customer_segment
	FROM customer_spending
	)t
GROUP BY customer_segment
ORDER BY total_customer DESC
