-- ============== 1 : DATABASE SETUP AND LOAD DATASET ==============

-- Create and select the database
CREATE DATABASE IF NOT EXISTS sales_analysis
    CHARACTER SET utf8mb4;
USE sales_analysis;

-- Drop table if re-running the script (safe reset)
DROP TABLE IF EXISTS superstore_raw;

-- Creating the table (as per the dataset)
CREATE TABLE superstore_raw (
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
    INDEX idx_order_id (order_id),
    INDEX idx_order_date (order_date),
    INDEX idx_region (region),
    INDEX idx_category (category),
    INDEX idx_sub_category (sub_category),
    INDEX idx_customer_id (customer_id),
    INDEX idx_segment (segment),
    INDEX idx_state (state)
);

/* -----------------------------------------------------------------------
	-- Load CSV into raw table

   NOTE: To LOAD DATA  to work on your machine:
   1. Run:  SHOW VARIABLES LIKE 'secure_file_priv';
      Move the CSV into that directory, 
      OR
   2. Use LOCAL keyword and start mysql with - local-infile=1
  
   Replace the path below with the path where your CSV actually exist.
---------------------------------------------------------------------------- */ 
LOAD DATA LOCAL INFILE 'D:\\CEI internship\\Week 3\\SQL Subqueries Assignment\\Data\\Sample - Superstore.csv'
INTO TABLE superstore_raw
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


-- ================== 2 : CREATING TABLES FROM DATASET ====================
-- Creating normalized tables: customers, orders, products table


-- Drop table if re-running the script
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS customers;
DROP TABLE IF EXISTS products;

CREATE TABLE customers (
    customer_id VARCHAR(15) PRIMARY KEY,
    customer_name VARCHAR(60),
    segment VARCHAR(20)
);

CREATE TABLE products (
    product_id VARCHAR(20) PRIMARY KEY,
    category VARCHAR(30),
    sub_category VARCHAR(30),
    product_name VARCHAR(255)
);

CREATE TABLE orders (
    row_id INT PRIMARY KEY,
    order_id VARCHAR(20),
    order_date DATE,
    ship_date DATE,
    ship_mode VARCHAR(30),
    customer_id VARCHAR(15),
    product_id VARCHAR(20),
    country VARCHAR(40),
    city VARCHAR(40),
    state VARCHAR(40),
    postal_code VARCHAR(15),
    region VARCHAR(20),
    sales DECIMAL(12 , 4 ),
    quantity INT,
    discount DECIMAL(5 , 4 ),
    profit DECIMAL(12 , 4 ),
    FOREIGN KEY (customer_id)
        REFERENCES customers (customer_id),
    FOREIGN KEY (product_id)
        REFERENCES products (product_id),
    INDEX idx_order_customer (customer_id),
    INDEX idx_order_product (product_id),
    INDEX idx_order_date (order_date)
);



-- ================ 3 : INSERT DATA INTO TABLES USING SELECT DISTINCT ==================

-- insert data into customers
INSERT INTO customers (customer_id, customer_name, segment)
SELECT DISTINCT customer_id, customer_name, segment
FROM superstore_raw;


/* ----------------------------------------------------------------------------------
-- Insert unique products into the products table
-- Group rows by product_id to ensure one record per product
-- MIN() is used to select a single value for category, sub_category,
-- and product_name from each group 
----------------------------------------------------------------------------------- */
INSERT INTO products (product_id, category, sub_category, product_name)
SELECT product_id,
       MIN(category)     AS category,
       MIN(sub_category) AS sub_category,
       MIN(product_name) AS product_name
FROM superstore_raw
GROUP BY product_id;


/* ----------------------------------------------------------------------------------
-- Load transactional order data from the raw table into the orders table
-- Insert one record for each order line item
----------------------------------------------------------------------------------- */
INSERT INTO orders (
    row_id, order_id, order_date, ship_date, ship_mode,
    customer_id, product_id, country, city, state, postal_code, region,
    sales, quantity, discount, profit)
SELECT row_id,
       order_id,
       order_date,
       ship_date,
       ship_mode,
       customer_id,
       product_id,
       country, city, state, postal_code, region,
       sales, quantity, discount, profit
FROM superstore_raw;



-- =================== 4 : APPLYING SUBQUERIES TO FILTER DATA =====================

