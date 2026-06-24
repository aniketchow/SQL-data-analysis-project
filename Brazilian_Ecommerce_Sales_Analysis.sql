				--==============================================
					--Brazilian Ecommerce Sales Analysis--
				--==============================================

--===============
--1.TNTRODUCTION--
--===============
/* 
This project focuses on analyzing a Brazilian ecommerce dataset using SQL.
The objective is to gain insights into sales performance, customer purchasing 
behaviour, product categories, saller performance, payment methods, and delivery 
trends. Through various SQL queries and KPI analysis, the project identifies key 
business insights that can help improve revenue, customer experience and overall
business performance.
*/

--=====================================
	--2. DATASET SCHEMA CREATION --
--=====================================

CREATE TABLE Customers(
		customer_id VARCHAR(100) PRIMARY KEY,
		unique_customer_id VARCHAR(100) NOT NULL,
		zip_code INT,
		city VARCHAR(50),
		state CHAR(2)
);

CREATE TABLE Products(
		product_id VARCHAR(100) PRIMARY KEY,
		category VARCHAR(100),
		weight_g INT,
		length_cm INT,
		height_cm INT,
		width_cm INT
);

CREATE TABLE Orders(
		order_id VARCHAR(100) PRIMARY KEY,
		customer_id VARCHAR(100),
		order_status VARCHAR(20),
		order_date TIMESTAMP,
		approved_date TIMESTAMP,
		shipped_date TIMESTAMP,
		delivered_date TIMESTAMP,
		estimated_delivery_date TIMESTAMP
);

CREATE TABLE Order_items(
		order_id VARCHAR(100),
		order_item_id INT,
		product_id VARCHAR(100),
		seller_id VARCHAR(100),
		shipping_limit_date TIMESTAMP,
		price NUMERIC(10,2),
		freight_value NUMERIC(10,2),
		PRIMARY KEY(order_id, order_item_id)
);

CREATE TABLE Order_payments(
		order_id VARCHAR(100),
		payment_sequential INT,
		payment_type VARCHAR(20),
		payment_installments INT,
		payment_value NUMERIC(10,2),
		PRIMARY KEY(order_id, payment_sequential)
);

CREATE TABLE Sellers(
		seller_id VARCHAR(100) PRIMARY KEY,
		seller_zip_code INT,
		seller_city VARCHAR(100),
		seller_state CHAR(2)
);

SELECT * FROM Customers;
SELECT * FROM Products;
SELECT * FROM Orders;
SELECT * FROM Order_items;
SELECT * FROM Order_payments;
SELECT * FROM Sellers;


--=========================
	--3. DATA IMPORT --
--=========================

--Import data into Customers table.
COPY Customers(customer_id,	unique_customer_id,	zip_code, city,	state)
FROM'C:\Program Files\PostgreSQL\Customers.csvdataset.csv'
DELIMITER','
CSV HEADER;

--Import data into Products table
COPY Products(product_id, category,	weight_g, length_cm, height_cm,	width_cm)
FROM'C:\Program Files\PostgreSQL\products.csv.dataset.csv'
DELIMITER','
CSV HEADER;

--Import data into Orders table
COPY Orders(order_id, customer_id, order_status, order_date, approved_date,	shipped_date, delivered_date, estimated_delivery_date)
FROM'C:\Program Files\PostgreSQL\orders.csv.dataset.csv'
DELIMITER','
CSV HEADER;

--Import data into Order_items table.
COPY Order_items(order_id,  order_item_id, product_id, seller_id, shipping_limit_date, price, freight_value)
FROM'C:\Program Files\PostgreSQL\Order_items.dataset.csvcsv.csv'
DELIMITER','
CSV HEADER;

--Import data into Order_payments table.
COPY Order_payments(order_id, payment_sequential, payment_type,	payment_installments, payment_value)
FROM'C:\Program Files\PostgreSQL\order_payment.DATASET.csv'
DELIMITER','
CSV HEADER;

--Import data into Sellers table.
COPY Sellers(seller_id,	seller_zip_code, seller_city, seller_state)
FROM'C:\Program Files\PostgreSQL\sellers.dataset.csv'
DELIMITER','
CSV HEADER;


--==============================
	--4. DATA CLEANING -- 
--==============================

-- CUSTOMERS TABLE --

--1. Checking NULL values
SELECT *
FROM Customers
WHERE customer_id IS NULL
	OR city IS NULL
	OR state IS NULL

