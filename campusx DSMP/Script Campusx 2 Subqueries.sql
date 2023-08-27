USE cx_live;

/* What is a Subquery?
In SQL, a subquery is a query within another query. It is a SELECT statement that is
nested inside another SELECT, INSERT, UPDATE, or DELETE statement. The
subquery is executed first, and its result is then used as a parameter or condition
for the outer query.
*/

# Find the movie with highest rating from movies table
SELECT * FROM movies
ORDER BY score DESC LIMIT 1;

SELECT * FROM movies 
WHERE score = (SELECT MAX(score) FROM movies);

-- Types of Subqueries
/*
Based on:
1. The result it Returns- Scalar Subquery(single value), 
						  Row Subquery(multiple rows, single column), 
						  Table Subquery(multiple rows, multiple columns)
2. Based on Execution- Independent Subquery
					   Correlated Subquery
*/  
                     
#Q. Where can subqueries be used?
#     INSERT, SELECT (WHERE,SELECT,FROM,HAVING), UPDATE ,DELETE                       

-- Independent Subquery - Scalar Subquery

SELECT * FROM movies;
#1. Find the movie with highest profit(vs order by) [profit= gross-budget]

SELECT *, gross-budget AS profit FROM movies ORDER BY profit DESC LIMIT 1;

SELECT * FROM movies WHERE gross-budget= (SELECT MAX(gross-budget) FROM movies);

SELECT *, gross-budget AS profit  FROM movies WHERE profit= (SELECT MAX(gross-budget) FROM movies);

-- Order of Execution:  FROM --> JOIN --> WHERE --> GROUP BY --> HAVING --> SELECT --> DISTINCT --> ORDER BY

SELECT *, gross-budget AS profit  FROM movies WHERE gross-budget = (SELECT MAX(gross-budget) FROM movies);


#2. Find how many movies have a rating > the avg of all the movie ratings(Find the count of above average movies)

SELECT COUNT(*) FROM movies WHERE score > (SELECT AVG(score) FROM movies);

#3. Find the highest rated movie of 2000

-- SELECT * FROM movies ORDER BY ((SELECT score FROM movies WHERE year=2000)) DESC   (xxxxxxxx DOES NoT WORK xxxxxxxx)


SELECT * FROM movies WHERE year=2000 and score = 
                                                  (SELECT MAX(score) from movies WHERE year=2000);

#4. Find the highest rated movie among all movies whose number of votes are > the dataset avg votes

SELECT * FROM movies WHERE score= 
                                  (SELECT MAX(score) FROM movies where votes> 
                                                                              (SELECT AVG(votes) FROM movies));


CREATE DATABASE zomato;
USE zomato;  

-- Independent Subquery - Row Subquery(One Col Multi Rows)      [using NOT IN]

#1. Find all users who never ordered
SELECT * FROM zomato.users
WHERE user_id NOT IN (SELECT DISTINCT (user_id) FROM zomato.orders);


#2. Find all the movies made by top 3 directors(in terms of total gross income)

WITH top_directors AS (SELECT director FROM cx_live.movies GROUP BY director ORDER BY SUM(gross) DESC LIMIT 3)
SELECT * FROM cx_live.movies WHERE director IN (SELECT * FROM top_directors);


#3. Find all movies of all those actors whose filmography's avg rating > 8.5(take 25000 votes as cutoff)
SELECT * FROM cx_live.movies
WHERE star IN (SELECT star FROM cx_live.movies WHERE votes > 25000 GROUP BY star HAVING AVG(score) > 8.5)
   AND votes > 25000;


-- Independent Subquery - Table Subquery(Multi-Col Multi-Row)

#1. Find the most profitable movie of each year
SELECT * FROM cx_live.movies WHERE (year, gross-budget) IN 
                                                   (SELECT year, MAX(gross - budget) FROM cx_live.movies GROUP BY year);


#2. Find the highest rated movie of each genre votes cutoff of 25000
SELECT * FROM cx_live.movies 
WHERE (genre,score) IN (
	                    SELECT genre, MAX(score) FROM cx_live.movies 
                        WHERE votes > 25000 
                        GROUP BY genre
					    )
AND votes > 25000;


#3. Find the highest grossing movies of top 5 actor/director combo in terms of total gross income
WITH top_duos AS (
	              SELECT star, director, MAX(gross) 
                  FROM cx_live.movies 
                  GROUP BY star, director 
                  ORDER BY SUM(gross) DESC 
                  LIMIT 5
                  )
