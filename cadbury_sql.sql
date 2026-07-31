
CREATE DATABASE IF NOT EXISTS cadbury_db;
USE cadbury_db;
SELECT COUNT(*) FROM sales_data;	
SELECT COUNT(*) FROM product_master;
SELECT *
FROM sales_data s
JOIN product_master p
ON s.product = p.product
LIMIT 5;
select * from regional_summary;
select * from product_master;

CREATE TABLE product_master (
    product_id      INT AUTO_INCREMENT PRIMARY KEY,
    product         VARCHAR(100) NOT NULL,
    category        VARCHAR(50),          -- Value / Mid-range / Premium
    unit_price      DECIMAL(10,2),
    cogs            DECIMAL(10,2),        -- Cost of Goods Sold
    margin_pct      DECIMAL(6,4),
    launch_year     INT,
    status          VARCHAR(20),
    description     VARCHAR(255)
);

-- Table 2: Sales Data (Main table)
CREATE TABLE sales_data (
    order_id        INT PRIMARY KEY,
    order_date      DATE,
    year            INT,
    month           VARCHAR(10),
    quarter         VARCHAR(5),
    product         VARCHAR(100),
    category        VARCHAR(50),
    region          VARCHAR(50),          -- North/South/East/West/International
    channel         VARCHAR(50),          -- Modern Trade / General Trade / E-Commerce / Institutional
    units_sold      INT,
    unit_price      DECIMAL(10,2),
    revenue         DECIMAL(15,2),
    cogs            DECIMAL(15,2),
    gross_profit    DECIMAL(15,2),
    discount_pct    DECIMAL(5,2),
    net_revenue     DECIMAL(15,2)
);

-- Table 3: Monthly Summary
CREATE TABLE monthly_summary (
    id              INT AUTO_INCREMENT PRIMARY KEY,
    year            INT,
    month           VARCHAR(10),
    month_num       INT,
    total_revenue   DECIMAL(15,2),
    total_units     INT,
    avg_order_value DECIMAL(10,2),
    gross_profit    DECIMAL(15,2),
    net_revenue     DECIMAL(15,2)
);
 
-- Table 4: Regional Summary
CREATE TABLE regional_summary (
    id              INT AUTO_INCREMENT PRIMARY KEY,
    year            INT,
    region          VARCHAR(50),
    total_revenue   DECIMAL(15,2),
    total_units     INT,
    gross_profit    DECIMAL(15,2),
    net_revenue     DECIMAL(15,2)
);

-- Table 5: KPI Targets
CREATE TABLE kpi_targets (
    id              INT AUTO_INCREMENT PRIMARY KEY,
    kpi_name        VARCHAR(100),
    year_2023_target DECIMAL(15,2),
    year_2023_actual DECIMAL(15,2),
    year_2023_pct   DECIMAL(6,2),
    year_2024_target DECIMAL(15,2),
    year_2024_actual DECIMAL(15,2),
    year_2024_pct   DECIMAL(6,2),
    year_2025_target DECIMAL(15,2),
    year_2025_actual DECIMAL(15,2),
    year_2025_pct   DECIMAL(6,2)
);


 
-- ============================================================
-- STEP 3: PRODUCT MASTER DATA INSERT KARO
-- ============================================================
 
INSERT INTO product_master (product, category, unit_price, cogs, margin_pct, launch_year, status, description) VALUES
('Dairy Milk',       'Mid-range', 45,  35,  0.2222, 1948, 'Active', 'Classic milk chocolate'),
('Dairy Milk Silk',  'Premium',   75,  52,  0.3067, 2010, 'Active', 'Smooth silk chocolate'),
('5 Star',           'Value',     30,  22,  0.2667, 1969, 'Active', 'Caramel & nougat bar'),
('Perk',             'Value',     25,  18,  0.2800, 1996, 'Active', 'Wafer chocolate'),
('Bournville',       'Premium',   90,  65,  0.2778, 1908, 'Active', 'Dark chocolate'),
('Gems',             'Value',     20,  14,  0.3000, 1968, 'Active', 'Colourful sugar shells'),
('Celebrations Box', 'Premium',   250, 180, 0.2800, 1997, 'Active', 'Assorted gift box'),
('Oreo',             'Mid-range', 40,  28,  0.3000, 2011, 'Active', 'Cream biscuit'),
('Fuse',             'Mid-range', 35,  24,  0.3143, 1996, 'Active', 'Fudge & biscuit bar'),
('Caramel',          'Mid-range', 55,  38,  0.3091, 2019, 'Active', 'Caramel chocolate');


-- ============================================================
-- STEP 5: ANALYSIS QUERIES - BASIC
-- ============================================================
 