--2. Checking duplicate records
SELECT customer_id,
	COUNT(*) AS Total
	FROM Customers
	GROUP BY customer_id
	HAVING COUNT(*) > 1;

--3. Remove extra spaces
UPDATE Customers
SET city = TRIM(city);

--4. Standardizing city names
UPDATE Customers
SET city = INITCAP(city);


-- PRODUCTS TABLE --

--1. Checking NULL values
SELECT *
FROM Products
WHERE product_id IS NULL
	OR category IS NULL;

--2. Replacing NULL category with 'Unknown'.
UPDATE Products
SET category = 'Unknown'
WHERE category IS NULL;

SELECT * 
FROM Products
WHERE category ='Unknown';

--3. Checking duplicate products.
SELECT product_id,
	COUNT(*) AS Total
FROM Products
GROUP BY product_id
HAVING COUNT(*) > 1;

--Standardizing category names
UPDATE Products
SET category = INITCAP(category);


-- ORDERS TABLE --

--1. Checking NULL values.
SELECT * 
FROM Orders
WHERE order_id IS NULL
	OR customer_id IS NULL
	OR order_status IS NULL;

--2. Checking missing dates
SELECT *
FROM Orders
WHERE order_date IS NULL
	OR approved_date IS NULL
	OR shipped_date IS NULL
	OR delivered_date is NULL 
	OR estimated_delivery_date IS NULL;

/* RESULT:
	NULL dates were found mainly for cancelled or undelivered orders. Records were 
	retained to preserve order history */

--3. Checking duplicate records.
SELECT order_id,
	COUNT(*) AS Total
FROM Orders
GROUP BY order_id
HAVING COUNT(*) > 1;

--4. Checking unique order status
SELECT DISTINCT order_status
FROM Orders;


-- ORDER_ITEMS TABLE --

--1. Checking duplicate rows.
SELECT *,
COUNT(*)
FROM Order_items
GROUP BY order_id, order_item_id, product_id, seller_id, shipping_limit_date, price,
freight_value
HAVING COUNT(*) > 1;

/* Result-- "Checked for duplicates records in the order_items table 
             and no duplicates found". */

--2. Checking NULL values
SELECT 
COUNT(*) FILTER(WHERE order_id IS NULL) AS null_order_id,
COUNT(*) FILTER(WHERE order_item_id IS NULL) AS null_order_item_id,
COUNT(*) FILTER(WHERE product_id IS NULL) AS null_product_id,
COUNT(*) FILTER(WHERE seller_id IS NULL) AS null_seller_id,
COUNT(*) FILTER(WHERE price IS NULL) AS null_price,
COUNT(*) FILTER(WHERE freight_value IS NULL) AS null_freight_value
FROM Order_items;

/* Result-- "Checked NULL values in important columns and found no 
			 missing values" */

--3. Checking spaces.
SELECT * 
FROM Order_items 
WHERE seller_id != TRIM(seller_id)
OR product_id != TRIM(product_id);

--4. Checking invalid values.
SELECT *
FROM Order_items
WHERE price <= 0
OR freight_value < 0;

/* Result-- "Checked invalid values and found no invalid values" */


-- ORDER_PAYMENTS TABLE --

--1. Checking duplicates
SELECT order_id, payment_sequential,
COUNT (*)
FROM Order_payments
GROUP BY order_id, payment_sequential
HAVING COUNT(*) > 1;

--2. Checking NULL values.
SELECT 
COUNT(*) FILTER(WHERE payment_type IS NULL) AS null_payment_type,
COUNT(*) FILTER(WHERE payment_value IS NULL) AS null_payment_value
FROM Order_payments;

--3. Checking invalid payment values and invalid payment_installments.
SELECT *
FROM Order_payments
WHERE payment_value <= 0
AND payment_installments < 0;


-- SELLERS TABLE --

--1. Checking duplicates
SELECT seller_id, seller_zip_code, 
COUNT(*)
FROM Sellers
GROUP BY seller_id, seller_zip_code
HAVING COUNT(*) > 1;

--2. Checking NULL values
SELECT
COUNT(*) FILTER(WHERE seller_city IS NULL) AS null_seller_city,
COUNT(*) FILTER(WHERE seller_state IS NULL) AS null_seller_state
FROM Sellers;

--3. Standardizing city names
UPDATE Sellers
SET seller_city = INITCAP(seller_city);