/* ----------------------------------------------------------------------------------
-- # Find all orders where sales are greater than the average sales. (Subquery)
-- Calculated the average sales using a subquery
----------------------------------------------------------------------------------- */
SELECT row_id, order_id, customer_id, sales
FROM orders
WHERE sales > (SELECT AVG(sales) FROM orders)
ORDER BY sales ASC;


/* ----------------------------------------------------------------------------------
-- # Find the highest sales order for each customer. (Subquery)  
-- Identify the order with the maximum sales for each customer
-- Used correlated subquery to compare each order against the customer's highest sales amount
----------------------------------------------------------------------------------- */
SELECT o.customer_id, o.order_id, o.product_id, o.sales
FROM orders AS o
WHERE o.sales = (
    SELECT MAX(o2.sales)
    FROM orders AS o2
    WHERE o2.customer_id = o.customer_id
)
ORDER BY o.sales DESC;


/* ----------------------------------------------------------------------------------
-- # Calculate total sales for each customer. (CTE)  
-- Calculated the total sales for each customer using a CTE
-- Joined the aggregated sales with customer details
----------------------------------------------------------------------------------- */
WITH customer_totals AS (
    SELECT customer_id, SUM(sales) AS total_sales
    FROM orders
    GROUP BY customer_id
)
SELECT c.customer_id, c.customer_name, ct.total_sales
FROM customer_totals AS ct
JOIN customers AS c ON c.customer_id = ct.customer_id
ORDER BY ct.total_sales DESC;


/* ----------------------------------------------------------------------------------
-- # Find customers whose total sales are above average. (CTE + Subquery)
-- Calculated the total sales for each customer using a CTE
-- Joined customer totals with customer table
-- Filtered customers whose total sales exceed the average total sales across all customers
----------------------------------------------------------------------------------- */
WITH customer_totals AS (
    SELECT customer_id, SUM(sales) AS total_sales
    FROM orders
    GROUP BY customer_id
)
SELECT c.customer_name, ct.total_sales
FROM customer_totals AS ct
JOIN customers AS c ON c.customer_id = ct.customer_id
WHERE ct.total_sales > (SELECT AVG(total_sales) FROM customer_totals)
ORDER BY ct.total_sales ASC;


/* ----------------------------------------------------------------------------------
-- # Rank all customers based on total sales. (Window Function)
-- Aggregated total sales for each customer
-- Used RANK() and DENSE_RANK() window functions to rank customers by sales
-- Displayed customers in order of their sales rank
----------------------------------------------------------------------------------- */
SELECT c.customer_name,
       SUM(o.sales) AS total_sales,
       RANK()       OVER (ORDER BY SUM(o.sales) DESC) AS customer_sales_rank,
       DENSE_RANK() OVER (ORDER BY SUM(o.sales) DESC) AS customer_dense_rank
FROM orders AS o
JOIN customers AS c ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.customer_name
ORDER BY customer_sales_rank;


/* ----------------------------------------------------------------------------------
-- # Assign row numbers to each order within a customer. (Window Function + PARTITION BY) 
-- Assigned a sequential number to each order within every customer group
-- Partition the data by customer_id to restart numbering for each customer
-- Order orders by sales in descending order so that the highest-value order gets row number 1 
----------------------------------------------------------------------------------- */
SELECT customer_id, order_id, product_id, sales,
       ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY sales DESC) AS row_no
FROM orders
ORDER BY customer_id, row_no;


/* ----------------------------------------------------------------------------------
-- # Display top 3 customers based on total sales. (Window Function)  
----------------------------------------------------------------------------------- */
WITH ranked AS (
    SELECT c.customer_name,
           SUM(o.sales) AS total_sales,
           RANK() OVER (ORDER BY SUM(o.sales) DESC) AS rnk
    FROM orders AS o
    JOIN customers AS c ON c.customer_id = o.customer_id
    GROUP BY c.customer_id, c.customer_name
)
SELECT customer_name, total_sales, rnk
FROM ranked
WHERE rnk <= 3;



-- ======================= 5 : FINAL COMBINED QUERY =========================


/* ----------------------------------------------------------------------------------
-- # One final query that shows: Customer Name, Total Sales, Rank  
-- (Use JOIN + CTE + Window Function together)  
-- Calculated the total sales for each customer using a Common Table Expression (CTE)
-- Joined customer sales with customer table
-- Assigned an overall sales rank to customers across all segments
-- Assigned a segment-wise sales rank within each customer segment
----------------------------------------------------------------------------------- */
WITH customer_totals AS (
    SELECT customer_id, SUM(sales) AS total_sales
    FROM orders
    GROUP BY customer_id
)
SELECT c.customer_id,
       c.customer_name,
       c.segment,
       ct.total_sales,
       RANK() OVER (ORDER BY ct.total_sales DESC) AS overall_rank,
       RANK() OVER (PARTITION BY c.segment ORDER BY ct.total_sales DESC) AS rank_in_segment
