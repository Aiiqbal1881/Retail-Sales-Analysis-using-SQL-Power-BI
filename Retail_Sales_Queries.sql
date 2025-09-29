CREATE DATABASE retail_company;

-- USING THE DATABASE
USE retail_company;

-- 1. Customer Table
CREATE TABLE Customers (
	customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100),
    gender VARCHAR(10),
    city VARCHAR(50),
    state VARCHAR(50),
    country VARCHAR(50)
);

-- inserting the values in customer table
INSERT INTO Customers (customer_id, customer_name, gender, city, state, country)
VALUES 
(1, 'Alice', 'Female', 'New York', 'NY', 'USA'),
(2, 'Bob', 'Male', 'Los Angeles', 'CA', 'USA'),
(3, 'Charlie' , 'Male', 'Chicago', 'IL', 'USA'),
(4, 'Diana', 'Female', 'Houston', 'TX', 'USA'),
(5, 'Eva', 'Female', 'Miami', 'FL', 'USA')
;


-- know about table
DESCRIBE Customers;

SELECT *
FROM Customers;

-- 2. Products Table
CREATE TABLE Products(
	product_id INT PRIMARY KEY,
    product_name VARCHAR(100),
    category VARCHAR(50),
    price DECIMAL(10,2)
    );
    
-- inseting the values in product table
INSERT INTO Products 
VALUES
(101, 'Laptop', 'Electronic', 1200.00),
(102, 'Smartphone', 'Electronic', 800.00),
(103, 'Headphone', 'Electronic', 150.00),
(104, 'Office Chair', 'Furniture', 300.00),
(105, 'Desk', 'Furniture', 450.00),
(106, 'T-shirt', 'Clothing', 25.00),
(107, 'Jeans', 'Clothing', 40.00)
;

-- printing the table of all products details
SELECT *
FROM Products;


-- 3. Sales Table
CREATE TABLE Sales (
	sale_id INT PRIMARY KEY,
    customer_id INT,
    product_id INT,
    quantity INT,
    sale_date DATE,
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id),
    FOREIGN KEY (product_id) REFERENCES Products(product_id)
);

-- Inserting the values in Sales table
INSERT INTO Sales
VALUES
(1001, 1, 101, 1, '2024-01-15'),
(1002, 2, 102, 2, '2024-02-10'),
(1003, 3, 106, 5, '2024-02-12'),
(1004, 4, 104, 1, '2024-03-05'),
(1005, 1, 103, 2, '2024-03-15'),
(1006, 5, 107, 3, '2024-04-01'),
(1007, 2, 105, 1, '2024-04-15'),
(1008, 3, 101, 1, '2024-05-20'),
(1009, 4, 106, 2, '2024-06-11'),
(1010, 5, 102, 1, '2024-06-30')
;

SELECT * FROM Sales WHERE sale_id = 1001;


-- Clear the table before inserting:
TRUNCATE TABLE Sales;   -- just use for some requirement

-- Step 1 :--> Data Exploration
-- Query 1: Count of Customers, Products , and Sales REcords

SELECT
(SELECT COUNT(*) FROM Customers ) AS total_customers,
(SELECT COUNT(*) FROM Products ) AS total_products,
(SELECT COUNT(*) FROM Sales ) AS total_sales_records
;

-- QUERY -2 : First and last sale date
SELECT MIN(sale_data) AS First_sale_date, MAX(sale_data) AS last_sale_date
FROM Sales ;
 
-- Step 2: Sales Analysis
-- Step 2.1: Total Revenue
SELECT  SUM(s.quantity * p.price) AS Total_Revenue
FROM Sales s
JOIN Products p
	ON s.product_id = p.product_id
;

-- step 2.2: Monthly sales Trend
SELECT 
	DATE_FORMAT(s.sale_data, '%Y-%m') AS Month,
    SUM(s.quantity * p.price) AS Monthly_Revenue
FROM Sales s
JOIN Products p
	ON s.product_id = p.product_id
GROUP BY DATE_FORMAT(s.sale_data, '%Y-%m')
ORDER BY Month ;

-- step 2.3: Top 5 Products by Revenue
SELECT p.product_name,p.category , SUM(s.quantity * p.price) AS Total_Revenue
FROM Products p
JOIN Sales s
	ON p.product_id = s.product_id
GROUP BY  p.product_name,p.category
ORDER BY Total_Revenue DESC
LIMIT 5;
    
-- step 2.4: Sales by Category
SELECT p.category , SUM(s.quantity *p.price) AS total_revenue
FROM Sales s
JOIN Products p
	ON s.product_id = p.product_id
GROUP BY p.category
ORDER BY total_revenue DESC
;