/*===========================5.SQL ANALYSIS QUERIES===================================*/


--==============================
--BEGINNER SQL QUERIES--
--==============================

--1. Find total number of customers.
SELECT COUNT(*) AS Total_customers
FROM Customers;

--2. Show all unique states where customers are loctaed.
SELECT DISTINCT state
FROM Customers
ORDER BY state;


--3. Count custoemrs from each state.
SELECT state, 
COUNT(*) AS total_customers
FROM Customers
GROUP BY state
ORDER BY total_customers DESC;

--4. Find top 10 cities with highest customers.
SELECT city,
COUNT(*) AS total_customers
FROM Customers
GROUP BY city
ORDER BY total_customers DESC
LIMIT 10;

--5. Find total number of orders.
SELECT COUNT(DISTINCT order_id) AS total_orders
FROM Orders;

--6. Count orders by status.
SELECT order_status,
COUNT(*) AS total_orders
FROM Orders
GROUP BY order_status
ORDER BY total_orders DESC;

--7. Find orders placed in 2018.
SELECT *
FROM Orders
WHERE EXTRACT(YEAR FROM order_date) = 2018;

--8. Find monthly order count.
SELECT TO_CHAR(order_date, 'YYYY-MM') AS Month,
	COUNT(*) AS total_orders
FROM Orders
GROUP BY Month
ORDER BY Month;

--9. Find latest and earliest orders.
SELECT
	MIN(order_date) AS earliest_order,
	MAX(order_date) AS latest_order
FROM Orders;

--10. Find total payment amount.
SELECT 
	SUM(payment_value) AS Total_payment_amount
FROM Order_payments;

--11. find average payment amount.
SELECT 
	AVG(payment_value) AS Average_payment
FROM Order_payments;

--12. Count orders by payment method.
SELECT payment_type,
	COUNT(order_id) AS Total_orders
FROM Order_payments
GROUP BY payment_type;

--13. Find highest single payment.
SELECT 
	MAX(payment_value) AS highest_payment
FROM Order_payments;

--14. Count total products.
SELECT
	COUNT(DISTINCT product_id) AS Total_products
FROM Products;

--15. Find top product categories.
SELECT category,
	COUNT(*) AS Total_products
FROM Products
GROUP BY category
ORDER BY Total_products DESC;

--16. Find products with highest weight.
SELECT 
	product_id,
	category,
	weight_g
FROM Products
WHERE weight_g IS NOT NULL
ORDER BY weight_g DESC
LIMIT 10;

--17. Find average product price.
SELECT 
	ROUND(AVG(price) ,2 ) AS Average_product_price 
FROM Order_items;

--18. Find top 10 expensive product sold.
SELECT product_id,
	   price
FROM Order_items
ORDER BY price DESC
LIMIT 10;

--19. Find total shipping cost.
SELECT 
	SUM(freight_value) AS Total_shipping_cost
FROM Order_items;

--20. Find all unique seller state.
SELECT DISTINCT seller_state
FROM Sellers;


--=====================================
-- INTERMEDIATE SQL QUERIES --           
--=====================================

SELECT * FROM Customers;
SELECT * FROM Products;
SELECT * FROM Orders;
SELECT * FROM Order_items;
SELECT * FROM Order_payments;
SELECT * FROM Sellers;

-- Find total sales by month.
SELECT
	DATE_TRUNC('month', o.order_date) AS Month,
	ROUND(SUM(op. payment_value), 2) AS Total_sales
	FROM Orders o
	JOIN Order_payments op
	ON o.order_id = op. order_id
	GROUP BY MONTH
	ORDER BY MONTH;

-- Find top 10 selling product categories.
SELECT 
	p. category,
	COUNT(oi. order_id) AS Total_sales
	FROM Order_items oi
	JOIN Products p
	ON oi. product_id = p. product_id
	GROUP BY category
	ORDER BY Total_sales DESC
	LIMIT 10;

--Find top 10 highest revenue generating product with category.
SELECT
	p.product_id,
	p.category,
	ROUND(SUM(oi.price), 2) AS Total_revenue
FROM Order_items oi
JOIN Products p
ON p.product_id = oi.product_id
GROUP BY p.product_id, p.category
ORDER BY Total_revenue DESC
LIMIT 10;

-- Find average order value.
SELECT
	ROUND(SUM(payment_value) / COUNT(DISTINCT order_id), 2) AS Average_order_value