SELECT * FROM cx_live.movies
WHERE (star, director,gross) IN (SELECT * FROM top_duos);

/* tried above CTE into Subquery but it do not work

SELECT * FROM cx_live.movies
WHERE (star, director,gross) IN ( 
								  SELECT star, director, MAX(gross) 
								  FROM cx_live.movies 
								  GROUP BY star, director 
								  ORDER BY SUM(gross) DESC 
								  )
*/


-- Correlated Subquery
/*
A Correlated subquery is the type of query in which the inner query depends upon the outer query for its execution. 
Specifically, the inner query uses an attribute from one of the tables in the outer query. The inner query is 
executed iteratively for each selected record of the outer query. In the case of independent subquery, the 
inner query just executes once.
Below is a correlated subquery written, to fetch the details of the employee(s) who are earning salary more than 
or same as the average salary earned by employees of the same designation.
			SELECT Id, Ename, Designation, Salary FROM Employee E1
			WHERE Salary >= (SELECT Avg(Salary) FROM Employee E2 WHERE E1.Designation = E2.Designation);
*/

SELECT * FROM cx_live.movies;

#1. Find all the movies that have a rating higher than the average rating of movies in the same genre.[Animation]
SELECT * FROM movies m1 
WHERE score > (SELECT AVG(score) FROM movies m2 WHERE m2.genre = m1.genre);


#2. Find the favorite food of each customer.
USE zomato;

WITH fav_food AS (
				  SELECT t2.user_id, name, f_name, COUNT(*) AS 'frequency' FROM users t1
				  JOIN orders t2 ON t1.user_id = t2.user_id
				  JOIN order_details t3 ON t2.order_id = t3.order_id
				  JOIN food t4 ON t3.f_id = t4.f_id
				  GROUP BY t2.user_id, t3.f_id
			      )
SELECT * FROM fav_food f1
WHERE frequency = ( SELECT MAX(frequency)
					FROM fav_food f2
					WHERE f2.user_id = f1.user_id
                    );


-- Usage with SELECT

#1. Get the percentage of votes for each movie compared to the total number of votes.
SELECT * FROM movies m1
WHERE score > (SELECT AVG(score) FROM movies m2 WHERE m2.genre = m1.genre);
SELECT name, (votes/(SELECT SUM(votes) FROM movies)) *100 FROM movies;


#2. Display all movie names ,genre, score and avg(score) of genre
SELECT name, genre, score, (SELECT AVG(score) FROM movies m2 WHERE m2.genre = m1.genre) 
FROM movies m1;

-- > Why this is inefficient?


-- Usage with FROM
#1. Display average rating of all the restaurants
USE zomato;

SELECT r_name, avg_rating
FROM (SELECT r_id, AVG(restaurant_rating) AS 'avg_rating'
        FROM orders
        GROUP BY r_id) t1 JOIN restaurants t2
		ON ti.r_id = t2.r_id;


-- Usage with HAVING
#1. Find genres having avg score > avg score of all the movies
SELECT genre, AVG(score) 
FROM movies 
GROUP BY genre 
HAVING AVG(score) > 
		            (SELECT AVG(score) FROM movies);




-- Create loyal_users empty table

CREATE TABLE zomato.loyal_users(
user_id VARCHAR(40),
name VARCHAR(40),
money INT);

SELECT * FROM zomato.loyal_users;

-- Subquery In INSERT

#1. Populate a already created loyal_customers table with records of only those customers who have ordered food more than 3 times.

INSERT INTO loyal_users
(user_id, name)

SELECT t1.user_id, name, COUNT(*)
FROM orders t1
JOIN users t2 ON t1.user_id = t2.user_id
GROUP BY user_id 
HAVING COUNT(*) > 3;

-- above code isn't working, check it by testing the below code
-- SELECT * 
-- FROM orders t1
-- INNER JOIN users t2 ON t1.user_id = t2.user_id



-- Subquery in UPDATE

#1. Populate the money col of loyal_cutomer table using the orders table.
 -- Provide a 10% app money to all customers based on their order value.

UPDATE loyal_users
SET money = (SELECT SUM(amount)*0.1
FROM orders
WHERE orders.user_id = loyal_users.user_id);

-- Subquery in DELETE

#1. Delete all the customers record who have never ordered

DELETE FROM users
WHERE user_id IN (SELECT user_id FROM users
WHERE user_id NOT IN (SELECT DISTINCT (user_id) FROM orders))
