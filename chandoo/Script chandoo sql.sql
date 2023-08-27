USE `awesome chocolates`;

-- Select everything from sales table
select * from sales;

-- Show just a few columns from sales table
select SaleDate, Amount, Customers from sales;
select Amount, Customers, GeoID from sales;

-- Adding a calculated column with SQL
Select SaleDate, Amount, Boxes, Amount / boxes  from sales;

-- Naming a field with AS in SQL
Select SaleDate, Amount, Boxes, Amount / boxes as 'Amount per box'  from sales;
Select SaleDate, Amount, Boxes, Amount / boxes 'Amount per box'  from sales;

-- Using WHERE Clause in SQL
select * from sales
where amount > 10000;

-- Showing sales data where amount is greater than 10,000 by descending order
select * from sales
where amount > 10000
order by amount desc;        -- ORDER BY is bydefault in asc

-- Showing sales data where geography is g1 by product ID &
-- descending order of amounts
select * from sales
where geoid='g1'
order by PID, Amount desc;       -- here PID is in asc order and amount in desc

-- Working with dates in SQL- amount gr than 10000 and date should be within 2022
Select * from sales
where amount > 10000 and SaleDate >= '2022-01-01';

-- Using year() function to select all data in a specific year
select SaleDate, Amount from sales
where amount > 10000 and year(SaleDate) = 2022
order by amount desc;

-- BETWEEN condition in SQL with < & > operators
select * from sales
where boxes >0 and boxes <=50;

-- Using the between operator in SQL
select * from sales
where boxes between 0 and 50;  -- 0 and 50 are inclusive in between

-- Using weekday() function in SQL
select SaleDate, Amount, Boxes, weekday(SaleDate) as 'Day of week'
from sales
where weekday(SaleDate) = 4;         -- date (0 = Monday, 1 = Tuesday,..., 6 = Sunday)
-- where 'Day of week' = 4;          won't return any value   
          

-- Working with People table
select * from people;

-- OR operator in SQL
select * from people
where team = 'Delish' or team = 'Jucies';

-- IN operator in SQL
select * from people
where team in ('Delish','Jucies');

-- LIKE operator in SQL- all the salesperson that starts with B
select * from people
where salesperson like 'B%';

-- all the salesperson with B (anywhere)
select * from people
where salesperson like '%B%';

-- Working with Sales table
select * from sales;

-- Using CASE to create branching logic in SQL
select 	SaleDate, Amount,
		case 	when amount < 1000 then 'Under 1k'
				when amount < 5000 then 'Under 5k'
                when amount < 10000 then 'Under 10k'
			else '10k or more'
		end as 'Amount Category'
from sales;


   -- -------------------------------------------- JOIN ------------------------------------------


select *  from sales;
select * from people;
select * from products;

select s.saledate, s.amount, p.salesperson, s.spid, p.spid 
from sales s
join people p on p.spid= s.spid;

select s.saledate, s.amount, pr.product
from sales s
left join products pr on pr.pid= s.pid;

select s.saledate, s.amount, p.salesperson, pr.product, p.team
from sales s
join people p on p.spid= s.spid
left join products pr on pr.pid= s.pid;

-- Conditions with Joins

select s.saledate, s.amount, p.salesperson, pr.product, p.team
from sales s
join people p on p.spid= s.spid
left join products pr on pr.pid= s.pid
where s.amount<500
and p.team= '';

select s.saledate, s.amount, p.salesperson, pr.product, p.team
from sales s
join people p on p.spid= s.spid
left join products pr on pr.pid= s.pid
where s.amount<500
and p.team is null;   -- 'NULL' is not in Team column

select s.saledate, s.amount, p.salesperson, pr.product, p.team
from sales s
join people p on p.spid= s.spid
join products pr on pr.pid= s.pid
join geo g on g.geoid = s.geoid
where s.amount<500
and p.team= ''
and g.geo in ('New Zealand', 'India')
order by saledate;

-- ------------------------------Using Group BY-----------------------------

select geoid, sum(amount), avg (amount), sum(boxes)
from sales
group by geoid;

