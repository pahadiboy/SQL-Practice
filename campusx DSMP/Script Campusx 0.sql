CREATE DATABASE campusx;
USE campusx; 

CREATE TABLE users (
user_id INTEGER PRIMARY KEY AUTO_INCREMENT,
name VARCHAR(255) NOT NULL,
email VARCHAR (255) NOT NULL UNIQUE,
password VARCHAR(255) NOT NULL
);
SELECT * FROM campusx.users;

INSERT INTO campusx.users (user_id, name, email,password)
VALUES (NULL, 'nitish', 'nitish@gmail.com',1234);

INSERT INTO campusx.users
VALUES (NULL, 'ankit', 'ankit@gmail.com',12345);

INSERT INTO campusx.users(name,email,password)
VALUES ('amit', 'amit@gmail.com',123456);

INSERT INTO campusx.users(password,name,email)
VALUES (1234567,'rupesh', 'rupesh@gmail.com');

INSERT INTO users VALUES 
(NULL, 'rishabh','rishabh@gmail.com', '123'),
(NULL, 'rohan', 'rohan@gmail.com', '1234'),
(NULL, 'rahul', 'rahul@gmail.com', '12345');

INSERT INTO users (name,email,password) VALUES 
('rish','rish@gmail.com', '1'),
('ro', 'ro@gmail.com', '12'),
('rahu', 'rahu@gmail.com', '123');

SELECT * FROM campusx.users;



-- IMPORT smartphones.csv file 

SELECT * FROM campusx.smartphones;
SELECT * FROM campusx.smartphones WHERE 1;

-- select * except model from smartphones;  ??? want every column except model


SELECT model, SQRT(resolution_width*resolution_width + resolution_height*resolution_height)/screen_size FROM smartphones;
SELECT model, SQRT(resolution_width*resolution_width + resolution_height*resolution_height)/screen_size PPI FROM smartphones;

SELECT model, 'smartphone' AS type FROM smartphones;

SELECT MAX(price) FROM campusx.smartphones;
SELECT MIN(ram_capacity) FROM campusx.smartphones;
SELECT AVG(rating) FROM smartphones
WHERE brand_name= 'samsung';
SELECT DISTINCT(brand_name) FROM smartphones;
SELECT COUNT(DISTINCT(brand_name)) FROM smartphones;
SELECT STD(screen_size) FROM smartphones;
SELECT VARIANCE(screen_size) FROM smartphones;
SELECT price-100000 temp FROM smartphones;
SELECT ABS(price-100000) AS temp FROM smartphones;

SELECT model, ROUND(SQRT(resolution_width*resolution_width + resolution_height*resolution_height)/screen_size) PPI FROM smartphones;
SELECT model, ROUND(SQRT(resolution_width*resolution_width + resolution_height*resolution_height)/screen_size,2) PPI FROM smartphones;

SELECT CEIL(screen_size) FROM smartphones;
SELECT FLOOR(screen_size) FROM smartphones;







--  Session 33 SORTING -----------------------------------------------------------------------------

SELECT * FROM campusx.smartphones WHERE brand_name= 'samsung'
ORDER BY screen_size DESC  LIMIT 5;

SELECT model, num_front_cameras + num_rear_cameras AS total_cameras
FROM campusx.smartphones
ORDER BY total_cameras DESC;


SELECT model, ROUND(SQRT(resolution_width*resolution_width + resolution_height*resolution_height)/screen_size) ppi FROM smartphones
ORDER BY ppi ASC;


SELECT model, battery_capacity
FROM campusx.smartphones
ORDER BY battery_capacity DESC LIMIT 1,1;

SELECT model, battery_capacity
FROM campusx.smartphones
ORDER BY battery_capacity ASC LIMIT 1,1;






-- ---------------------------------------Grouping Data-----------------------------

-- 1.Group smartphones by brand and get the count, average price, max rating, avg screen size and avg battery capacity
SELECT brand_name, COUNT(*) AS num_phones,
ROUND(AVG(price)) AS 'avg price',
MAX(rating) AS 'max rating',
ROUND(AVG(screen_size),2) AS 'avg screen size',
ROUND(AVG(battery_capacity)) AS 'avg battery capacity'
FROM smartphones
GROUP BY brand_name
ORDER BY num_phones DESC LIMIT 15;

/* Order of Execution: FROM --> WHERE --> GROUP BY --> HAVING --> ORDER BY
  (FROM --> JOIN --> WHERE --> GROUP BY --> HAVING --> SELECT --> DISTINCT --> ORDER BY)  */