FROM customer_totals AS ct
JOIN customers AS c ON c.customer_id = ct.customer_id
ORDER BY ct.total_sales DESC;



-- =========================== 5 : BUSINESS QUERIES =============================


/* ----------------------------------------------------------------------------------
-- # Top 5 customers by total sales
-- Calculated the total sales generated by each customer using a CTE
-- Joined the aggregated sales data with customer details
-- Sorted customers by total sales in descending order
-- Retrieved the top 5 customers with the highest total sales
----------------------------------------------------------------------------------- */
WITH customer_totals AS (
    SELECT customer_id, SUM(sales) AS total_sales
    FROM orders
    GROUP BY customer_id
)
SELECT c.customer_id, c.customer_name, ct.total_sales
FROM customer_totals AS ct
JOIN customers AS c ON c.customer_id = ct.customer_id
ORDER BY ct.total_sales DESC
LIMIT 5;


/* ----------------------------------------------------------------------------------
-- # Bottom 5 customers by total sales
-- Calculated the total sales for each customer using a Common Table Expression (CTE)
-- Joined customer sales with customer details
-- Sorted customers by total sales in ascending order
-- Retrieved the bottom 5 customers with the lowest total sales
----------------------------------------------------------------------------------- */
WITH customer_totals AS (
    SELECT customer_id, SUM(sales) AS total_sales
    FROM orders
    GROUP BY customer_id
)
SELECT c.customer_id, c.customer_name, ct.total_sales
FROM customer_totals AS ct
JOIN customers AS c ON c.customer_id = ct.customer_id
ORDER BY ct.total_sales ASC
LIMIT 5;

/* ----------------------------------------------------------------------------------
-- # Customers who placed only one order
-- Calculated the number of orders and total sales for each customer
-- Grouped records by customer to aggregate order information
-- Filtered customers who have placed exactly one order using the HAVING clause
-- Sorted the results by total sales in descending order
----------------------------------------------------------------------------------- */
SELECT c.customer_id, c.customer_name,
       COUNT(DISTINCT o.order_id) AS orders_placed,
       SUM(o.sales) AS total_sales
FROM customers AS c
JOIN orders AS o ON o.customer_id = c.customer_id
GROUP BY c.customer_id, c.customer_name
HAVING COUNT(DISTINCT o.order_id) = 1
ORDER BY total_sales DESC;

/* ----------------------------------------------------------------------------------
-- # Customers whose total sales are above the average customer total
-- Calculated the total sales generated by each customer using a CTE
-- Joined customer sales with customer details
-- Filtered customers whose total sales exceed the average total sales across all customers
-- Sorted the results in descending order of total sales
----------------------------------------------------------------------------------- */
WITH customer_totals AS (
    SELECT customer_id, SUM(sales) AS total_sales
    FROM orders
    GROUP BY customer_id
)
SELECT c.customer_id, c.customer_name, ct.total_sales
FROM customer_totals AS ct
JOIN customers AS c ON c.customer_id = ct.customer_id
WHERE ct.total_sales > (SELECT AVG(total_sales) FROM customer_totals)
ORDER BY ct.total_sales DESC;

/* ----------------------------------------------------------------------------------
-- # Highest order value per customer
-- Calculated the total value of each order for every customer
-- Ranked orders for each customer based on order value
-- Assigned row number 1 to the highest-value order of each customer
-- Retrieved the highest-value order for each customer
-- Joined with the customers table to obtain customer names
-- Sorted the results by order value in descending order
----------------------------------------------------------------------------------- */
WITH order_values AS (
    SELECT customer_id, order_id, SUM(sales) AS order_value
    FROM orders
    GROUP BY customer_id, order_id
),
ranked AS (
    SELECT customer_id, order_id, order_value,
           ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_value DESC) AS rn
    FROM order_values
)
SELECT c.customer_name, r.order_id, r.order_value
FROM ranked AS r
JOIN customers AS c ON c.customer_id = r.customer_id
WHERE r.rn = 1
ORDER BY r.order_value DESC;