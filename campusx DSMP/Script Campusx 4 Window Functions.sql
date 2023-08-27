USE campusx;
-- -----------------Ranking
SELECT BattingTeam, batter, SUM(batsman_run) AS 'total_runs',
       DENSE_RANK () OVER(PARTITION BY BattingTeam ORDER BY SUM(batsman_run) DESC) AS 'rank within team'
FROM ipl
GROUP BY BattingTeam, batter;

SELECT * FROM (SELECT BattingTeam, batter, SUM(batsman_run) AS 'total_runs',
                      DENSE_RANK () OVER(PARTITION BY BattingTeam ORDER BY SUM(batsman_run) DESC) AS 'rank within team'
                FROM ipl
                GROUP BY BattingTeam, batter) t;

SELECT * FROM (SELECT BattingTeam, batter, SUM(batsman_run) AS 'total_runs',
				      DENSE_RANK () OVER(PARTITION BY BattingTeam ORDER BY SUM(batsman_run) DESC) AS 'rank_within_team'
				FROM ipl
				GROUP BY BattingTeam, batter) t
WHERE t.rank_within_team <6
ORDER BY t.BattingTeam, t.rank_within_team;

-- ------------------------------
-- Cumulative Sum
/*
Cumulative sum is another type of calculation that can be performed using
window functions. A cumulative sum calculates the sum of a set of values up to a
given point in time, and includes all previous values in the calculation.
*/

# How much runs did Kohli score upto his 50th, 75th, 100th match
SELECT 
       CONCAT("Match-" ,CAST(ROW_NUMBER() OVER(ORDER BY ID) AS CHAR)) AS 'match_no',
       SUM(batsman_run) AS 'runs_scored'
FROM ipl
WHERE batter = 'V Kohli'
GROUP BY ID;

SELECT 
      CONCAT("Match-" ,CAST(ROW_NUMBER() OVER(ORDER BY ID) AS CHAR)) AS 'match_no',
      SUM(batsman_run) AS 'runs_scored',
      SUM(SUM(batsman_run)) OVER(ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS career_runs
FROM ipl
WHERE batter = 'V Kohli'
GROUP BY ID


SELECT * FROM (SELECT 
				      CONCAT("Match-" ,CAST(ROW_NUMBER() OVER(ORDER BY ID) AS CHAR)) AS 'match_no',
				      SUM(batsman_run) AS 'runs_scored',
				      SUM(SUM(batsman_run)) OVER(ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS career_runs
				FROM ipl
				WHERE batter = 'V Kohli'
				GROUP BY ID) t
WHERE match_no= 'match-50' or match_no= 'match-75'


-- ----------------Cumulative Average
/*
Cumulative average is another type of average that can be calculated using
window functions. A cumulative average calculates the average of a set of values
up to a given point in time, and includes all previous values in the calculation.
*/

SELECT * FROM (SELECT 
                     CONCAT("Match-", CAST(ROW_NUMBER() OVER(ORDER BY ID) AS CHAR)) AS 'match_no',
                     SUM(batsman_run) AS 'runs_scored',
                     SUM(SUM(batsman_run)) OVER w AS 'career_runs',
                     AVG(SUM(batsman_run)) OVER w AS 'career_avg'
               FROM ipl
               WHERE batter = 'V Kohli'
               GROUP BY ID
               WINDOW w AS (ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)) t
               
               
 -- Running Average
 /*
Running average (also known as moving average) is a statistical technique that calculates
the average value of a dataset over a moving window of consecutive data points

The window size determines the number of data points used to calculate the average, and as
the window moves forward in time, the average is recalculated using the new data points
and dropping the oldest one. This means that the running average is continuously updated
and reflects the most recent trends in the data.

For example, a running average of a batsman's runs scored over a window of 10 matches
will calculate the average runs scored in the last 10 matches, then move the window one
match forward and recalculate the average for the new set of 10 matches, and so on.

Running averages are often used in finance, economics, and engineering to smooth out
noisy or volatile data series, and to identify trends or patterns that may be obscured by
random fluctuations in the data.
*/


SELECT * FROM (SELECT 
                     CONCAT("Match-", CAST(ROW_NUMBER() OVER(ORDER BY ID) AS CHAR)) AS 'match_no',
                     SUM(batsman_run) AS 'runs_scored',
                     SUM(SUM(batsman_run)) OVER w AS 'career_runs',
                     AVG(SUM(batsman_run)) OVER w AS 'career_avg',
                     AVG(SUM(batsman_run)) OVER(ROWS BETWEEN 9 PRECEDING AND CURRENT ROW) AS 'rolling_avg'
               FROM ipl
               WHERE batter = 'V Kohli'
               GROUP BY ID
               WINDOW w AS (ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)) t

-- Percent of total
/*
Percent of total refers to the percentage or proportion of a specific value in
relation to the total value. It is a commonly used metric to represent the relative
importance or contribution of a particular value within a larger group or
population.
*/
USE zomato;
SELECT * FROM orders t1
JOIN order_details t2
ON t1.order_id = t2.order_id
WHERE r_id = 1

SELECT f_id,SUM(amount) FROM orders t1
JOIN order_details t2
ON t1.order_id = t2.order_id
WHERE r_id = 1
GROUP BY f_id 

SELECT f_name,
(total_value/SUM(total_value) OVER())*100 AS 'percent_of_total'
FROM (SELECT f_id,SUM(amount) AS 'total_value' FROM orders t1
JOIN order_details t2
ON t1.order_id = t2.order_id
WHERE r_id = 1
GROUP BY f_id) t
JOIN food t3
ON t.f_id = t3.f_id
ORDER BY (total_value/SUM(total_value) OVER())*100 DESC

# ****************************************************************************************************************
# ****************************************************************************************************************

-- -------------------Percent Change
/*
Percent change is a way of expressing the difference between two
values as a percentage of the original value. It is often used to measure
how much a value has increased or decreased over a given period of
time, or to compare two different values.
*/




-- --------------------Percentiles & Quantiles
/*
A Quantile is a measure of the distribution of a dataset that divides the data into
any number of equally sized intervals. For example, a dataset could be divided into
deciles (ten equal parts), quartiles (four equal parts), percentiles (100 equal
parts), or any other number of intervals.

Each quantile represents a value below which a certain percentage of the data
falls. For example, the 25th percentile (also known as the first quartile, or Q1)
represents the value below which 25% of the data falls. The 50th percentile (also
known as the median) represents the value below which 50% of the data falls, and
so on.
*/


#Q1. Find the median marks of all the students
SELECT * FROM campusx.marks;

SELECT *,
	   PERCENTILE_DISC(0.5) WITHIN GROUP(ORDER BY marks) OVER()
FROM campusx.marks;

#Q2. Find branch wise median of student marks
SELECT *,
	   PERCENTILE_DISC(0.5) WITHIN GROUP(ORDER BY marks) OVER(PARTITION BY branch) AS 'median_marks'
FROM campusx.marks;

/*
PERCENTILE_CONT calculates the continuous percentile value, which returns the
interpolated value between adjacent data points. In other words, it estimates the
percentile value by assuming that the values between data points are distributed
uniformly. This function returns a value that may not be present in the original
dataset.

PERCENTILE_DISC, on the other hand, calculates the discrete percentile value,
which returns the value of the nearest data point. This function returns a value
that is present in the original dataset.
*/

SELECT *,
	   PERCENTILE_DISC(0.5) WITHIN GROUP(ORDER BY marks) OVER(PARTITION BY branch) AS 'median_marks',
       PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY marks) OVER(PARTITION BY branch) AS 'median_marks_cont'
FROM marks;


SELECT * FROM campusx.marks;
INSERT INTO campusx.marks (name,branch,marks)VALUES ('Abhi','EEE',1);   -- outlier

SELECT * FROM (SELECT *,  
                      PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY marks) OVER() AS 'Q1',
                      PERCENTILE_CONT(0.75) WITHIN GROUP(ORDER BY marks) OVER() AS 'Q3'
               FROM marks) t