FROM Order_payments;

--Find total revenue by state.
SELECT 
	c.state,
	ROUND(SUM(op.payment_value),2) AS Total_revenue
FROM Customers c
JOIN Orders o
ON c.customer_id = o.customer_id
JOIN Order_payments op
ON o.order_id = op.order_id
GROUP BY c.state
ORDER BY Total_revenue DESC;

-- Find revenue contribution percentage by category.
SELECT
	p.category,
	ROUND(SUM(oi.price),2) AS Total_revenue,
	CONCAT(
	ROUND(
		(SUM(oi.price) * 100.0) /
		(SELECT SUM(price) FROM Order_items), 2),'%') AS Revenue_percentage
FROM Order_items oi
JOIN Products p
ON p.product_id = oi.product_id
GROUP BY p.category
ORDER BY Revenue_percentage DESC;

-- Find repeat customers.
SELECT 
	c.unique_customer_id,
	COUNT(o.order_id) AS Total_orders
FROM Orders o
JOIN Customers c
ON c.customer_id = o.customer_id
GROUP BY c.unique_customer_id
HAVING COUNT(o.order_id) > 1
ORDER BY Total_orders DESC;

-- Find customers with more than 5 orders.
SELECT 
	c.unique_customer_id,
	COUNT(o.order_id) AS Total_orders
FROM Customers c
JOIN Orders o
ON c.customer_id = o.customer_id
GROUP BY c.unique_customer_id
HAVING COUNT(o.order_id) >5
ORDER BY Total_orders DESC;

-- Find top customers by spending.
SELECT 
	c.unique_customer_id,
	ROUND(SUM(op.payment_value),2) AS Total_spent
FROM Customers c
JOIN Orders o
ON c.customer_id = o.customer_id
JOIN Order_payments op
ON o.order_id = op.order_id
GROUP BY c.unique_customer_id
ORDER BY Total_spent DESC
LIMIT 10;

--Find average order per customer.
SELECT 
	ROUND(COUNT(order_id) / COUNT(DISTINCT customer_id) ,2) AS Avg_order_per_customer
FROM Orders;

-- Find average delivery time.
SELECT 
	 AVG(DATE_PART('day', delivered_date - order_date)) AS avg_delivery_days
FROM Orders
WHERE delivered_date IS NOT NULL;

-- Find delayed orders where delivered date > estimated date.
SELECT 
	order_id,
	delivered_date,
	estimated_delivery_date
FROM Orders
WHERE delivered_date > estimated_delivery_date;

--Find states with highest delivery delays.
SELECT
	c.state,
	ROUND(AVG(DATE_PART('days', o.delivered_date - o.estimated_delivery_date))::numeric,2) AS Avg_delay_days
FROM Orders o
JOIN Customers c
ON c. customer_id = o.customer_id
WHERE delivered_date > estimated_delivery_date
GROUP BY state
ORDER BY Avg_delay_days DESC;

-- Find fastest delivery sates.
SELECT 
	c.state,
	ROUND(AVG(DATE_PART('days', o.delivered_date - order_date))::numeric,2) AS Avg_delivery_days
FROM Orders o
JOIN Customers c
ON c.customer_id = o.customer_id
WHERE delivered_date IS NOT NULL
GROUP BY state
ORDER BY Avg_delivery_days ASC;

-- Find most used payment method.
SELECT 
	payment_type,
	COUNT(*) AS Total_usage
FROM Order_payments
GROUP BY payment_type
ORDER BY Total_usage DESC;

-- Find installment vs non-installment payments.
SELECT
	CASE 
	WHEN payment_installments > 1 THEN 'Installment'
	ELSE 'Non-installment'
	END AS payment_type_category,
	COUNT(*) AS Total_payments
FROM Order_payments
GROUP BY payment_type_category;

-- Find average payment by payment type.
SELECT
	payment_type,
	ROUND(AVG(payment_value)::numeric,2) AS Avg_payment
FROM Order_payments
GROUP BY payment_type
ORDER BY Avg_payment DESC;

-- Find top sellers by revenue.
SELECT
	oi.seller_id,
	ROUND(SUM(op.payment_value),2) AS total_revenue
FROM Order_payments op
JOIN Order_items oi
ON op.order_id = oi.order_id
GROUP BY oi.seller_id
ORDER BY total_revenue DESC;

