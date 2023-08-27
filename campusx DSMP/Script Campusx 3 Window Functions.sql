/*
-- What are Window Functions?
Window functions in SQL are a type of analytical function that perform calculations
across a set of rows that are related to the current row, called a "window". A
window function calculates a value for each row in the result set based on a subset
of the rows that are defined by a window specification.

The window specification is defined using the OVER() clause in SQL, which specifies
the partitioning and ordering of the rows that the window function will operate
on. The partitioning divides the rows into groups based on a specific column or
expression, while the ordering defines the order in which the rows are processed
within each group.
*/
USE campusx;

CREATE TABLE marks (
 student_id INTEGER PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(40),
    branch VARCHAR(40),
    marks INTEGER
);

INSERT INTO marks (name,branch,marks)VALUES 
('Nitish','EEE',82),
('Rishabh','EEE',91),
('Anukant','CSE',69),
('Rupesh','CSE',55),
('Shubham','EEE',78),
('Ved','EEE',43),
('Deepak','CSE',98),
('Arpan','CSE',95),
('Vinay','ECE',95),
('Ankit','ECE',88),
('Anand','ECE',81),
('Rohit','ECE',95),
('Prashant','MECH',75),
('Amit','MECH',69),
('Sunny','MECH',39),
('Gautam','MECH',51);

SELECT AVG(marks) FROM marks;
SELECT AVG(marks) OVER() FROM marks;
SELECT *, AVG(marks) OVER() FROM marks;
SELECT *, AVG(marks) OVER(PARTITION BY branch) FROM marks;

SELECT *,
		AVG(marks) OVER(),
		MIN(marks) OVER(),
		MAX(marks) OVER()
FROM campusx.marks
ORDER BY student_id;

SELECT *,
		AVG(marks) OVER() AS Overall_marks,
		MIN(marks) OVER(),
		MAX(marks) OVER(),
		MIN(marks) OVER(PARTITION BY branch),
		MAX(marks) OVER(PARTITION BY branch)
FROM campusx.marks
ORDER BY student_id;


-- Aggregate Function with OVER()

#1. Find all the students who have marks higher than the avg marks of their respective branch
SELECT * FROM 
              (SELECT *, AVG(marks) OVER(PARTITION BY branch) AS branch_avg FROM marks) t
WHERE t.marks > t.branch_avg;


-- ------------------RANK-----------------------
SELECT *,
	   RANK() OVER(ORDER BY marks DESC)
FROM marks;

SELECT *,
	   RANK() OVER(PARTITION BY branch ORDER BY marks DESC),
	   DENSE_RANK() OVER(PARTITION BY branch ORDER BY marks DESC)
FROM marks;

-- ----------------------------------ROW_NUMBER---------------------------------------
SELECT *,
	   ROW_NUMBER() OVER()
FROM marks;

SELECT *,
	   ROW_NUMBER() OVER(PARTITION BY branch)
FROM marks;

SELECT *,
	   CONCAT(branch,'-',ROW_NUMBER() OVER(PARTITION BY branch))
FROM marks;

SELECT *,
	   ROW_NUMBER() OVER(PARTITION BY branch),
	   CONCAT(branch,'-',ROW_NUMBER() OVER(PARTITION BY branch))
FROM marks;

#1. Find top 2 most paying customers of each month
USE zomato;
SELECT date, MONTH(date), MONTHNAME(date) FROM orders;

SELECT MONTHNAME(date), user_id, SUM(amount)
FROM orders
GROUP BY MONTHNAME(date), user_id
ORDER BY MONTHNAME(date);

SELECT MONTHNAME(date), user_id, SUM(amount),
	   RANK() OVER(PARTITION BY MONTHNAME(date) ORDER BY SUM(amount) DESC)
FROM orders
GROUP BY MONTHNAME(date),user_id
ORDER BY MONTHNAME(date); 


SELECT * FROM (SELECT MONTHNAME(date) AS 'month' ,user_id, SUM(amount) AS 'total',
					  RANK() OVER(PARTITION BY MONTHNAME(date) ORDER BY SUM(amount) DESC) AS 'month_rank'
			   FROM orders
			   GROUP BY MONTHNAME(date),user_id
			   ORDER BY MONTHNAME(date)) t
WHERE t.month_rank < 3
ORDER BY month DESC, month_rank ASC;

#2. Create roll no from branch and marks (CONCAT to form roll no)       [=============DYI=============]
SELECT *,
	   ROW_NUMBER() OVER(PARTITION BY branch),
	   CONCAT(branch,'-',ROW_NUMBER() OVER(PARTITION BY branch))