-- --> Group By Animation by Order of Execution
-- https://infytq.onwingspan.com/web/en/app/toc/lex_auth_01275806667282022456_shared/overview

/* Order of Execution:
   FROM --> JOIN --> WHERE --> GROUP BY --> HAVING --> SELECT --> DISTINCT --> ORDER BY  */
  
-- 2. Group smartphones by whether they have an NFC and get the average price and rating
SELECT * FROM campusx.smartphones;
SELECT has_nfc,
AVG(price) AS avg_price, 
AVG(rating) AS rating 
FROM smartphones
GROUP BY has_nfc;

-- 3. Group smartphones by the extended memory available and get the average price
SELECT extended_memory_available,AVG(price) AS avg_price, AVG(rating) AS rating FROM smartphones
GROUP BY extended_memory_available;

-- 4. Group smartphones by the brand and processor brand and get the count of models and the average primary camera resolution(rear)
SELECT brand_name, processor_brand,
COUNT(*) AS num_phones,
AVG(primary_camera_rear) AS 'avg camera resolution'
FROM smartphones
GROUP BY brand_name, processor_brand;

-- 5. find top 5 most costly phone brands
SELECT brand_name,
ROUND(AVG(price)) AS 'avg price'
FROM smartphones
GROUP BY brand_name
ORDER BY 'avg price' DESC LIMIT 5;

-- 6. which brand makes the smallest screen smartphones
SELECT * FROM smartphones;
SELECT brand_name,
ROUND(AVG(screen_size)) AS avg_screen_size
FROM smartphones
GROUP BY brand_name
ORDER BY avg_screen_size ASC 
-- LIMIT 1
;

-- 7. Avg price of 5g phones vs avg price of non 5g phones
SELECT * FROM smartphones;
SELECT AVG(price) AS avg_price
FROM smartphones
GROUP BY has_5g;


-- 8. Group smartphones by the brand, and find the brand with the highest number of models that have both NFC and an IR blaster
SELECT brand_name, COUNT(*) AS count FROM smartphones
WHERE has_nfc='TRUE' AND has_ir_blaster= 'true'
GROUP BY brand_name
ORDER BY count DESC 
-- LIMIT 1
;
 

-- 9. Find all samsung 5g enabled smartphones and find out the avg price for NFC and Non-NFC phones
SELECT has_nfc, AVG(price) AS avg_price FROM smartphones
WHERE brand_name= 'samsung'
GROUP BY has_nfc;

-- 10. find the phone name, price of the costliest phone
SELECT model, price FROM smartphones
ORDER BY price DESC LIMIT 1;

-- ---------------------------------Having clause-------------------------------
-- 1. find the avg rating of smartphone brands which have more than 20 phones
SELECT  brand_name,
COUNT(*) AS 'count',
AVG(rating) AS 'avg_rating'
FROM smartphones
GROUP BY brand_name
HAVING count > 20
ORDER BY avg_rating DESC;

-- 2. Find the top 3 brands with the highest avg ram that have a refresh rate of at least 90 Hz and 
   -- fast charging available and dont consider brands which have less than 10 phones
SELECT brand_name,
AVG (ram_capacity) AS 'avg_ram'
FROM smartphones
WHERE refresh_rate > 90 AND fast_charging_available = 1
GROUP BY brand_name
HAVING COUNT(*) >10
ORDER BY avg_ram DESC LIMIT 3;

-- 3. find the ava price of all the phone brands with ava rating > 70 and num phones more than 10 among all 5a enabled phones
SELECT brand_name, AVG(price) AS 'avg_price'
FROM smartphones
WHERE has_5g = 'True'
GROUP BY brand_name
HAVING AVG(rating) > 70 AND COUNT(*) > 10;


-- ----------------------------------Practice-------------------------------------------------
-- IMPORT ipl file

SELECT * FROM campusx.ipl;

-- Find the top 5 batsman in IPL


-- Find the and highest 6 hitter in IPL


-- Find Virat Kohli's performance against all IPL teams


-- Find top 10 batsman with centuries in IPL
SELECT batter, ID, SUM(batsman_run) As 'score' FROM ipl
GROUP BY batter, ID
HAVING score >= 100
ORDER BY batter DESC LIMIT 10;

-- Find the top 5 batsman with highest strike rate who have played a min of 1000 balls
SELECT batter, SUM(batsman_run), COUNT(batsman_run),
ROUND((SUM(batsman_run) /COUNT(batsman_run)) * 100,2) AS 'sr'
FROM campusx.ipl
GROUP BY batter
HAVING COUNT(batsman_run) > 1000
ORDER BY sr DESC LIMIT 5