-- ============================================================
-- PORTFÓLIO 4: SUPERSTORE RETAIL ANALYTICS
-- Dataset: 5000 pedidos, 40 estados, 4 regiões (2020-2024)
-- ============================================================

-- 1. EXECUTIVE SUMMARY
SELECT COUNT(DISTINCT [Order ID]) as orders, COUNT(DISTINCT State) as states,
       COUNT(DISTINCT City) as cities, ROUND(SUM(Sales),2) as revenue,
       ROUND(SUM(Profit),2) as profit, ROUND(SUM(Profit)/SUM(Sales)*100,2) as margin
FROM retail;

-- 2. REGIONAL PERFORMANCE
SELECT Region, ROUND(SUM(Sales),2) as revenue, ROUND(SUM(Profit),2) as profit,
       ROUND(SUM(Profit)/SUM(Sales)*100,2) as margin, COUNT(DISTINCT [Order ID]) as orders
FROM retail GROUP BY Region ORDER BY revenue DESC;

-- 3. TOP 20 STATES BY REVENUE
SELECT State, Region, ROUND(SUM(Sales),2) as revenue, ROUND(SUM(Profit),2) as profit,
       ROUND(SUM(Profit)/SUM(Sales)*100,2) as margin, COUNT(DISTINCT [Order ID]) as orders
FROM retail GROUP BY State, Region ORDER BY revenue DESC LIMIT 20;

-- 4. CATEGORY DRILL-DOWN
SELECT Category, [Sub-Category], ROUND(SUM(Sales),2) as revenue,
       ROUND(SUM(Profit),2) as profit, ROUND(SUM(Profit)/SUM(Sales)*100,2) as margin,
       COUNT(*) as items, ROUND(AVG(Discount),2) as avg_disc
FROM retail GROUP BY Category, [Sub-Category] ORDER BY Category, revenue DESC;

-- 5. SEGMENT ANALYSIS
SELECT Segment, ROUND(SUM(Sales),2) as revenue, ROUND(SUM(Profit),2) as profit,
       ROUND(SUM(Profit)/SUM(Sales)*100,2) as margin,
       COUNT(DISTINCT [Order ID]) as orders, ROUND(AVG(Sales),2) as aov
FROM retail GROUP BY Segment ORDER BY revenue DESC;

-- 6. MONTHLY TREND (48 MONTHS)
SELECT strftime('%Y-%m', [Order Date]) as month, ROUND(SUM(Sales),2) as revenue,
       ROUND(SUM(Profit),2) as profit
FROM retail GROUP BY 1 ORDER BY 1;

-- 7. YEAR-OVER-YEAR GROWTH (WINDOW FUNCTION)
WITH yearly AS (
    SELECT strftime('%Y', [Order Date]) as year, SUM(Sales) as rev
    FROM retail GROUP BY 1
)
SELECT year, ROUND(rev,2) as revenue,
       ROUND(LAG(rev) OVER (ORDER BY year),2) as prev_year,
       ROUND((rev - LAG(rev) OVER (ORDER BY year)) /
             LAG(rev) OVER (ORDER BY year) * 100, 2) as yoy_pct
FROM yearly ORDER BY year;

-- 8. SHIP MODE ANALYSIS
SELECT [Ship Mode], ROUND(SUM(Sales),2) as revenue, COUNT(*) as orders,
       ROUND(AVG(Sales),2) as avg_order
FROM retail GROUP BY [Ship Mode] ORDER BY revenue DESC;

-- 9. TOP PRODUCTS BY REVENUE (DENSE_RANK)
SELECT [Sub-Category], Category, ROUND(SUM(Sales),2) as revenue,
       ROUND(SUM(Profit),2) as profit, COUNT(*) as items,
       DENSE_RANK() OVER (ORDER BY SUM(Sales) DESC) as rank
FROM retail GROUP BY [Sub-Category], Category ORDER BY revenue DESC;

-- 10. QUARTERLY PERFORMANCE
SELECT strftime('%Y', [Order Date]) as year,
       CASE WHEN CAST(strftime('%m', [Order Date]) AS INT) <= 3 THEN 'Q1'
            WHEN CAST(strftime('%m', [Order Date]) AS INT) <= 6 THEN 'Q2'
            WHEN CAST(strftime('%m', [Order Date]) AS INT) <= 9 THEN 'Q3'
            ELSE 'Q4' END as quarter,
       ROUND(SUM(Sales),2) as revenue, ROUND(SUM(Profit),2) as profit,
       COUNT(DISTINCT [Order ID]) as orders
FROM retail GROUP BY year, quarter ORDER BY year, quarter;

-- 11. DISCOUNT IMPACT ON PROFITABILITY (CASE WHEN grouping)
SELECT CASE WHEN Discount = 0 THEN 'No Discount'
            WHEN Discount <= 0.2 THEN '1-20%'
            WHEN Discount <= 0.4 THEN '21-40%'
            ELSE '41%+' END as disc_range,
       COUNT(*) as orders, ROUND(AVG(Sales),2) as avg_sales,
       ROUND(AVG(Profit),2) as avg_profit,
       ROUND(AVG(Profit)/AVG(Sales)*100, 2) as avg_margin
FROM retail GROUP BY disc_range ORDER BY avg_margin DESC;

-- 12. SHIPPING TIME ANALYSIS
SELECT [Ship Mode],
       ROUND(AVG(CAST(strftime('%s', [Ship Date]) - strftime('%s', [Order Date]) AS REAL)/86400), 1) as avg_ship_days,
       COUNT(*) as orders
FROM retail GROUP BY [Ship Mode] ORDER BY avg_ship_days;

-- 13. CUMULATIVE SALES (RUNNING TOTAL via WINDOW FUNCTION)
WITH monthly AS (
    SELECT strftime('%Y-%m', [Order Date]) as month, SUM(Sales) as monthly_rev
    FROM retail GROUP BY 1
)
SELECT month, ROUND(monthly_rev, 2) as monthly_revenue,
       ROUND(SUM(monthly_rev) OVER (ORDER BY month), 2) as cumulative_revenue
FROM monthly ORDER BY month;

-- 14. PARETO ANALYSIS (80/20 RULE)
WITH sub_rev AS (
    SELECT [Sub-Category], SUM(Sales) as rev FROM retail GROUP BY 1
),
ranked AS (
    SELECT [Sub-Category], rev,
           SUM(rev) OVER (ORDER BY rev DESC) as running_total,
           (SELECT SUM(Sales) FROM retail) as grand_total
    FROM sub_rev
)
SELECT [Sub-Category], ROUND(rev, 2) as revenue,
       ROUND(running_total / grand_total * 100, 2) as cumulative_pct
FROM ranked ORDER BY rev DESC;

-- 15. REGIONAL QUARTERLY HEATMAP
SELECT Region,
       strftime('%Y', [Order Date]) as year,
       CASE WHEN CAST(strftime('%m', [Order Date]) AS INT) <= 3 THEN 'Q1'
            WHEN CAST(strftime('%m', [Order Date]) AS INT) <= 6 THEN 'Q2'
            WHEN CAST(strftime('%m', [Order Date]) AS INT) <= 9 THEN 'Q3'
            ELSE 'Q4' END as quarter,
       ROUND(SUM(Sales), 2) as revenue
FROM retail GROUP BY Region, year, quarter ORDER BY Region, year, quarter;