select g.geo, sum(amount), avg (amount), sum(boxes)
from sales s
join geo g on s.geoid= s.geoid
group by g.geo;

select pr.category, p.team, sum(amount), avg (amount), sum(boxes)
from sales s
join people p on p.spid= s.spid
join products pr on pr.pid= s.pid
group by pr.category, p.team
order by pr.category, p.team;

select pr.category, p.team, sum(amount), avg (amount), sum(boxes)
from sales s
join people p on p.spid= s.spid
join products pr on pr.pid= s.pid
where p.team <> ''                   -- Not Equal to <>
group by pr.category, p.team
order by pr.category, p.team;

-- Total Amount by Top 10 products 
select pr.product, sum(s.amount) as 'Total Amount'
from sales s
join products pr on pr.pid= s.pid
group by pr.Product
order by 'Total Amount' desc;
-- LIMIT 10;


-- GROUP BY in SQL
select team, count(*) from people
group by team;



-- INTERMEDIATE PROBLEMS:

-- 1. Print details of shipments (sales) where amounts are > 2,000 and boxes are <100?

select * from sales where amount > 2000 and boxes < 100;

-- 2. How many shipments (sales) each of the sales persons had in the month of January 2022?

select p.Salesperson, count(*) as 'Shipment Count'
from sales s
join people p on s.spid = p.spid
where SaleDate between '2022-1-1' and '2022-1-31'
group by p.Salesperson;

-- 3. Which product sells more boxes? Milk Bars or Eclairs?

select pr.product, sum(boxes) as 'Total Boxes'
from sales s
join products pr on s.pid = pr.pid
where pr.Product in ('Milk Bars', 'Eclairs')
group by pr.product;

-- 4. Which product sold more boxes in the first 7 days of February 2022? Milk Bars or Eclairs?

select pr.product, sum(boxes) as 'Total Boxes'
from sales s
join products pr on s.pid = pr.pid
where pr.Product in ('Milk Bars', 'Eclairs')
and s.saledate between '2022-2-1' and '2022-2-7'
group by pr.product;

-- 5. Which shipments had under 100 customers & under 100 boxes? Did any of them occur on Wednesday?

select * from sales
where customers < 100 and boxes < 100;

select *,
case when weekday(saledate)=2 then 'Wednesday Shipment'
else ”
end as 'W Shipment'
from sales
where customers < 100 and boxes < 100;

 

-- HARD PROBLEMS:

-- What are the names of salespersons who had at least one shipment (sale) in the first 7 days of January 2022?

select distinct p.Salesperson
from sales s
join people p on p.spid = s.SPID
where s.SaleDate between '2022-01-01' and '2022-01-07';

-- Which salespersons did not make any shipments in the first 7 days of January 2022?

select p.salesperson
from people p
where p.spid not in
(select distinct s.spid from sales s where s.SaleDate between '2022-01-01' and '2022-01-07');

-- How many times we shipped more than 1,000 boxes in each month?

select year(saledate) 'Year', month(saledate) 'Month', count(*) 'Times we shipped 1k boxes'
from sales
where boxes>1000
group by year(saledate), month(saledate)
order by year(saledate), month(saledate);

-- Did we ship at least one box of ‘After Nines’ to ‘New Zealand’ on all the months?

set @product_name = 'After Nines';
set @country_name = 'New Zealand';

select year(saledate) 'Year', month(saledate) 'Month',
if(sum(boxes)>1, 'Yes','No') 'Status'
from sales s
join products pr on pr.PID = s.PID
join geo g on g.GeoID=s.GeoID
where pr.Product = @product_name and g.Geo = @country_name
group by year(saledate), month(saledate)
order by year(saledate), month(saledate);

-- India or Australia? Who buys more chocolate boxes on a monthly basis?

select year(saledate) 'Year', month(saledate) 'Month',
sum(CASE WHEN g.geo='India' = 1 THEN boxes ELSE 0 END) 'India Boxes',
sum(CASE WHEN g.geo='Australia' = 1 THEN boxes ELSE 0 END) 'Australia Boxes'
from sales s
join geo g on g.GeoID=s.GeoID
group by year(saledate), month(saledate)
order by year(saledate), month(saledate);