-- Find sellers with highest number of orders.
SELECT 
	seller_id,
	COUNT(DISTINCT order_id) AS total_orders
FROM Order_items
GROUP BY seller_id
ORDER BY total_orders DESC
LIMIT 10;

--Find top seller state.
SELECT 
	seller_state,
	COUNT(seller_id) AS Total_sellers
FROM Sellers
GROUP BY seller_state
ORDER BY Total_sellers DESC;


--================================
--ADVANCED SQL QUERIES
--================================

SELECT * FROM Customers;
SELECT * FROM Products;
SELECT * FROM Orders;
SELECT * FROM Order_items;
SELECT * FROM Order_payments;
SELECT * FROM Sellers;

-- Rank top products by revenue.
SELECT
	product_id,
	SUM(price+freight_value) AS Total_revenue,
	RANK() OVER(ORDER BY SUM(price+freight_value)DESC) AS Revenue_rank
FROM Order_items
GROUP BY product_id;

-- Find running monthly revenue.
SELECT
	DATE_TRUNC('month',order_date) AS Month,
	SUM(payment_value) AS Monthly_revenue,
	SUM(SUM(payment_value)) OVER(ORDER BY DATE_TRUNC('month',order_date))
	AS Running_revenue
FROM Orders o
JOIN Order_payments op
ON o.order_id = op.order_id
GROUP BY Month
ORDER BY Month;

-- Find cumulative sales over time.
SELECT
 	 DATE(o.order_date) AS Order_date,
	 ROUND(SUM(op.payment_value),2) AS Daily_sales,
	 ROUND(SUM(SUM(payment_value)) OVER(ORDER BY DATE(order_date)),2) AS Cumulative_sales
FROM Orders o
JOIN Order_payments op 
ON o.order_id = op.order_id
GROUP BY DATE(o.order_date)
ORDER BY Order_date;

-- Find Recency, Frequency and Monetary.
SELECT
	c.unique_customer_id,
	MAX(o.order_date) AS last_order_date,
	MAX(DATE(o.order_date)) AS Recency,
	COUNT(DISTINCT o.order_id) AS Frequency,
	ROUND(SUM(op.payment_value),2) AS Monetary
FROM Customers c
JOIN Orders o
ON c.customer_id = o.customer_id
JOIN Order_payments op
ON o.order_id = op.order_id
WHERE o.order_status = 'delivered'
GROUP BY c.unique_customer_id
ORDER BY last_order_date DESC;

-- Segment customers into: High value, Medium value, Low value.
SELECT 
	c.unique_customer_id,
	ROUND(SUM(op.payment_value),2) AS Monetary,
	CASE
		WHEN SUM(op.payment_value) >= 3000 THEN 'High value'
		WHEN SUM(op.payment_value) >= 1500 THEN 'Medium value'
		ELSE 'Low value'
	END AS customer_segment
FROM Customers c
JOIN Orders o
ON c.customer_id = o.customer_id
JOIN Order_payments op
ON o.order_id = op.order_id 
where o.order_status = 'delivered'
GROUP BY c.unique_customer_id
ORDER BY Monetary DESC;

-- Find customers at risk of churn.
SELECT 
	c.unique_customer_id,
	MAX(DATE(o.order_date)) AS last_order_date,
	CURRENT_DATE - MAX(DATE(o.order_date)) AS days_since_last_order,
	CASE
		WHEN CURRENT_DATE - MAX(DATE(o.order_date)) >3000
		THEN 'At risk'
		ELSE 'Active'
	END AS customer_status
FROM Customers c
JOIN Orders o
ON c.customer_id = o.customer_id
WHERE o.order_status = 'delivered'
GROUP BY c.unique_customer_id;

-- Find products frequently bought together.
SELECT 
	oi1.product_id AS product_1,
	oi2.product_id AS product_2,
	COUNT(DISTINCT oi1.order_id) AS times_together_bought
	FROM Order_items oi1
	JOIN Order_items oi2
	ON oi1.product_id < oi2.product_id
	GROUP BY 
		oi1.product_id,
		oi2.product_id
ORDER BY times_together_bought DESC
LIMIT 10;

-- Find category contributing highest profit.
SELECT 
	p.category,
	ROUND(SUM(oi.price),2) AS Total_revenue
FROM Order_items oi
JOIN Products p
ON p.product_id = oi.product_id
GROUP BY p.category
ORDER BY Total_revenue DESC
LIMIT 1;

