#----------------------------------Texture_Sales--------------------------------------------#
create database casestudy2;


use casestudy2;



select * from product_details limit 5;
select * from product_hierarchy limit 5;
select * from product_prices limit 5;
select * from sales limit 5;




## 1. What was the total quantity sold for all products? ##
select s.prod_id, Pd.product_name, sum(s.qty) as 'total_qty_sold'
from product_details Pd
inner join sales s
on Pd.product_id = s.prod_id
group by s.prod_id, Pd.product_name
order by total_qty_sold desc;




## 2. What is the total generated revenue for all products before discounts? ##
select s.prod_id, Pd.product_name, sum(s.qty * s.price) as 'no_dis_revenue'
from product_details Pd
inner join sales s
on Pd.product_id = s.prod_id
group by s.prod_id, Pd.product_name
order by no_dis_revenue desc;




## 3. What was the total discount amount for all products? ##
select s.prod_id, Pd.product_name, sum(s.price * s.qty * s.discount)/100 as 'total_discount'
from product_details Pd
inner join sales s
on Pd.product_id = s.prod_id
group by s.prod_id, Pd.product_name
order by total_discount desc;




## 4. How many unique transactions were there? ##
select s.prod_id, Pd.product_name, count(distinct txn_id) as 'unqiue_txn'
from product_details Pd
inner join sales s
on Pd.product_id = s.prod_id
group by s.prod_id, Pd.product_name;




## 5. What are the average unique products purchased in each transaction? ##
with txn_cte as 
(
select txn_id, count(distinct prod_id) as 'product_count'
from sales 
group by txn_id
)
select txn_id, round(avg(product_count)) as 'avg_unique_prod'
from txn_cte
group by txn_id;





## 6. What is the average discount value per transaction? ##
with txn_cte_discount as 
(
select txn_id, sum(price*qty*discount)/100 as 'total_discount'
from sales 
group by txn_id
)
select txn_id, round(avg(total_discount)) as 'avg_discount'
from txn_cte_discount
group by txn_id;




## 7. What is the average revenue for member transactions and non-member transactions? ##
with cte_member_revenue as
(
select member, txn_id, sum(price * qty) as 'revenue'
from sales
group by member, txn_id
)
select member, round(avg(revenue),2) as 'avg_revenue'
from cte_member_revenue
group by member;




## 8. What are the top 3 products by total revenue before discount? ##
select s.prod_id, Pd.product_name, sum(s.price * s.qty) as 'revenue'
from sales s
inner join product_details Pd
on Pd.product_id = s.prod_id
group by s.prod_id, Pd.product_name
order by revenue desc
limit 3 ;




## 9. What are the total quantity, revenue and discount for each segment? ##
select Pd.segment_id, Pd.segment_name, sum(s.qty) as 'total_qty', sum(s.price * s.qty) as 'total_revenue', sum(s.price * s.qty * s.discount)/100 as 'total_discount'
from sales s
inner join product_details Pd
on Pd.product_id = s.prod_id
group by Pd.segment_id, Pd.segment_name;



## 10. What is the top selling product for each segment? ##
select Pd.segment_id, Pd.segment_name, Pd.product_id, Pd.product_name, sum(s.qty) as 'prod_qty',
dense_rank() over(partition by Pd.segment_name  order by sum(s.qty) desc) as 'rank'
from product_details Pd
inner join sales s
on Pd.product_id = s.prod_id
group by Pd.segment_id, Pd.segment_name, Pd.product_id, Pd.product_name;




## 11. What are the total quantity, revenue and discount for each category? ##
select Pd.category_id, Pd.category_name, sum(s.qty) as 'total_qty', sum(s.qty * s.price) as 'total_revenue', sum(s.qty * s.price * s.discount)/100 as 'total_discount'
from sales s
inner join product_details Pd
on s.prod_id = Pd.product_id
group by Pd.category_id, Pd.category_name;




## 12. What is the top selling product for each category? ##
select Pd.category_id, Pd.category_name, Pd.product_id, Pd.product_name, sum(s.qty) as 'prod_qty',
dense_rank() over(partition by Pd.category_name  order by sum(s.qty) desc) as 'rank'
from product_details Pd
inner join sales s
on Pd.product_id = s.prod_id
group by Pd.category_id, Pd.category_name, Pd.product_id, Pd.product_name;