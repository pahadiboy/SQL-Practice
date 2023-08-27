CREATE DATABASE cx_flipkart;
CREATE DATABASE cx_live;

USE cx_live;

# Order of Execution
# FROM --> JOIN --> WHERE --> GROUP BY --> HAVING --> SELECT -->DISTINCT --> ORDER BY

SELECT * FROM cx_live.users;  -- 6 rows
SELECT * FROM cx_live.groups; -- 4 rows

-- ----------------------------------------CROSS JOIN-------------------------------------------------

SELECT * FROM cx_live.users t1
CROSS JOIN cx_live.groups t2;  -- 6*4=24 rows


SELECT * FROM cx_live.membership t1
INNER JOIN cx_live.users t2
ON t1.user_id = t2.user_id;


SELECT * FROM cx_live.membership t1
LEFT JOIN cx_live.users t2
ON t1.user_id = t2.user_id;



SELECT * FROM cx_live.membership t1
RIGHT JOIN cx_live.users t2
ON t1.user_id = t2.user_id;

# No FULL OUTER JOIN keyword in MYSQL

/*
SQL Set Operations

UNION: The UNION operator is used to combine the results of two or more SELECT statements into 
        a single result set. The UNION operator removes duplicate rows between the various SELECT statements.
UNION ALL: The UNION ALl operator is similar to the UNION operator, but it does
			not remove duplicate rows from the result set.
INTERSECT: The INTERSECT operator returns only the rows that appear in both
		   result sets of two SELECT statements.
EXCEPT: The EXCEPT or MINUS operator returns only the distinct rows that appear
	    in the first result set but not in the second result set of two SELECT statements.
*/


SELECT * FROM cx_live.person1
UNION
SELECT * FROM cx_live.person2;

SELECT * FROM cx_live.person1
UNION ALL
SELECT * FROM cx_live.person2;

SELECT * FROM cx_live.person1
INTERSECT
SELECT * FROM cx_live.person2;

SELECT * FROM cx_live.person1
EXCEPT
SELECT * FROM cx_live.person2;

SELECT * FROM cx_live.person1
UNION
SELECT * FROM cx_live.person2;


-- ------------------------------------FULL OUTER JOIN method in MYSQL----------------------------------------

SELECT * FROM cx_live.membership t1
LEFT JOIN cx_live.users t2
ON t1.user_id = t2.user_id
UNION
SELECT * FROM cx_live.membership t1
RIGHT JOIN cx_live.users t2
ON t1.user_id = t2.user_id;

SELECT * FROM cx_live.membership t1
LEFT JOIN cx_live.users t2
ON t1.user_id = t2.user_id
UNION ALL                               -- UNION ALL adds duplicate values
SELECT * FROM cx_live.membership t1
RIGHT JOIN cx_live.users t2
ON t1.user_id = t2.user_id;

-- -----------------------------------------------SELF JOIN--------------------------------

SELECT * FROM cx_live.users t1
JOIN cx_live.users t2
ON t1.emergency_contact = t2.user_id;

# Order of Execution
# FROM --> JOIN --> WHERE --> GROUP BY --> HAVING --> SELECT -->DISTINCT --> ORDER BY

SELECT * FROM cx_live.students t1
JOIN cx_live.class t2
ON t1.class_id = t2.class_id AND t1.enrollment_year = t2.class_year;

SELECT * FROM cx_live.students t1
LEFT JOIN cx_live.class t2
ON t1.class_id = t2.class_id AND t1.enrollment_year = t2.class_year;

-- Find order name and corresponding category name
SELECT * FROM cx_flipkart.users;
SELECT * FROM cx_flipkart.orders;
SELECT * FROM cx_flipkart.order_details;
SELECT * FROM cx_flipkart.category;

SELECT * FROM cx_flipkart.order_details t1
JOIN cx_flipkart.orders t2
ON t1.order_id = t2.order_id
JOIN cx_flipkart.users t3
ON t2.user_id = t3.user_id;

-- Find order_id, name and city by joining users and orders
SELECT t1.order_id, t2.name, t2.city
FROM cx_flipkart.orders t1
JOIN cx_flipkart.users t2
ON t1.user_id = t2.user_id;

-- Find order_id, product category by joining order_details and category table
SELECT t1.order_id, t2.category
FROM cx_flipkart.order_details t1
JOIN cx_flipkart.category t2
ON t1.category_id = t2.category_id;

-- Find all the orders placed in pune
SELECT * FROM cx_flipkart.orders t1
JOIN cx_flipkart.users t2
ON t1.user_id = t2.user_id
WHERE t2.city = 'Pune' 
-- AND t2.name = 'Sarita'
;

-- Find all orders under Chairs category  (????????????/////////////////////////////////////////???????)
SELECT * FROM cx_flipkart.order_details t1
JOIN cx_flipkart.category t2
ON t1.category_id = t2.category_id
WHERE t2.category= 'chairs';



#1. Find all profitable orders
SELECT t1.order_id, SUM(t2.profit) FROM cx_flipkart.orders t1
JOIN cx_flipkart.order_details t2
ON t1.order_id = t2.order_id
GROUP BY t1.order_id
HAVING SUM(t2.profit) > 0;

#2. Find the customer who has placed max number of orders (WRONG ANSWER?????????///////////////////////////????????)

SELECT name, COUNT(*) AS 'num_orders' FROM cx_flipkart.orders t1
JOIN cx_flipkart.users t2
ON t1.user_id = t2.user_id
GROUP BY t2.name
ORDER BY 'num_orders' DESC LIMIT 1;

#3. Which is the most profitable category
SELECT t2.category, SUM(profit) FROM cx_flipkart.order_details t1
JOIN cx_flipkart.category t2
ON t1.category_id = t2.category_id
GROUP BY t2.category
ORDER BY SUM(profit) DESC LIMIT 1;

#4. Which is the most profitable state
SELECT state,SUM(profit) FROM cx_flipkart.orders t1
JOIN cx_flipkart.order_details t2
ON t1.order_id = t2.order_id
JOIN cx_flipkart.users t3
ON t1.user_id = t3.user_id
GROUP BY state
ORDER BY SUM(profit) DESC LIMIT 1;

#5. Find all categories with profit higher than 3000
SELECT t2.category, SUM(profit) FROM cx_flipkart.order_details t1
JOIN cx_flipkart.category t2
ON t1.category_id = t2.category_id
GROUP BY t2.category
HAVING SUM(profit) > 3000
