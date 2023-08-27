SELECT * FROM moviesdb.movies;

SELECT *
FROM moviesdb.movies
where imdb_rating= (SELECT MAX(imdb_rating) OVER() r 
            FROM moviesdb.movies LIMIt 1)
; -- not good with results

ALTER TABLE moviesdb.movies
MODIFY COLUMN imdb_rating varchar(5);  

ALTER TABLE moviesdb.movies
MODIFY COLUMN imdb_rating decimal(3,1);

SELECT *,
case 
	when release_year <2005 then "old"
    when release_year <2010 then "new"
    when release_year<2023 then "recent"
end k   
    FROM moviesdb.movies;

SELECT * FROM moviesdb.movies;

SELECT  DISTINCT language_id from movies;  

SELECT  DISTINCT industry, language_id from movies;   

SELECT * from movies WHERE language_id IN (SELECT  DISTINCT language_id from movies) ;
    
SELECT *, max(imdb_rating) over(partition by language_id)
from movies;

SELECT *,  ROW_NUMBER()  over(partition by language_id)
from movies;

SELECT *  FROM
			(
			SELECT *, ROW_NUMBER() over(partition by language_id) AS rownum, 
					  max(imdb_rating) over(partition by language_id)
			from movies
			) t
WHERE t.rownum = 1;
