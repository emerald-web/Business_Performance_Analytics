/*
=========================================================================================
                               PRODUCT PERFORMANCE REPORT
=========================================================================================

📌 Purpose:
    This report consolidates product-level performance metrics and lifecycle indicators.
    It converts transactional data into actionable product insights for product managers,
    sales, finance, and marketing to drive assortment, pricing, and promotional decisions.

🎯 Business Objectives:
    - Identify high-performing and underperforming products for assortment and inventory actions.
    - Assess product profitability and customer reach to guide pricing and margin optimization.
    - Support targeted promotions and product lifecycle strategies (grow, maintain, or retire SKUs).

📊 Key Insights & Metrics:
    1. Product Profile:
        - Product Name, Category, Subcategory, Cost.
    2. Behavioral & Reach Metrics:
        - Total Orders, Unique Customers (buyers), Total Quantity Sold.
    3. Financial Metrics:
        - Total Sales, Average Order Revenue (AOR), Average Selling Price (ASP).
    4. Lifecycle & Recency:
        - Lifespan (Months active), Last Order Date, Recency (Months since last sale).
    5. Segmentation & Contribution:
        - Product Segments (High-Performer / Mid-Range / Low-Performer) by revenue bands.
        - Part-to-whole contribution to total revenue and category performance.

🧭 Business Relevance:
    - Enables product managers to prioritize SKUs for promotions, re-ordering, or discontinuation.
    - Helps sales and marketing design offers around high-impact products and identify cross-sell opportunities.
    - Supports finance with product-level revenue visibility and margin monitoring.
    - Provides executive teams with clear signals on portfolio health and revenue concentration.

📁 Output:
    Creates a view: [gold].[report_products]
    - Each record represents a product with summarized behavioral, financial, and lifecycle KPIs,
      ready for dashboards, scorecards, and downstream reporting.

=========================================================================================
*/

/*
-----------------------------------------------------------------------------
1) Base Query: Retrieve core columns from fact_sales and dim_products
-----------------------------------------------------------------------------
*/

CREATE VIEW  gold.report_products AS
WITH base_query AS 
(
	SELECT
		f.order_number,
		f.order_date,
		f.customer_key,
		f.sales_amount,
		f.quantity,
		p.product_key,
		p.product_name,
		p.category,
		p.subcategory,
		p.cost
	FROM gold.fact_sales f
	LEFT JOIN gold.dim_products p
		ON f.product_key = p.product_key
	WHERE order_date IS NOT NULL --only consider sales date
),

product_aggregations AS (
/*
-----------------------------------------------------------------------------
2) Customer Aggregations: Summarizes key metrics at the customer level
-----------------------------------------------------------------------------
*/
SELECT
	product_key,
	product_name,
	category,
	subcategory,
	cost,
	DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) AS life_span,
	MAX(order_date) AS last_order_date,
	COUNT(DISTINCT order_number) AS total_order,
	COUNT(DISTINCT customer_key) AS total_customers,
	SUM(sales_amount) AS total_sales,
	SUM(quantity) AS total_quantity,
	ROUND(AVG(CAST(sales_amount AS float) / NULLIF(quantity, 0)), 1) AS avg_selling_price
FROM base_query
GROUP BY
	product_key,
	product_name,
	category,
	subcategory,
	cost
)

SELECT
	product_key,
	product_name,
	category,
	subcategory,
	cost,
	last_order_date,
	DATEDIFF(MONTH, last_order_date, GETDATE()) AS recency_in_months,
	CASE
		WHEN total_sales > 50000 THEN 'High-Performer'
		WHEN total_sales >= 10000 THEN 'Mid-Range'
		ELSE 'Low-Perfromer'
	END AS product_segment,
	life_span,
	total_order,
	total_sales,
	total_quantity,
	total_customers,
	avg_selling_price,
	-- compute average order revenue (AOR)
	CASE WHEN total_sales = 0 THEN 0
		 ELSE total_sales / total_order 
	END AS  avg_order_revenue,
	--Compute average monthly revenue
	CASE WHEN life_span = 0 THEN total_sales
		ELSE total_sales / life_span
	END AS avg_monthly_revenue

FROM product_aggregations



SELECT * FROM gold.report_products
