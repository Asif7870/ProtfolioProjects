create database Sales_Analysis;
select * from Sales_Analysis.dbo.Orders_Sales

alter table Sales_Analysis.dbo.Orders_Sales
drop column F1 

select * from Sales_Analysis.dbo.Orders_Sales

alter table Sales_Analysis.dbo.Orders_Sales
set column order_id int primary key

------------------------------------------------------------------------------------------------
-- Q - 1 Find top 10 highest revenue generating products ? (use of new command "top 10")

select top 10 product_id,SUM(sale_price) as Revenue from 
Sales_Analysis.dbo.Orders_Sales group by product_id
order by Revenue desc 


------------------------------------------------------------------------------------------------
-- Q - 2 Find top 5 highest selling products in each region ?  (generate rank)

with cte as (
select region, product_id,SUM(sale_price) as Revenue from 
Sales_Analysis.dbo.Orders_Sales group by region, product_id)

select * from (
select *, ROW_NUMBER () over(partition by region order by Revenue desc) as Rn from cte  ) cte_2 
where Rn<=5


---- Method 2 (using sub-querries) think about it 
select region, product_id from 
Sales_Analysis.dbo.Orders_Sales 
where product_id IN 
(select top 5 product_id, SUM(sale_price) as Revenue_2 from Sales_Analysis.dbo.Orders_Sales
group by product_id order by Revenue_2 desc )


------------------------------------------------------------------------------------------------
-- Q - 3 Find month over month comparison for 2022 and 2023 sales ex: jan 2022 vs jan 2023 ?

with COMPcte as (
select year(order_date) as Year ,month(order_date) as Month,
sum(sale_price) as sales from 
Sales_Analysis.dbo.Orders_Sales 
group by year(order_date),month(order_date) )

select  Month ,
round(sum(case when Year = 2023 then sales else 0 end ),2) as Sales_2023,
round(sum(case when Year = 2022 then sales else 0 end ) ,2) as Sales_2022 
from COMPcte
--order by Month 
group by Month  

------------------------------------------------------------------------------------------------
-- Q - 4 for each category which month had highest sales ? (use of format function else it will consider bot 22 & 23 sales)

---Method 01 using where function(this will sepearte year wise)
with cte as (
select  category, month(order_date) as Month, sum(sale_price) as sales
from Sales_Analysis.dbo.Orders_Sales
where Year(order_date) = 2023
group by month(order_date), category
---order by sales desc
)
select * from (
select *, ROW_NUMBER () over (partition by category order by sales desc) as rn from cte) as A 
where rn =1

---Method 02 using format date function
with cte as (
select  category, format(order_date,'yyyyMM') as Order_year_Month, sum(sale_price) as sales
from Sales_Analysis.dbo.Orders_Sales
group by format(order_date,'yyyyMM'), category
---order by sales desc
)
select * from (
select *, ROW_NUMBER () over (partition by category order by sales desc) as rn from cte) as A 
where rn =1

------------------------------------------------------------------------------------------------
-- Q - 5 which sub-category had highest growth by profit in 2023 as compared to 2022

with COMPcte as (
select sub_category,year(order_date) as Year,
sum(profit) as Profit from 
Sales_Analysis.dbo.Orders_Sales 
group by year(order_date),sub_category
),
cte_2 as(
select sub_category ,
round(sum(case when Year = 2023 then Profit else 0 end ),2) as Profit_2023,
round(sum(case when Year = 2022 then Profit else 0 end ) ,2) as Profit_2022 
from COMPcte
group by sub_category 
)
select top 1 *,(Profit_2022-Profit_2023) as Growth from cte_2 
order by (Profit_2022-Profit_2023) desc

