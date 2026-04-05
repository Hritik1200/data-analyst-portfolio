
create database project_1;

CREATE TABLE retail_sales
(
    transactions_id INT PRIMARY KEY,
    sale_date DATE,
    sale_time TIME,
    customer_id INT,
    gender VARCHAR(10),
    age INT,
    category VARCHAR(35),
    quantity INT,
    price_per_unit FLOAT,
    cogs FLOAT,
    total_sale FLOAT
);

select * from retail_sales;

select count(*) from retail_sales;
-- DATA CLEANING
select * from retail_sales
where transactions_id is null or  
sale_date is null or
sale_time is null or
customer_id is null or
gender is null or
age is null or
category is null or
quantiy is null or
price_per_unit is null or
cogs is null or
total_sale is null;

select * from retail_sales
where quantiy = 0;

SET SQL_SAFE_UPDATES = 0;

delete from retail_sales
where quantiy = 0;

ALTER TABLE retail_sales
change quantiy  quantity int ;


-- DATA EXPLORATION
-- HOW MANY SALES COUNT WE HAVE
SELECT COUNT(*) TOTAL_SALES_COUNT FROM retail_sales;

-- HOW MANY UNIQUE CUSTOMERS WE HAVE
SELECT  COUNT(distinct customer_id) UNIQUE_CUSTOMERS FROM retail_sales;

-- HOW MANY UNIQUE CATEGORY WE HAVE
SELECT DISTINCT CATEGORY FROM retail_sales;

-- which years of data
select year(sale_date) year from retail_sales
group by year(sale_date);

-- Data Analysis & Business Key Problems & Answers

-- My Analysis & Findings
-- Q.1 Write a SQL query to retrieve all columns for sales made on '2022-11-05
-- Q.2 Write a SQL query to retrieve all transactions where the category is 'Clothing' and the quantity sold is more than 10 in the month of Nov-2022
-- Q.3 Write a SQL query to calculate the total sales (total_sale) for each category.
-- Q.4 Write a SQL query to find the average age of customers who purchased items from the 'Beauty' category.
-- Q.5 Write a SQL query to find all transactions where the total_sale is greater than 1000.
-- Q.6 Write a SQL query to find the total number of transactions (transaction_id) made by each gender in each category.
-- Q.7 Write a SQL query to calculate the average sale for each month. Find out best selling month in each year
-- Q.8 Write a SQL query to find the top 5 customers based on the highest total sales
-- Q.9 Write a SQL query to find the number of unique customers who purchased items from each category.
-- Q.10 Write a SQL query to create each shift and number of orders (Example Morning <=12, Afternoon Between 12 & 17, Evening >17)



 -- Q.1 Write a SQL query to retrieve all columns for sales made on '2022-11-05'
 SELECT * FROM retail_sales
 WHERE sale_date = '2022-11-05';
 
 -- Q.2 Write a SQL query to retrieve all transactions where the category is 'Clothing' and the quantity sold is more than 4 in the month of Nov-2022
select * FROM retail_sales
WHERE CATEGORY = 'Clothing' and date_format(sale_date,'%Y-%m') = '2022-11' and quantity >=4
;

select * from retail_sales
where category = 'Clothing' and quantity >= 4 and sale_date between '2022-11-01' and '2022-11-31';

-- Q.3 Write a SQL query to calculate the total sales (total_sale) for each category.
select category,sum(total_sale) toatal_sale from retail_sales
group by category;

-- Q.4 Write a SQL query to find the average age of customers who purchased items from the 'Beauty' category.
Select round(avg(age),2) Avg_customer_age,category from retail_sales
Where category = 'Beauty' ;

-- Q.5 Write a SQL query to find all transactions where the total_sale is greater than 1000.

Select * from retail_sales
Where total_sale > 1000
Order by total_sale asc;

-- Q.6 Write a SQL query to find the total number of transactions (transaction_id) made by each gender in each category.

Select category, gender,count(transactions_id) total_transactions from retail_sales
Group by category, gender
Order by total_transactions desc;

-- Q.7 Write a SQL query to calculate the average sale for each month. Find out best selling month in each year
-- method 1 with subqueries
Select a.month,a.year,a.avg_sale
 from
(Select month(sale_date)month,year(sale_date) year,round(avg(total_sale),2) avg_sale,
row_number() over (partition by year(sale_date) order by avg(total_sale) desc) rank_no  from retail_sales
Group by month(sale_date),year(sale_date))a
Where rank_no = 1;

-- Alternative method with CTE
With cte_Avg as
(
Select round(avg(total_sale),2) avg_sale,month(sale_date)month,year(sale_date)year from retail_sales
Group by month(sale_date),year(sale_date)
)
,cte_rank as
(
Select month,year,avg_sale,row_number() over(partition by year order by avg_sale desc) rank_no from cte_Avg
)
Select month,year,avg_sale from cte_rank
Where rank_no = 1;

-- Q.8 Write a SQL query to find the top 5 customers based on the highest total sales

Select customer_id,sum(total_sale) total_sales from retail_sales
Group by customer_id
Order by total_sales desc
Limit 5;

-- Q.9 Write a SQL query to find the number of unique customers who purchased items from each category.
Select category,count(distinct customer_id) unique_customers from retail_sales
Group by category ;

-- Q.10 Write a SQL query to create each shift and number of orders (Example Morning <=12, Afternoon Between 12 & 17, Evening >17)
With cte_shift as
(
Select  * ,
case
When hour(sale_time)< 12 then 'Morning'
When hour(sale_time) between 12 and 17 then 'Afternoon'
Else 'Evening'
End as  Shift
From retail_sales
)
Select shift,count(*)total_orders,sum(total_sale)total_revenue
from cte_shift
Group by shift ;
