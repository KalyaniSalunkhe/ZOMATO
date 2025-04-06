---SQL project---

----ZOMATO PROJECT----

CREATE DATABASE ZOMATO;
USE ZOMATO;




-- Create the 'product' table
DROP TABLE IF EXISTS product;
CREATE TABLE product (
    product_id INTEGER,         -- Unique identifier for each product
    product_name TEXT,          -- Name of the product (e.g., p1, p2, etc.)
    price INTEGER               -- Price of the product in Rs.
);



-- Insert data into the 'product' table

INSERT INTO product (product_id, product_name, price) 
VALUES
    (1, 'p1', 980),  -- Product ID 1, Name: p1, Price: 980 Rs
    (2, 'p2', 870),  -- Product ID 2, Name: p2, Price: 870 Rs
    (3, 'p3', 330);  -- Product ID 3, Name: p3, Price: 330 Rs




-- Create the 'users' table
DROP TABLE IF EXISTS users;
CREATE TABLE users (
    userid INTEGER,             -- Unique identifier for each user
    signup_date DATE            -- Date when the user signed up
);



-- Insert data into the 'users' table
INSERT INTO users (userid, signup_date) 
VALUES 
    (1, '2014-09-02'),  -- User ID 1, Signup Date: 2014-09-02
    (2, '2015-01-15'),  -- User ID 2, Signup Date: 2015-01-15
    (3, '2014-04-11');  -- User ID 3, Signup Date: 2014-04-11



-- Create the 'goldusers_signup' table
DROP TABLE IF EXISTS goldusers_signup;
CREATE TABLE goldusers_signup (
    userid INTEGER,             -- Unique identifier for each gold member
    gold_signup_date DATE       -- Date the user became a gold member
);


-- Insert data into the 'goldusers_signup' table
INSERT INTO goldusers_signup (userid, gold_signup_date) 
VALUES 
    (1, '2017-09-22'),  -- User ID 1, Gold Signup Date: 2017-09-22
    (3, '2017-04-21');  -- User ID 3, Gold Signup Date: 2017-04-21


-- Create the 'sale' table
DROP TABLE IF EXISTS sale;
CREATE TABLE sale (
    userid INTEGER,             -- User who made the purchase
    created_date DATE,          -- Date of the purchase
    product_id INTEGER          -- Product purchased (linked to the 'product' table)
);


-- Insert data into the 'sale' table
INSERT INTO sale (userid, created_date, product_id) 
VALUES 
    (1, '2017-04-19', 2),  -- User ID 1, Purchase Date: 2017-04-19, Product ID: 2
    (3, '2019-12-18', 1),  -- User ID 3, Purchase Date: 2019-12-18, Product ID: 1
    (2, '2020-07-20', 3),  -- User ID 2, Purchase Date: 2020-07-20, Product ID: 3
    (1, '2019-10-23', 2),  -- User ID 1, Purchase Date: 2019-10-23, Product ID: 2
    (1, '2018-03-19', 3),  -- User ID 1, Purchase Date: 2018-03-19, Product ID: 3
    (3, '2016-12-20', 2),  -- User ID 3, Purchase Date: 2016-12-20, Product ID: 2
    (1, '2016-11-09', 1),  -- User ID 1, Purchase Date: 2016-11-09, Product ID: 1
    (1, '2016-05-20', 3),  -- User ID 1, Purchase Date: 2016-05-20, Product ID: 3
    (2, '2017-09-24', 1),  -- User ID 2, Purchase Date: 2017-09-24, Product ID: 1
    (1, '2017-03-11', 2),  -- User ID 1, Purchase Date: 2017-03-11, Product ID: 2
    (1, '2016-03-11', 1),  -- User ID 1, Purchase Date: 2016-03-11, Product ID: 1
    (3, '2016-11-10', 1),  -- User ID 3, Purchase Date: 2016-11-10, Product ID: 1
    (3, '2017-12-07', 2),  -- User ID 3, Purchase Date: 2017-12-07, Product ID: 2
    (3, '2016-12-15', 2),  -- User ID 3, Purchase Date: 2016-12-15, Product ID: 2
    (2, '2017-11-08', 2),  -- User ID 2, Purchase Date: 2017-11-08, Product ID: 2
    (2, '2018-09-10', 3);  -- User ID 2, Purchase Date: 2018-09-10, Product ID: 3


	SELECT * FROM sale;
	SELECT * FROM product;
	SELECT * FROM goldusers_signup;
	SELECT * FROM users;

	

	--Questions Set--

--1. What is the total amount each customer spent on Zomato?

SELECT s.userid,SUM(price) AS Total_Amount
FROM sale s
INNER JOIN 
product p
ON s.product_id =p.product_id
GROUP BY s.userid;

--2. How many days has each customer visited Zomato?

SELECT s .userid,COUNT(distinct created_date) AS Total_Days
FROM sale s
GROUP BY s .userid;


--3. What is the first product purchased by each customer after signup?
SELECT *
FROM
(
SELECT * ,
DENSE_RANK () OVER (PARTITION BY userid ORDER BY created_date) RN
FROM sale
) AS ranked_sales
WHERE RN=1;