-- Q1: Total Orders
SELECT COUNT(*) AS total_orders FROM sales_data;
 
-- Q2: Total Revenue of Each product
SELECT 
    product,
    SUM(units_sold)  AS total_units,
    ROUND(SUM(revenue), 2) AS total_revenue,
    ROUND(AVG(discount_pct)*100, 2) AS avg_discount_pct
FROM sales_data
GROUP BY product
ORDER BY total_revenue DESC;
 
-- Q3: Sales of Each Region
SELECT 
    region,
    COUNT(order_id)        AS total_orders,
    SUM(units_sold)        AS total_units,
    ROUND(SUM(revenue), 2) AS total_revenue
FROM sales_data
GROUP BY region
ORDER BY total_revenue DESC;
 
-- Q4: channel (Modern Trade / E-Commerce etc.)  performance
SELECT 
    channel,
    COUNT(order_id)        AS total_orders,
    ROUND(SUM(revenue), 2) AS total_revenue,
    ROUND(AVG(units_sold), 0) AS avg_units_per_order
FROM sales_data
GROUP BY channel
ORDER BY total_revenue DESC;
 
-- Q5: Premium vs Value vs Mid-range category comparison
SELECT 
    category,
    COUNT(order_id)            AS total_orders,
    ROUND(SUM(revenue), 2)     AS total_revenue,
    ROUND(SUM(gross_profit), 2) AS total_gross_profit,
    ROUND(AVG(discount_pct)*100, 2) AS avg_discount_pct
FROM sales_data
GROUP BY category
ORDER BY total_revenue DESC;
 
 
-- ============================================================
-- STEP 6: ANALYSIS QUERIES - INTERMEDIATE
-- ============================================================
 
-- Q6: Year-wise revenue trend
SELECT 
    year,
    ROUND(SUM(revenue), 2)      AS total_revenue,
    ROUND(SUM(gross_profit), 2) AS total_gross_profit,
    ROUND(SUM(net_revenue), 2)  AS total_net_revenue,
    SUM(units_sold)             AS total_units
FROM sales_data
GROUP BY year
ORDER BY year;
 
-- Q7: Top 5 best-selling products by units
SELECT 
    product,
    SUM(units_sold) AS total_units_sold
FROM sales_data
GROUP BY product
ORDER BY total_units_sold DESC
LIMIT 5;
 
-- Q8: Monthly revenue trend (2022 ke liye)
SELECT 
    month,
    ROUND(SUM(revenue), 2) AS monthly_revenue
FROM sales_data
WHERE year = 2022
GROUP BY month
ORDER BY MIN(order_date);
 
-- Q9: Region x Channel cross analysis
SELECT 
    region,
    channel,
    ROUND(SUM(revenue), 2) AS total_revenue
FROM sales_data
GROUP BY region, channel
ORDER BY region, total_revenue DESC;
 
-- Q10: Gross Profit Margin % by product
SELECT 
    s.product,
    p.category,
    ROUND(SUM(s.gross_profit) / SUM(s.revenue) * 100, 2) AS gross_margin_pct,
    ROUND(SUM(s.revenue), 2) AS total_revenue
FROM sales_data s
JOIN product_master p ON s.product = p.product
GROUP BY s.product, p.category
ORDER BY gross_margin_pct DESC;
 
 
-- ============================================================
-- STEP 7: ANALYSIS QUERIES - ADVANCED
-- ============================================================
 
-- Q11: Quarter-wise performance comparison
SELECT 
    year,
    quarter,
    ROUND(SUM(revenue), 2)      AS quarterly_revenue,
    ROUND(SUM(gross_profit), 2) AS quarterly_profit,
    SUM(units_sold)             AS quarterly_units
FROM sales_data
GROUP BY year, quarter
ORDER BY year, quarter;
 
-- Q12: Revenue Growth % Year over Year (Window Function)
SELECT 
    year,
    ROUND(SUM(revenue), 2) AS total_revenue,
    ROUND(
        (SUM(revenue) - LAG(SUM(revenue)) OVER (ORDER BY year)) 
        / LAG(SUM(revenue)) OVER (ORDER BY year) * 100, 2
    ) AS yoy_growth_pct
FROM sales_data
GROUP BY year;
 
-- Q13: Top performing region per year
SELECT year, region, total_revenue
FROM (
    SELECT 
        year,
        region,
        ROUND(SUM(revenue), 2) AS total_revenue,
        RANK() OVER (PARTITION BY year ORDER BY SUM(revenue) DESC) AS rnk
    FROM sales_data
    GROUP BY year, region
) ranked
WHERE rnk = 1;
 
