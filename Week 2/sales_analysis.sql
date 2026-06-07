-- ============== 1 : DATABASE SETUP AND LOAD DATASET ==============

-- Create and select the database
CREATE DATABASE IF NOT EXISTS sales_analysis
    CHARACTER SET utf8mb4;
USE sales_analysis;

-- Drop table if re-running the script (safe reset)
DROP TABLE IF EXISTS superstore;

-- Creating the table (as per the dataset)
CREATE TABLE superstore (
    row_id INT NOT NULL,
    order_id VARCHAR(20) NOT NULL,
    order_date DATE NOT NULL,
    ship_date DATE NOT NULL,
    ship_mode VARCHAR(20) NOT NULL,
    customer_id VARCHAR(10) NOT NULL,
    customer_name VARCHAR(50) NOT NULL,
    segment VARCHAR(20) NOT NULL,
    country VARCHAR(30) NOT NULL,
    city VARCHAR(50) NOT NULL,
    state VARCHAR(30) NOT NULL,
    postal_code VARCHAR(10) NOT NULL,
    region VARCHAR(10) NOT NULL,
    product_id VARCHAR(20) NOT NULL,
    category VARCHAR(20) NOT NULL,
    sub_category VARCHAR(20) NOT NULL,
    product_name VARCHAR(150) NOT NULL,
    sales DECIMAL(10 , 4 ) NOT NULL,
    quantity INT NOT NULL,
    discount DECIMAL(4 , 2 ) NOT NULL,
    profit DECIMAL(10 , 4 ) NOT NULL,
    PRIMARY KEY (row_id),
-- index for filtering
    INDEX idx_order_id (order_id),
    INDEX idx_order_date (order_date),
    INDEX idx_region (region),
    INDEX idx_category (category),
    INDEX idx_sub_category (sub_category),
    INDEX idx_customer_id (customer_id),
    INDEX idx_segment (segment),
    INDEX idx_state (state)
);

-- Load the dataset 
LOAD DATA LOCAL INFILE 'D:\\CEI internship\\Week 2\\Sample - Superstore.csv'
INTO TABLE superstore
CHARACTER SET latin1
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(
    row_id, order_id, @order_date, @ship_date, ship_mode,
    customer_id, customer_name, segment, country, city,
    state, postal_code, region, product_id, category,
    sub_category, product_name, sales, quantity, discount, profit
)
-- change date format as per sql
SET
order_date = STR_TO_DATE(@order_date,'%m/%d/%Y'), 
ship_date = STR_TO_DATE(@ship_date,'%m/%d/%Y');


-- ===================== 2 : EXPLORE THE TABLE =====================

-- View table schema
DESCRIBE superstore;

-- Sample data (first 10 rows)
SELECT *
FROM superstore
LIMIT 10;

-- Distinct values in key categorical columns
SELECT DISTINCT region
FROM superstore;

-- Date range
SELECT 
    MIN(order_date) AS earliest_order,
    MAX(order_date) AS latest_order
FROM superstore;


-- ======================== 3 : WHERE FILTERS ========================

-- Filter table by a single region
SELECT *
FROM superstore
WHERE region = 'West'
LIMIT 10;

-- Filter table by category
SELECT 
    order_id,
    customer_name,
    sub_category,
    product_name,
    sales,
    profit
FROM
    superstore
WHERE
    category = 'Technology'
LIMIT 10;

-- Filter by date range 
SELECT 
    order_id,
    customer_name,
    category,
    product_name,
    sales,
    profit,
    order_date
FROM
    superstore
WHERE
    order_date BETWEEN '2017-10-01' AND '2017-12-31'
ORDER BY order_date
LIMIT 10;

-- Filter by discounts (> 40%) 
SELECT 
    order_id,
    customer_name,
    product_name,
    discount,
    ROUND(sales, 2) AS sales,
    ROUND(profit, 2) AS profit
FROM
    superstore
WHERE
    discount > 0.40
LIMIT 10;


-- ==================== 4 : GROUP BY AGGREGATIONS ====================

-- Revenue(sales), quantity & Profit aggregation by Category
SELECT 
    category,
    COUNT(*) AS orders,
    SUM(quantity) AS units_sold,
    ROUND(SUM(sales), 2) AS revenue,
    ROUND(SUM(profit), 2) AS profit
FROM
    superstore
GROUP BY category;

-- Revenue, Profit, and average sales by Region
SELECT 
    region,
    COUNT(*) AS orders,
    ROUND(SUM(sales), 2) AS total_revenue,
    ROUND(SUM(profit), 2) AS total_profit,
    ROUND(AVG(sales), 2) AS avg_sales
FROM
    superstore
GROUP BY region;


-- ====================== 5 : SORT AND LIMIT  ======================

-- Top 10 Products by Revenue(sales)
SELECT 
    product_name,
    ROUND(SUM(sales), 2) AS revenue
FROM
    superstore
GROUP BY product_name
ORDER BY revenue DESC
LIMIT 10;

-- Top 10 Products by Profit
SELECT product_name,
       ROUND(SUM(profit), 2) AS profit
FROM   superstore
GROUP  BY product_name
ORDER  BY profit DESC
LIMIT  10;


-- ===================== 6 : BUSINESS USE CASES  =====================

-- Monthly Revenue & Profit Trend 
SELECT 
    YEAR(order_date) AS year,
    MONTH(order_date) AS month,
    ROUND(SUM(sales), 2) AS revenue,
    ROUND(SUM(profit), 2) AS profit
FROM
    superstore
GROUP BY year , month
having year = '2017'
ORDER BY year;

-- Top 10 Customers by Lifetime revenue
SELECT 
    customer_id,
    customer_name,
    ROUND(SUM(sales), 2) AS lifetime_revenue
FROM
    superstore
GROUP BY customer_id , customer_name
ORDER BY lifetime_revenue DESC
LIMIT 10;

-- Duplicate Row Detection
-- returns empty if no duplicates
SELECT 
    row_id, COUNT(*) AS occurrences
FROM
    superstore
GROUP BY row_id
HAVING COUNT(*) > 1
ORDER BY occurrences DESC;


-- =============== 7 : VALIDATE RESULTS & DATA QUALITY  ===============

-- Row count 
SELECT 
    COUNT(*) AS total_rows
FROM
    superstore;
    
-- Check for zero or negative sales
SELECT 
    COUNT(*) AS zero_or_neg_sales
FROM
    superstore
WHERE
    sales <= 0;
    
-- Discount range validation (must be 0–1)
SELECT 
    COUNT(*) AS invalid_discounts
FROM
    superstore
WHERE
    discount < 0 OR discount > 1;
    
-- total Revenue & Profit
SELECT 
    ROUND(SUM(sales), 2) AS total_revenue,
    ROUND(SUM(profit), 2) AS total_profit,
    ROUND(SUM(profit) * 100 / SUM(sales), 2) AS overall_margin_pctg,
    SUM(quantity) AS total_units_sold
FROM
    superstore;