WHERE t.marks > t.Q1 - (1.5*(t.Q3 - t.Q1)) AND
t.marks < t.Q3 + (1.5* (t.Q3 - t.Q1))
ORDER BY t.student_id;

SELECT * FROM (SELECT *,
                      PERCENTILE_CONT (0.25) WITHIN GROUP (ORDER BY marks) OVER () AS 'Q1',
					  PERCENTILE_CONT (0.75) WITHIN GROUP (ORDER BY marks) OVER () AS 'Q3'
               FROM marks) t
WHERE t.marks <= t.Q1 - (1.5* (t.Q3 - t.Q1))




-- ---------------Segmentation
/*
Segmentation using NTILE is a technique in SQL for dividing a dataset into equal-
sized groups based on some criteria or conditions, and then performing
calculations or analysis on each group separately using window functions.
For example if we have 1,2,3,4,4,5
*/

SELECT *,
NTILE (3) OVER() AS 'buckets'
FROM marks

SELECT *,
NTILE (3) OVER(ORDER BY marks) AS 'buckets'
FROM marks

SELECT *,
NTILE(3) OVER(ORDER BY marks DESC) AS 'buckets'
FROM marks
ORDER BY student_id


SELECT brand_name, model,price,
CASE
	WHEN bucket = 1 THEN 'budget'
	WHEN bucket = 2 THEN 'mid-range'
	WHEN bucket = 3 THEN 'premium'
END AS 'phone_type'
FROM (SELECT brand_name, model,price,
			NTILE(3) OVER(ORDER BY price) AS 'bucket'
	  FROM smartphones) t

-- ----------------Cumulative Distribution
/* 
The cumulative distribution function is used to
describe the probability distribution of random
variables. It can be used to describe the probability
for a discrete, continuous or mixed variable. It is
obtained by summing up the probability density
function and getting the cumulative probability for
a random variable
*/

SELECT *,
CUME_DIST() OVER(ORDER BY marks) AS 'Percentile Score'
FROM marks;


SELECT * FROM (SELECT *,
					  CUME_DIST() OVER(ORDER BY marks) AS 'Percentile_Score'
			   FROM marks) t
WHERE t.percentile_score > 0.90;


-- ----------------Partition By Multiple Columns (flights table not found)

SELECT * FROM (SELECT source, destination, airline, AVG(price) AS 'avg_fare',
					  DENSE_RANK() OVER(PARTITION BY source, destination ORDER BY AVG(price)) AS 'rank'
			   FROM campusx.flights
			   GROUP BY source, destination,airline) t
WHERE t.rank < 2