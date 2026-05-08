select * from coffee_shop_sales.`coffee shop sales`;
describe coffee_shop_sales.`coffee shop sales`;
####convert date(transaction_date)column to proper date format


set SQL_SAFE_UPDATES = 0;
###change the date format to a wrong format d/d/d before giving it the right format
update coffee_shop_sales.`coffee shop sales` set transaction_date = STR_TO_DATE(transaction_date, '%d-%m-%y');
 
 set SQL_SAFE_UPDATES = 1;
alter table coffee_shop_sales.`coffee shop sales` modify column transaction_time time;
alter table coffee_shop_sales.`coffee shop sales` modify column transaction_date Date;

describe coffee_shop;

### To clean our transaction_id column
alter table coffee_shop_sales.`coffee shop sales` change column ï»¿transaction_id transaction_id int;

##Total Sales 
select concat(round(sum(unit_price*transaction_qty)/1000,1),"k")
 as total_Sales from coffee_shop;

select concat(round(sum(unit_price*transaction_qty)/1000,1),"k")
 as total_Sales from coffee_shop
where month(transaction_date )= 5 ### May;


###Total Sales KPI- MOM difference and MOM Growth

Select
MONTH(transaction_date) as Month,sum(unit_price*transaction_qty) as total_ sales, sum(unit_price*transaction_qty)-
lag(sum(unit_price*transaction_qty),1)over(order by month(transaction_date)))/lag(sum(unit_price*transaction_qty),1)
over(order by month(transaction_date))*100 as mom_increase_ percentage from coffee_shop_sales.`coffee shop sales` WHERE month(transaction_date) IN (4,5)group by month(transaction_date) 
order by month(transaction_date);


select month,total_sales,total_sales-lag(total_sales,1)
 over(order by month)/lag(total_sales,1) over(order by month)*100 as 
 mom_increase_percentage 
 from(select month(transaction_date)as month,sum(unit_price*transaction_qty) 
 as total_sales from coffee_shop group by month(transaction_date)) as subquery 
 order by month;
 
 
select distinct count(transaction_id) as Total_order from  coffee_shop where month(transaction_date )= 5 ;

select month,total_order,total_order -lag(total_order,1)
 over(order by month)/lag(total_order,1) over(order by month)*100 as 
 mom_increase_percentage 
 from(select month(transaction_date)as month,sum(transaction_qty) 
 as total_order from coffee_shop group by month(transaction_date)) as subquery 
 order by month;
 
 ###total Quantity
 select distinct count(transaction_qty) as Total_Qty from  coffee_shop where month(transaction_date )= 5 ;
 
 
 
 
 
 ####calendar table_ daily sales,quantity and total-order
 select concat(round(sum(unit_price*transaction_qty)/1000,1),"k") as  total_sales,
  concat(round(sum(transaction_qty)/1000,1),"k") as quantity_sold,
 concat(round(count(transaction_id)/1000,1),"k") as total_order from coffee_shop
 where transaction_date = "2023-05-18";
 
 ###sales trends over period
 select avg(total_sales) as avg_sales
 from(select sum(unit_price*transaction_qty) as total_sales
 from coffee_shop_sales.`coffee shop sales`group by transaction_date) as subquery;
 
 ###Daily Sales
 select day(transaction_date) as Day_of_month, concat(round(sum(unit_price*transaction_qty)/1000,1),"k")
 as total_sales  from coffee_shop
 group by day(transaction_date) order by day(transaction_date);
 
 ###comparing daily sales and average sales,if daily sales is >average sales its above average,if its <,its below average
 ###case statement
 select Day_of_month,case when total_sales>avg_sales then "above average"
 when total_sales<avg_sales then "below average" else "average" end as sales_status,
 total_sales from (select day(transaction_date) as Day_of_month,
 concat(round(sum(unit_price*transaction_qty)/1000,1),"k")
  as total_sales,
 avg(sum(unit_price*transaction_qty)) over () as avg_sales from coffee_shop group by day(transaction_date))
 as subquery order by Day_of_month;
 
 ##sales by weekdays/weekends
 select case when dayofweek(transaction_date) in(1,7) then "weekends" else "weekdays" end as Day_type,
 concat(round(sum(unit_price*transaction_qty)/1000,1),"k")  as total_sales from coffee_shop group by  case when
 dayofweek(transaction_date) in(1,7) then "weekends" else "weekdays" end;
 
 ###sales analysis by store location
 select store_location,concat(round(sum(unit_price*transaction_qty)/1000,1),"k") as total_sales
 from coffee_shop group by store_location order by concat(round(sum(unit_price*transaction_qty)/1000,1),"k") desc;
 
 ###sales by product category
 select product_category,concat(round(sum(unit_price*transaction_qty)/1000,1),"k") 
 as total_sales from coffee_shop group by product_category order by concat(round(sum(unit_price*transaction_qty)/1000,1),"k") desc;
 
 ###Top 10 products
 select product_type,concat(round(sum(unit_price*transaction_qty)/1000,1),"k")
 as total_sales from coffee_shop group by product_type 
 order by concat(round(sum(unit_price*transaction_qty)/1000,1),"k") desc limit 10;
 
 ###Sales by day and hour
 select concat(round(sum(unit_price*transaction_qty)/1000,1),"k") as total_sales, 
 count(*) as Total_order,sum(transaction_qty) as Total_Qty from coffee_shop where dayofweek(transaction_date) = 3
 and hour(transaction_time) = 8 and month(transaction_date) = 5;
 
 ###Sales from monday to sunday
 select case when dayofweek(transaction_date) =2 then "monday"
 when dayofweek(transaction_date)  = 3 then "tuesday" 
  when dayofweek(transaction_date)  = 4 then "wednesday" 
   when dayofweek(transaction_date)  = 5 then "thursday" 
    when dayofweek(transaction_date)  = 6 then "friday" 
     when dayofweek(transaction_date) = 7 then "saturday" else "sunday" end Day_of_the_week, 
     concat(round(sum(unit_price*transaction_qty)/1000,1),"k")  as total_sales from coffee_shop where month(transaction_date) = 5
     group by case when dayofweek(transaction_date) =2 then "monday"
 when dayofweek(transaction_date)  = 3 then "tuesday" 
  when dayofweek(transaction_date)  = 4 then "wednesday" 
   when dayofweek(transaction_date)  = 5 then "thursday" 
    when dayofweek(transaction_date)  = 6 then "friday" 
     when dayofweek(transaction_date) = 7 then "saturday" else "sunday" end;
     
     ###sales for all hours for the month of may
     select hour(transaction_time),concat(round(sum(unit_price*transaction_qty)/1000,1),"k")
     as total_sales from coffee_shop group by(transaction_time) order by concat(round(sum(unit_price*transaction_qty)/1000,1),"k");
     
     
     
     

 
 