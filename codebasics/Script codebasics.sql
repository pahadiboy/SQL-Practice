USE moviesdb;
SELECT * FROM moviesdb.movies;
SELECT * FROM movies;  -- when database is selected
SELECT * FROM movies where industry= "bollywood";
SELECT DISTINCT industry from movies;
SELECT * FROM movies where title LIKE 'THOR%';
SELECT * FROM movies where title LIKE "%America%";
SELECT * FROM movies WHERE studio='';
SELECT * FROM movies WHERE imdb_rating= null;   -- =NULL is not valid, IS NULL is valid
SELECT * FROM movies WHERE imdb_rating is null;
SELECT * FROM movies WHERE imdb_rating is not null;
SELECT * FROM movies WHERE imdb_rating>=9;
SELECT * FROM movies WHERE imdb_rating>=6 AND imdb_rating<=8;
SELECT * FROM movies WHERE imdb_rating BETWEEN 6 AND 8;
SELECT * FROM movies WHERE release_year=2022 or release_year=2019 or release_year=2018;
SELECT * FROM movies WHERE release_year IN (2022,2019,2018);
SELECT * FROM movies WHERE Studio IN ("Marvel Studios", "Zee Studios")
ORDER BY imdb_rating;  -- by default ORDER BY is in ASC order
SELECT * FROM movies WHERE Studio IN ("Marvel Studios", "Zee Studios")
ORDER BY imdb_rating DESC;  -- 9 rows returned
SELECT * FROM movies WHERE Studio IN ("Marvel Studios", "Zee Studios") ORDER BY imdb_rating DESC 
LIMIT 5;                    -- 5 rows returned 
SELECT * FROM movies WHERE Studio IN ("Marvel Studios", "Zee Studios") ORDER BY imdb_rating DESC 
LIMIT 5 OFFSET 3 ;          -- 5 rows returned   
SELECT * FROM movies WHERE Studio IN ("Marvel Studios", "Zee Studios") ORDER BY imdb_rating DESC 
LIMIT 5 OFFSET 5 ;          -- 4 rows returned 
SELECT * FROM movies WHERE Studio IN ("Marvel Studios", "Zee Studios") ORDER BY imdb_rating DESC 
LIMIT 5 OFFSET 8 ;          -- 1 row returned 






SELECT COUNT(*) FROM movies WHERE industry="bollywood";
SELECT MAX(imdb_rating) FROM movies WHERE industry="bollywood";
SELECT MIN(imdb_rating) FROM movies WHERE industry="bollywood";
SELECT AVG(imdb_rating) FROM movies WHERE studio="marvel studios";
SELECT ROUND(AVG(imdb_rating),2) as avg_rating FROM movies WHERE studio="marvel studios";
SELECT COUNT(*) FROM movies
GROUP BY industry;
SELECT industry, COUNT(*) FROM movies
GROUP BY industry;
SELECT studio, COUNT(*)  FROM movies
GROUP BY studio ORDER BY COUNT(*) DESC ;
SELECT studio, COUNT(*) as cnt  FROM movies
GROUP BY studio ORDER BY cnt DESC ;
SELECT industry,
COUNT(industry) as cnt,
ROUND(AVG(imdb_rating), 1) as avg_rating
FROM movies GROUP BY industry;

SELECT studio,
COUNT(studio),
ROUND(AVG(imdb_rating), 1) as avg_rating
FROM movies GROUP BY studio order by avg_rating DESC;
/*
There are 2 Universal Pictures in studio column and 1 missing value
'Universal Pictures'
'Universal Pictures  '
''
HOW TO CLEAN THE DATA ???
*/
SELECT studio,
COUNT(studio),
ROUND(AVG(imdb_rating), 1) as avg_rating
FROM movies WHERE studio != ''  --  !=   <>   not equal 
			  AND studio <> 'Universal Pictures  '
GROUP BY studio order by avg_rating DESC;






#print all the years where more than 2 movies were released
select release_year, count(*) as movies_count
from movies
group by release_year
order by movies_count desc;