--4. What is the most purchased item on the menu and how many times it is purchased by all customers?

SELECT userid,COUNT(product_id) AS count_product
FROM sale WHERE product_id=(SELECT TOP 1 product_id FROM sale GROUP BY product_id ORDER BY COUNT(product_id) desc)
GROUP BY userid;

--5. Which item was most popular for each customer?

WITH ProductCount AS (
SELECT 
userid,
product_id,
COUNT(product_id) AS product_count
FROM sale
GROUP BY userid, product_id
),
RankedProducts AS (
SELECT 
userid,
product_id,
product_count,
ROW_NUMBER() OVER (PARTITION BY userid ORDER BY product_count DESC) AS rank
FROM ProductCount
)
SELECT 
userid,
product_id,
product_count
FROM RankedProducts
WHERE rank = 1;


--6. Which item was first purchased by a customer after becoming gold member?
WITH FirstPurchaseAfterGold AS (
SELECT 
s.userid,
s.product_id,
s.created_date,
g.gold_signup_date,
ROW_NUMBER() OVER (PARTITION BY s.userid ORDER BY s.created_date) AS purchase_rank
FROM sale s
JOIN goldusers_signup g ON s.userid = g.userid
WHERE s.created_date > g.gold_signup_date
)
SELECT 
f.userid,
p.product_name,
f.created_date AS first_purchase_date
FROM FirstPurchaseAfterGold f
JOIN product p ON f.product_id = p.product_id
WHERE f.purchase_rank = 1;


--7. Which item was purchased just before becoming a member?

WITH LastPurchaseBeforeGold AS (
SELECT 
s.userid,
s.product_id,
s.created_date,
g.gold_signup_date,
ROW_NUMBER() OVER (PARTITION BY s.userid ORDER BY s.created_date DESC) AS purchase_rank
FROM sale s
JOIN goldusers_signup g ON s.userid = g.userid
WHERE s.created_date < g.gold_signup_date
)
SELECT 
f.userid,
p.product_name,
f.created_date AS last_purchase_date
FROM LastPurchaseBeforeGold f
JOIN product p ON f.product_id = p.product_id
WHERE f.purchase_rank = 1;

--8. What is the total orders and amount spent by each customer before they became a member?

SELECT 
s.userid,
COUNT(s.product_id) AS total_orders,
SUM(p.price) AS total_amount_spent
FROM sale s
JOIN goldusers_signup g ON s.userid = g.userid
JOIN product p ON s.product_id = p.product_id
WHERE s.created_date < g.gold_signup_date
GROUP BY s.userid;

--9. Calculate points collected by each customer and for which product most points have been given till now?

WITH CustomerPoints AS (
SELECT 
s.userid,
s.product_id,
SUM(p.price) AS total_spent,  -- Total amount spent on the product
SUM(p.price) AS points_collected  -- Points collected by the customer (assuming 1 point per Rs spent)
FROM sale s
JOIN product p ON s.product_id = p.product_id
GROUP BY s.userid, s.product_id
),
TotalPoints AS (
SELECT 
userid,
SUM(points_collected) AS total_points
FROM CustomerPoints
GROUP BY userid
),
ProductPoints AS (
SELECT 
product_id,
SUM(points_collected) AS total_points_given
FROM CustomerPoints
GROUP BY product_id
)
SELECT 
u.userid,
tp.total_points,
p.product_name,
pp.total_points_given
FROM TotalPoints tp
JOIN users u ON tp.userid = u.userid
JOIN ProductPoints pp ON pp.product_id = (
SELECT TOP 1 product_id
FROM ProductPoints
ORDER BY total_points_given DESC
)
JOIN product p ON pp.product_id = p.product_id;


--10. In the first one year after a customer joins the gold program (including their join date) 
--irrespective of what the customer has purchased they earn 5 Zomato points for every 10 Rs spent 
--who earned more 1 or 3 and what was their points earnings in their first year?

WITH PointsInFirstYear AS (
SELECT 
 s.userid,
SUM(p.price) AS total_spent,
SUM(p.price) / 2 AS zomato_points_earned  -- Points earned based on Rs. spent
FROM sale s
JOIN goldusers_signup g ON s.userid = g.userid
JOIN product p ON s.product_id = p.product_id
WHERE s.created_date BETWEEN g.gold_signup_date AND DATEADD(YEAR, 1, g.gold_signup_date)
GROUP BY s.userid
)
SELECT 
userid,
zomato_points_earned
FROM PointsInFirstYear
WHERE userid IN (1, 3)
ORDER BY zomato_points_earned DESC;

--11. Rank all the transaction of the customers.

SELECT 
s.userid,
s.product_id,
s.created_date,
p.product_name,
ROW_NUMBER() OVER (PARTITION BY s.userid ORDER BY s.created_date) AS transaction_rank
FROM sale s
JOIN product p ON s.product_id = p.product_id
ORDER BY s.userid, transaction_rank;