-- Find seasonal sales trends.
SELECT 
	DATE_TRUNC('month', o.order_date) AS Month,
	ROUND(SUM(oi.price),2) AS Total_sales
FROM Order_items oi
JOIN Orders o
ON o.order_id = oi.order_id
GROUP BY Month
ORDER BY Month;

-- Find relationship between shipping cost and delivery speed.
SELECT
	CASE
		WHEN oi.freight_value < 20 THEN 'Low shipping cost'
		WHEN oi.freight_value BETWEEN 20 AND 50 THEN 'Medium shipping cost'
		ELSE 'High shipping cost'
	END AS Shipping_category,
	ROUND(AVG(DATE_PART('day', o.delivered_date - order_date))::numeric,2) AS avg_delivery_days
FROM Orders o
JOIN Order_items oi
ON o.order_id = oi.order_id
WHERE o.delivered_date IS NOT NULL
GROUP BY Shipping_category
ORDER BY avg_delivery_days;

-- Find seller performance based on delivery time.
SELECT 
	s.seller_id,
	ROUND(AVG(DATE_PART('days',o.delivered_date - o.order_date))::numeric,2) AS Avg_delivery_days,
	RANK()OVER(ORDER BY AVG(DATE_PART('day',o.delivered_date - o.order_date))) AS Sellere_rank
FROM Order_items oi
JOIN Sellers s
ON s.seller_id = oi.seller_id
JOIN Orders o
ON oi.order_id = o.order_id
GROUP BY s.seller_id;

--Find states with worst logistics performance.
SELECT
	c.state,
	ROUND(AVG(DATE_PART('days',o.delivered_date - o.order_date))::numeric,2) AS Avg_delivery_days,
	COUNT(o.order_id) AS Total_orders
FROM Customers c
JOIN Orders o
ON c.customer_id = o.customer_id
WHERE o.delivered_date IS NOT NULL
GROUP BY c.state
ORDER BY Avg_delivery_days DESC;


--====================================
-- Business case Questions --
--====================================
	
-- Which category should company promote more.
SELECT 
	p.category,
	COUNT(oi.order_id) AS total_orders,
	ROUND(SUM(oi.price),2) AS total_sales
FROM Products p
JOIN Order_items oi
ON p.product_id = oi.product_id
GROUP BY p.category
ORDER BY total_sales ASC;

/*
Objective:
Find category with lower sales to identify promotion opportunities
*/

-- Which states generate high revenue but low order count.
SELECT 
	c.state,
	COUNT(DISTINCT oi.order_id) AS total_orders,
	ROUND(SUM(oi.price),2) AS total_revenue,
	ROUND(SUM(oi.price) / COUNT(DISTINCT oi.order_id),2) AS Avg_order_value
FROM Customers c
JOIN Orders o
ON c.customer_id = o.customer_id
JOIN Order_items oi
ON o.order_id = oi.order_id
GROUP BY c.state
ORDER BY Avg_order_value DESC;

/*
Objective:
Identify states where customers place fewer orders but spend more
money per order.
*/

-- Which payment method brings highest revenue.
SELECT 
	payment_type,
	COUNT(DISTINCT order_id) AS Total_orders,
	ROUND(SUM(payment_value),2) AS Total_revenue
FROM Order_payments
GROUP BY payment_type
ORDER BY Total_revenue DESC;

--Which sellers should company prioritize.
SELECT 
	s.seller_id,
	COUNT(DISTINCT oi.order_id) AS total_orders,
	ROUND(SUM(op.payment_value),2) AS total_revenue,
	ROUND(AVG(op.payment_value),2) AS avg_order_value
FROM Sellers s
JOIN Order_items oi
ON s.seller_id = oi.seller_id
JOIN Order_payments op
ON oi.order_id = op.order_id
GROUP BY s.seller_id
HAVING SUM(op.payment_value) > 50000
ORDER BY total_revenue desc;

/*
Objective:
This analysis helps identify high performing sellers contributing significantly to
company revenue and order volume.these sellers can be prioritize for partnerships,
promotion,inventory support and retention strategies.
*/


--====================6.KEY PERFORMANCE INDICATORS(KPIs)==============================--

SELECT * FROM Customers;
SELECT * FROM Products;
SELECT * FROM Orders;
SELECT * FROM Order_items;
SELECT * FROM Order_payments;
SELECT * FROM Sellers;

