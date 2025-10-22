/*
=========================================================================================
                               CUSTOMER ENGAGEMENT REPORT
=========================================================================================

📌 Purpose:
    This report provides a unified view of customer behavior and value contribution.
    It transforms raw transactional data into meaningful customer insights for
    marketing, sales, and business managers to drive retention and growth strategies.

🎯 Business Objectives:
    - Identify high-value (VIP) and potential churn-risk customers.
    - Understand customer lifetime behavior and spending patterns.
    - Support segmentation-based marketing and customer relationship strategies.

📊 Key Insights & Metrics:
    1. Customer Demographics:
        - Age and Age Group Classification.
    2. Behavioral Metrics:
        - Total Orders, Total Products Purchased, Total Quantity.
    3. Financial Metrics:
        - Total Sales, Average Order Value (AOV), Average Monthly Spend.
    4. Customer Lifecycle Metrics:
        - Lifespan (Months), Recency (Months since last order).
    5. Segmentation:
        - Categorizes customers as:
            • VIP: ≥ 12 months lifespan and > 5000 in total sales.
            • Regular: ≥ 12 months lifespan and ≤ 5000 in total sales.
            • New: < 12 months lifespan.

🧭 Business Relevance:
    - Enables performance tracking across customer segments.
    - Supports personalized marketing, loyalty programs, and customer retention planning.
    - Helps management forecast revenue and optimize engagement strategies.

📁 Output:
    Creates a view: [gold].[report_customers]
    - Each record represents an individual customer with key behavioral and financial KPIs.

=========================================================================================
*/


CREATE VIEW gold.report_customers AS
WITH base_query AS
(
	/*
	-----------------------------------------------------------------------------
	1) Base Query: Retrieve core columns from tables
	-----------------------------------------------------------------------------
	*/

	SELECT
		f.order_number,
		f.product_key,
		f.order_date,
		f.sales_amount,
		f.quantity,
		c.customer_key,
		c.customer_number,
		CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
		DATEDIFF(YEAR, c.birthdate, GETDATE()) AS age
	FROM gold.fact_sales AS f
	LEFT JOIN gold.dim_customers AS c
	ON c.customer_key = f.customer_key
	WHERE order_date IS NOT NULL
),
 customer_aggregation AS
(
/*
-----------------------------------------------------------------------------
2) Customer Aggregations: Summarizes key metrics at the customer level
-----------------------------------------------------------------------------
	*/
SELECT 
	customer_key,
	customer_number,
	customer_name,
	age,
	COUNT(DISTINCT order_number) AS total_order,
	SUM(sales_amount) AS total_sales,
	SUM(quantity) AS total_quantity,
	COUNT(DISTINCT product_key) AS total_products,
	MAX(order_date) AS last_order_date,
	DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) AS life_span
FROM base_query
GROUP BY
	customer_key,
	customer_number,
	customer_name,
	age
)

/*
-----------------------------------------------------------------------------
3) Final Query: Combines all product result into one output
-----------------------------------------------------------------------------
*/
SELECT
	customer_key,
	customer_number,
	customer_name,
	age,
	CASE
		WHEN age < 20 THEN 'Under 20'
		WHEN age between 20 and 29 THEN '20-29'
		WHEN age between 30 and 39 THEN '30-39'
		WHEN age between 40 and 49 THEN '40-49'
		ELSE '50 and above'
	END AS age_group, 
	CASE
		WHEN life_span >= 12 AND total_sales > 5000 THEN 'VIP'
		WHEN life_span >= 12 AND total_sales <= 5000 THEN 'Regular'
		ELSE 'New'
	END AS customer_segment,
	last_order_date,
	DATEDIFF(MONTH, last_order_date, GETDATE()) AS recency_in_months,
	total_order,
	total_sales,
	total_quantity,
	total_products,
	life_span,
	-- compute average order value (AVO)
	CASE WHEN total_sales = 0 THEN 0
		 ELSE total_sales / total_order 
	END AS  avg_order_value,

	--Compute average monthly spent
	CASE WHEN life_span = 0 THEN total_sales
		ELSE total_sales / life_span
	END AS avg_monthly_spent

FROM customer_aggregation


SELECT * FROM gold.report_customers