-- Q14: Products with above-average revenue (Subquery)
SELECT 
    product,
    ROUND(SUM(revenue), 2) AS total_revenue
FROM sales_data
GROUP BY product
HAVING SUM(revenue) > (
    SELECT AVG(product_revenue) 
    FROM (
        SELECT SUM(revenue) AS product_revenue 
        FROM sales_data 
        GROUP BY product
    ) sub
);
 
-- Q15: High discount orders (discount > 10%)
SELECT 
    order_id,
    product,
    region,
    channel,
    units_sold,
    ROUND(revenue, 2)    AS revenue,
    discount_pct * 100   AS discount_pct
FROM sales_data
WHERE discount_pct > 0.10
ORDER BY discount_pct DESC
LIMIT 20;
 
-- Q16: E-Commerce vs Traditional channels ka revenue share
SELECT 
    CASE 
        WHEN channel = 'E-Commerce' THEN 'E-Commerce'
        ELSE 'Traditional (Offline)'
    END AS channel_type,
    ROUND(SUM(revenue), 2) AS total_revenue,
    ROUND(SUM(revenue) / (SELECT SUM(revenue) FROM sales_data) * 100, 2) AS revenue_share_pct
FROM sales_data
GROUP BY channel_type;
 
-- Q17: CTE - Monthly Revenue Running Total
WITH monthly_rev AS (
    SELECT
        year,
        MONTH(order_date) AS month_num,
        month,
        SUM(revenue) AS monthly_revenue
    FROM sales_data
    GROUP BY year, MONTH(order_date), month
)

SELECT
    year,
    month,
    ROUND(monthly_revenue,2) AS monthly_revenue,

    ROUND(
        SUM(monthly_revenue) OVER(
            PARTITION BY year
            ORDER BY month_num
        ),2
    ) AS running_total

FROM monthly_rev
ORDER BY year, month_num;

SELECT * FROM monthly_summary LIMIT 5;
 
 
-- ============================================================
-- STEP 8: VIEWS BANAO (Reporting ke liye)
-- ============================================================
 
-- View 1: Sales Summary by Product & Region
CREATE OR REPLACE VIEW vw_product_region_summary AS
SELECT 
    product,
    category,
    region,
    SUM(units_sold)             AS total_units,
    ROUND(SUM(revenue), 2)      AS total_revenue,
    ROUND(SUM(gross_profit), 2) AS total_gross_profit,
    ROUND(AVG(discount_pct)*100,2) AS avg_discount
FROM sales_data
GROUP BY product, category, region;
 
-- View 2: Annual KPI Dashboard
CREATE OR REPLACE VIEW vw_annual_kpi AS
SELECT 
    year,
    COUNT(DISTINCT order_id)    AS total_orders,
    SUM(units_sold)             AS total_units,
    ROUND(SUM(revenue), 2)      AS total_revenue,
    ROUND(SUM(gross_profit), 2) AS total_gross_profit,
    ROUND(SUM(gross_profit)/SUM(revenue)*100, 2) AS gross_margin_pct,
    ROUND(AVG(discount_pct)*100, 2) AS avg_discount_pct
FROM sales_data
GROUP BY year;
 
-- View use karna:
SELECT * FROM vw_annual_kpi;
SELECT * FROM vw_product_region_summary WHERE region = 'North India';
 
 
-- ============================================================
-- STEP 9: INDEXES (Performance ke liye)
-- ============================================================
 
CREATE INDEX idx_sales_year     ON sales_data(year);
CREATE INDEX idx_sales_product  ON sales_data(product);
CREATE INDEX idx_sales_region   ON sales_data(region);
CREATE INDEX idx_sales_channel  ON sales_data(channel);
 
 
-- ============================================================
-- BONUS: Interesting Business Insights Queries
-- ============================================================
 
-- Festive Season (Oct-Dec) revenue contribution
SELECT 
    CASE 
        WHEN month IN ('Oct','Nov','Dec') THEN 'Festive Season (Q4)'
        ELSE 'Rest of Year'
    END AS season,
    ROUND(SUM(revenue), 2) AS total_revenue,
    ROUND(SUM(revenue)/(SELECT SUM(revenue) FROM sales_data)*100, 2) AS share_pct
FROM sales_data
GROUP BY season;
 
-- Top Loss-Making Orders (COGS > Revenue)
SELECT order_id, product, region, units_sold, 
       ROUND(revenue,2) AS revenue, 
       ROUND(cogs,2) AS cogs,
       ROUND(revenue - cogs, 2) AS profit_loss
FROM sales_data
WHERE revenue < cogs
ORDER BY profit_loss ASC
LIMIT 10;
 