-- STEP 2.5:  Top Customers by Spend (Top 10)
SELECT c.customer_id,c.customer_name , 
	SUM(s.quantity *p.price) AS total_revenue,
    COUNT(DISTINCT s.sale_id) AS Transactions, 
    SUM(s.quantity) AS total_units
FROM Sales s
JOIN Customers c
	ON s.customer_id = c.customer_id
JOIN Products p 
	ON s.product_id = p.product_id
GROUP BY c.customer_id,c.customer_name
ORDER BY total_revenue DESC
LIMIT 10 ;
    

-- 2.6: Unique Customers Count
SELECT COUNT(DISTINCT customer_id) AS Unique_customer
FROM Customers;

-- 2.7: Average Order Value (AOV)
SELECT ROUND(AVG(order_revenue),2) AS Average_Order_Value
FROM
(SELECT s.sale_id, SUM(s.quantity * p.price) AS order_revenue   -- order_rvenue per sales_id
FROM Sales s
JOIN Products p 
	ON s.product_id = p.product_id
GROUP BY s.sale_id
) order_totals;


-- 2.8 Sales By State/ Region
SELECT c.state ,
	COUNT(DISTINCT s.sale_id) AS transactions,
    SUM(s.quantity) AS total_units,
	SUM(s.quantity *p.price)AS total_sales_revenue
FROM Sales s
JOIN Customers c
	ON s.customer_id = c.customer_id
JOIN Products p 
	ON s.product_id = p.product_id
GROUP BY c.state
ORDER BY total_sales_revenue DESC
;


-- 2.9: Category Performance(Extended Analysis)

SELECT p.category, SUM(s.quantity * p.price) AS Total_Revenue,
		SUM(s.quantity ) AS Units_Sold,
		COUNT(DISTINCT s.sale_id) AS number_of_transaction
FROM Sales s
JOIN Products p 
	ON s.product_id = p.product_id
GROUP BY p.category
ORDER BY Total_Revenue DESC
;



-- 2.10: Customer Segmentation (RFM Analysis)
-- RFM-> Recency(How recently a cust. made a purchase), Frequency(how many orders a cust. has made), Monetary(total spend by the customer)
-- This is a real-world technique business use to identify: -vip customers, -loyal customer, -At-risk cust. ,-Low-value customer


-- CTE 
WITH cust_metrics AS(
	SELECT c.customer_id, c.customer_name,
		   MAX(s.sale_data) AS last_purchase,
           COUNT(DISTINCT s.sale_id) AS Frequency,
           SUM(s.quantity * p.price) AS Monetary
    FROM Sales s
    JOIN Products p 
		ON s.product_id = p.product_id
	JOIN Customers c 
		ON s.customer_id = c.customer_id
	GROUP BY c.customer_id, c.customer_name
)
SELECT 
		customer_id,
        customer_name,
        DATEDIFF(CURDATE(), last_purchase) AS recency_days,
        Frequency,
        Monetary
FROM cust_metrics
ORDER BY Monetary DESC
;
        
        
WITH cust_metrics AS (
    SELECT 
        c.customer_id,
        c.customer_name,
        MAX(s.sale_data) AS last_purchase,
        COUNT(DISTINCT s.sale_id) AS frequency,
        SUM(s.quantity * p.price) AS monetary
    FROM Sales s
    JOIN Products p ON s.product_id = p.product_id
    JOIN Customers c ON s.customer_id = c.customer_id
    GROUP BY c.customer_id, c.customer_name
),
rfm AS (
    SELECT
        customer_id,
        customer_name,
        DATEDIFF(CURDATE(), last_purchase) AS recency_days,
        frequency,
        monetary,
        -- Recency score: recent = better
        CASE                                                    -- it is Statement like work as( If else Statment) -> CASE End 
            WHEN DATEDIFF(CURDATE(), last_purchase) <= 30 THEN 3
            WHEN DATEDIFF(CURDATE(), last_purchase) <= 90 THEN 2
            ELSE 1
        END AS recency_score,
        -- Frequency score
        CASE 
            WHEN frequency >= 10 THEN 3
            WHEN frequency >= 5 THEN 2
            ELSE 1
        END AS frequency_score,
        -- Monetary score
        CASE 
            WHEN monetary >= 1000 THEN 3
            WHEN monetary >= 500 THEN 2
            ELSE 1
        END AS monetary_score
    FROM cust_metrics
)
SELECT 
    customer_id,
    customer_name,
    recency_days,
    frequency,
    monetary,
    recency_score,
    frequency_score,
    monetary_score,
    (recency_score + frequency_score + monetary_score) AS rfm_total
FROM rfm
ORDER BY rfm_total DESC, monetary DESC;



SELECT * 
FROM Sales ;