FROM marks;



-- FIRST_VALUE/LAST VALUE/NTH_VALUE

USE campusx;
SELECT * FROM marks;

SELECT *,
	   FIRST_VALUE (name) OVER(ORDER BY marks DESC)
FROM marks;

SELECT *, FIRST_VALUE (marks) OVER(ORDER BY marks DESC) FROM marks;

SELECT *,
	   LAST_VALUE (name) OVER(ORDER BY marks DESC)
FROM marks;

SELECT *,
	   LAST_VALUE (marks) OVER(ORDER BY marks DESC)
FROM marks;

SELECT *,
	   LAST_VALUE (marks) OVER(ORDER BY marks DESC
					    ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING)
FROM marks;

SELECT *,
	   LAST_VALUE(marks) OVER(PARTITION BY branch
						ORDER BY marks DESC
					    ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING)
FROM marks;

SELECT *,
FIRST_VALUE (name) OVER(PARTITION BY branch
						ORDER BY marks DESC
					    ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING)
FROM marks;

SELECT *,
NTH_VALUE(name,2) OVER(PARTITION BY branch
						ORDER BY marks DESC
					    ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING)
FROM marks;

SELECT *,
NTH_VALUE(name,5) OVER(PARTITION BY branch     -- ONLY 4 STUDENT IN EACH BRANCH
						ORDER BY marks DESC
					    ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING)
FROM marks;

/*
Frames
A frame in a window function is a subset of rows within the partition that
determines the scope of the window function calculation. The frame is defined
using a combination of two clauses in the window function: ROWS and BETWEEN.

The ROWS clause specifies how many rows should be included in the frame
relative to the current row. For example, ROWS 3 PRECEDING means that the
frame includes the current row and the three rows that precede it in the partition.

The BETWEEN clause specifies the boundaries of the frame.

Examples
• ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW:
  means that the frame includes all rows from the beginning of the partition up to and including the current row.
• ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING: 
  the frame includes the current row and the row immediately before and after it.
• ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING: 
  theframe includes all rows in the partition.
• ROWS BETWEEN 3 PRECEDING AND 2 FOLLOWING: 
  the frame includes the current row and the three rows before it and the two rows after it.
*/


#1. Find the branch toppers
SELECT name, branch, marks FROM (SELECT *,
										FIRST_VALUE(name) OVER(PARTITION BY branch ORDER BY marks DESC) AS 'topper_name',
										FIRST_VALUE(marks) OVER(PARTITION BY branch ORDER BY marks DESC) AS 'topper_marks'
								 FROM marks) t
WHERE t.name = t.topper_name AND t.marks = t.topper_marks;

SELECT name, branch, marks FROM (SELECT *,
										LAST_VALUE(name) OVER(PARTITION BY branch ORDER BY marks DESC
										ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS 'topper_name',
										LAST_VALUE(marks) OVER(PARTITION BY branch ORDER BY marks DESC
										ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS 'topper_marks'
								 FROM marks) t
WHERE t.name = t.topper_name AND t.marks = t.topper_marks;



SELECT name, branch, marks FROM (SELECT *,
										LAST_VALUE(name) OVER W AS 'topper_name',
                                        LAST_VALUE(marks) OVER W AS 'topper_marks'
                                  FROM marks
                                  WINDOW W AS (PARTITION BY branch ORDER BY marks DESC
                                               ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING)) t
WHERE t.name = t.topper_name AND t.marks = t.topper_marks


#2. FRAME Clause

#3. Find the last guy of each branch

#4. Alternate way of writing Window functions

#5. Find the 2nd last guy of each branch, 5th topper of each branch



-- LEAD & LAG
USE campusx;

SELECT *,
		LAG(marks) OVER(ORDER BY student_id),
		LEAD(marks) OVER(ORDER BY student_id)
FROM marks;

SELECT *,
		LAG(marks) OVER(PARTITION BY branch ORDER BY student_id),
		LEAD(marks) OVER(PARTITION BY branch ORDER BY student_id)
FROM marks;


#1. Find the MoM revenue growth of Zomato            [==========WRONG ANS==========]
USE zomato;

SELECT MONTHNAME(date), SUM(amount),
	   ((SUM(amount) - LAG(SUM(amount)) OVER(ORDER BY MONTHNAME(date))) /LAG(SUM(amount)) OVER(ORDER BY MONTHNAME(date)))*100
FROM orders
GROUP BY MONTHNAME(date)
ORDER BY MONTHNAME(date) ASC