select release_year, count(*) as movies_count
from movies
where movies_count>2    #Error Code: 1054. Unknown column 'movies_count' in 'where clause'
group by release_year
order by movies_count desc;
/*Order of Execution: FROM --> WHERE --> GROUP BY --> HAVING --> ORDER BY
( FROM --> JOIN --> WHERE --> GROUP BY --> HAVING --> SELECT --> DISTINCT --> ORDER BY )
HAVING is mostly used along with GROUP BY but can be used without GROUP BY too
The column you use in HAVING should be present in SELECT clause 
whereas WHERE can use columns that is not present in SELECT clause as well*/
select release_year, count(*) as movies_count
from movies
group by release_year
HAVING movies_count>2
order by movies_count desc;

SELECT YEAR(CURDATE());
SELECT *, YEAR(CURDATE()) FROM actors;
SELECT *, YEAR(CURDATE())-birth_year as age FROM actors;



SELECT * FROM financials;
SELECT * , revenue-budget as profit FROM financials;
-- convert USD --> 82INR and unit --> Millions

SELECT *, 
IF(currency= 'USD', revenue*82, revenue) as revenue_inr
-- IF (condition, is True then do, is False then do)
FROM financials;

select distinct unit from financials;  -- 3 different units B,M,T so standardize into Millions

#Billions -> 12 -> 12000 Mln ->12*1000 -> rev*1000
#Thousands-> 4567 -> 4.567 Million -> rev/1000
#Millions -> rev

SELECT* ,
CASE
	WHEN unit="thousands" THEN revenue/1000
	WHEN unit="billions" THEN revenue*1000
	WHEN unit="millions" THEN revenue
    #ELSE revenue
END as revenue_mln
FROM moviesdb.financials;

/* Takeaways
-You can derive new columns from the existing columns in a table
-As a data analyst, Revenue and Profit are the most common metrics that you will
 calculate in any industry
-Currency Conversion and Unit Conversion are important business use cases
 of SQL
-IF Function is often used in SQL queries
-When you have more than two conditions, you need to use CASE and END Function
 instead of IF Function
*/







SELECT * FROM financials;
SELECT * FROM movies;

SELECT movies.movie_id, title, budget, revenue, currency, unit
FROM movies
JOIN financials
ON movies.movie_id=financials.movie_id;

SELECT m.movie_id, title, budget, revenue, currency, unit
FROM movies m
JOIN financials f           #INNER JOIN
ON m.movie_id= f.movie_id;

SELECT m.movie_id, title, budget, revenue, currency, unit
FROM movies m
LEFT JOIN financials f      #LEFT OUTER JOIN
ON m.movie_id= f.movie_id;

SELECT m.movie_id, title, budget, revenue, currency, unit
FROM movies m
RIGHT JOIN financials f     #RIGHT OUTER JOIN
ON m.movie_id= f.movie_id;

SELECT m.movie_id, title, budget, revenue, currency, unit
FROM movies m LEFT JOIN financials f     ON m.movie_id= f.movie_id
UNION                      #FULL OUTER JOIN
SELECT m.movie_id, title, budget, revenue, currency, unit
FROM movies m RIGHT JOIN financials f    ON m.movie_id= f.movie_id;

#A little change in second SELECT clause
SELECT m.movie_id, title, budget, revenue, currency, unit
FROM movies m LEFT JOIN financials f     ON m.movie_id= f.movie_id
UNION                      #FULL OUTER JOIN
SELECT f.movie_id, title, budget, revenue, currency, unit  -- changed to f.movie_id to get last 3 movie_id
FROM movies m RIGHT JOIN financials f    ON m.movie_id= f.movie_id;


-- ------------USING clause because the column we are joining on has same name------------------------------

SELECT movie_id, title, budget, revenue, currency, unit
FROM movies m  
LEFT JOIN financials f     #LEFT OUTER JOIN
USING (movie_id);

SELECT movie_id, title, budget, revenue, currency, unit
FROM movies m
RIGHT JOIN financials f     #RIGHT OUTER JOIN
USING (movie_id);