-- Total revenue
SELECT
	ROUND(SUM(payment_value),2) AS Total_revenue
FROM Order_payments;
/*
Insight: The business generated total revenue of $16.01 million, demonstrating 
strong sales performance and healthy customer demand during the analyzed
period. 
*/

-- Total_orders 
SELECT
	COUNT(DISTINCT order_id) AS Total_orders
FROM Orders;
/*
Insight: The platform processed 99,441 orders, reflecting high sales volume
and customer demand.
*/

-- Total Customers
SELECT COUNT(DISTINCT customer_id) AS total_customers 
FROM Orders;
/*
Insight: The platform served 99,441 unique customersduring the analyis period
indicating a broad customer base and strong market reach
*/

-- Total Sellers
SELECT 
	COUNT(DISTINCT seller_id) AS total_sellers
FROM Sellers;
/*
Insight: The platform has 3095 active sellers contributing to product
availability and marketplace growth.
*/

-- Total Categories
SELECT 
	COUNT(DISTINCT category) AS total_category
FROM Products;
/*
Insight: Products are distributed across 74 categories, highlighting
the platform's broad product variety.
*/

-- Total Products
SELECT 
	COUNT(DISTINCT product_id) AS total_products
FROM Products;
/*
Insight: The platform maintains 32,951 products, supporting customer demand 
accross various categories.
*/

-- Repeat Customers
SELECT
	COUNT(*) AS repeat_customers
FROM (SELECT c.unique_customer_id
		FROM Orders o
		JOIN Customers c 
		ON c.customer_id = o.customer_id
		GROUP BY unique_customer_id
		HAVING COUNT(order_id) > 1) AS t;
/*
Insight: I analyzed repeat customers using unique_customer_id
and found 2,997 customers who placed more than one order.
*/

-- Average order value 
SELECT
	ROUND(SUM(payment_value) / COUNT(DISTINCT order_id),2) AS avg_order_value
FROM Order_payments;
/*
Insight: Customers spent an average of $160.99 per order, reflecting the platform's
average transaction value.
*/

-- Monthly revenue trend
SELECT
	TO_CHAR(order_date, 'YYYY-MM') AS month,
	ROUND(SUM(op.payment_value),2) AS revenue
FROM Orders o
JOIN Order_payments op
ON o.order_id = op.order_id
GROUP BY month 
ORDER BY month;
/*
Insight: revenue varied accross months, suggesting seasonal trends and changes
in customers purchasing behaviour.
*/

-- Top product category by revenue
SELECT 
	p.category,
	ROUND(SUM(oi.price),2) AS revenue
FROM Order_items oi
JOIN Products p
ON p.product_id = oi.product_id
GROUP BY p.category
ORDER BY revenue DESC 
limit 10;
/*
Insight: Beleza_Saude was the highest revenue generating product category,
indicating strong customer demand and a significant contribution to 
overall sales.
*/

-- Revenue by state
SELECT
	c.state,
	ROUND(SUM(op.payment_value),2) AS revenue
FROM Orders o
JOIN Customers c
ON c.customer_id = o.customer_id
JOIN Order_payments op
ON o.order_id = op.order_id
GROUP BY c.state
ORDER BY revenue DESC;
/*
Insight: SP generated the highest revenue among all states,
indicating a strong customer base and significant contribution 
to overall sales.
*/

-- Most used payment method
SELECT payment_type,
	COUNT(*) AS total_transactions
FROM Order_payments
GROUP BY payment_type
ORDER BY total_transactions DESC;
/* 
Insights: Credit card dominated transactions, making it the platform's 
primary payment method.
*/

-- Delivery delay
SELECT
	COUNT(*) AS delayed_orders
FROM Orders
WHERE delivered_date > estimated_delivery_date;
/*
Insight: A total of 7827 orders were delivered later than the estimated delivery
date.
*/

-- Top sellers by revenue
SELECT 	
	seller_id,
	ROUND(SUM(price),2) AS revenue
FROM Order_items 
GROUP BY seller_id
ORDER BY revenue DESC 
LIMIT 10;
/*
Insight: Top sellers contributed the highest revenue, making them
key drivers of business growth.
*/


/*
=================
7. CONCLUSION:
==================
The KPI analysis revealed important insights into sales performance,
customer purchasing behaviour, seller performance, paymemt preferences 
and delivery operations. These findings demonstrate how SQL can be used
to support data driven business decisions.






