# Business Performance Analytics – Executive Insights for a Multi-Region Bike Retailer

## Executive Summary

Between 2011 and 2013, the Bike Store business experienced rapid top-line growth, generating **$29.3M in revenue**, maintaining **~40% profit margins**, and expanding its customer base by **over 400%**. Growth, however, was not driven by customers spending more per order. Instead, performance scaled through a sharp increase in customer volume, while **Average Order Value steadily declined**.

This project translates those patterns into actionable insight. An end-to-end SQL Server data warehouse was designed using a **Medallion Architecture (Bronze → Silver → Gold)** and modeled into a **Star Schema** to support executive-level analytics. The warehouse feeds an **Executive Tableau Dashboard** built to help leadership understand where growth is coming from, how it behaves over time, and what structural risks accompany it.

The analysis reveals a business that grows powerfully when demand timing, category strength, and execution align, but slows quickly when any of those weaken. The opportunity ahead is clear. Shift the next growth phase from customer acquisition alone toward **increasing value per customer while diversifying revenue drivers**.

🔗 **Interactive Executive Dashboard (Tableau Public)**
[https://public.tableau.com/app/profile/emmanuel.okenwa/viz/tableaubikestoredataexploration/executivedashboard](https://public.tableau.com/app/profile/emmanuel.okenwa/viz/tableaubikestoredataexploration/executivedashboard)

---

## Business Context

This project reflects a real-world analytics engagement, framed as work delivered for internal stakeholders at a multi-region retail business. The objective is create decision support for leadership, finance, marketing, and operations teams.

The focus is on answering a single executive concern.

> The business is growing fast. Is that growth structurally healthy and sustainable.

---

## Data Architecture and Analytics Stack

**Data Warehouse**

* Platform. Microsoft SQL Server
* Architecture. Medallion (Bronze, Silver, Gold)
* Modeling. Star Schema

**Gold Layer Schema**

* **Fact Table**. `fact_sales`
* **Dimension Tables**. `dim_customers`, `dim_products`

![Star Schema](docs/Data model.png)



**Analytics and Visualization**

* SQL for transformation and aggregation
* Tableau for executive-level exploratory analytics

**SQL Repository**
All warehouse scripts live here.
[https://github.com/emerald-web/olist-data-warehouse/tree/main/scripts](https://github.com/emerald-web/olist-data-warehouse/tree/main/scripts)

---

## Executive Performance Overview

📌 *Insert Executive KPI Visualization Here*
Recommended visualization. High-level KPI tiles showing Revenue, Profit Margin, Customer Count, and Average Order Value.

From 2011 to 2013, revenue accelerated year over year, supported by disciplined cost control that preserved margins near 40%. Customer acquisition surged dramatically, forming the primary growth engine. At the same time, Average Order Value declined, signaling a shift toward smaller but more frequent purchases.

This combination produced strong short-term results, while introducing longer-term questions around efficiency, customer value, and revenue resilience.

---

## Insight Deep Dive

### Growth Was Driven by Volume, Not Customer Value

📌 *Insert Customer Growth vs AOV Trend Chart Here*
Recommended visualization. Dual-axis line chart showing Customer Count rising sharply while AOV trends downward.

The customer base expanded by more than 400% across three years, fueling record revenue growth. However, individual transaction value declined steadily. The business scaled by bringing more customers through the door rather than by increasing the value extracted from each relationship.

This growth model is effective but costly. Customer acquisition requires sustained marketing investment and becomes harder to scale over time. Without improvements in retention, upselling, or pricing, long-term profitability becomes more fragile.

This insight is particularly relevant for **Marketing and Finance teams**, where acquisition efficiency and customer lifetime value directly affect future margins.

---

### Category Concentration Explains Performance Swings

📌 *Insert Revenue by Product Category Chart Here*
Recommended visualization. Stacked bar or area chart showing category contribution over time.

A small number of product categories, primarily Bikes, generate the majority of revenue, while Accessories contribute disproportionately to profitability. When these core categories perform well, the entire business accelerates. When they soften, overall performance slows immediately, as seen during the 2012 dip.

This concentration creates exposure. Dependence on a narrow revenue engine increases operational and financial risk, especially during demand fluctuations or inventory constraints.

This insight supports **Merchandising, Operations, and Finance teams** in prioritizing category diversification and margin protection.

---

### Seasonal Acceleration Became Structural in 2013

📌 *Insert Monthly Revenue Trend Chart Here*
Recommended visualization. Line chart showing monthly revenue patterns across years.

Across all years, revenue followed a predictable seasonal rhythm, with slower starts and strong finishes. In 2013, however, growth began earlier, climbed faster, and sustained momentum longer than previous years.

This was not seasonal chance. It reflected improved alignment between demand timing, category readiness, and execution. Acceleration became structural rather than incidental.

This insight informs **Sales, Inventory, and Campaign Planning teams**, highlighting the value of acting earlier to capture predictable demand surges.

---

## Recommendations

The analysis points to a clear next phase for sustainable growth.

* **Increase value per customer** through retention programs, targeted upselling, and pricing optimization. This reduces dependence on constant acquisition.
* **Diversify category contribution** to lower revenue risk and stabilize performance when core categories soften.
* **Act earlier on seasonal demand** with inventory positioning and promotions timed ahead of historical peaks.

Collectively, these actions allow the business to move from reactive growth toward controlled, repeatable expansion.

---

## Assumptions and Caveats

* Analysis is based on historical sales data from 2011 to 2013.
* External factors such as competitor actions or macroeconomic shifts are not modeled.
* Customer lifetime value is inferred from transactional behavior, not longitudinal cohort tracking.

---

## Project Scope

This project was delivered end to end.

* Data ingestion and transformation in SQL Server
* Analytical modeling using a Star Schema
* Executive dashboard design in Tableau
* Business storytelling focused on decision support

The goal was clarity over complexity and insight over ornamentation. Every metric, model, and visualization exists to support a business decision.

