use customer_behavior
select * from customer

--Q1. How much total money was earned from male customers and how much from female customers?

select gender, sum(purchase_amount) as revenue 
from customer
group by gender 

--Q2. Which customers used a discount but still spent more than the average purchase amount?

select customer_id, purchase_amount
from customer 
where discount_applied =  'Yes' and purchase_amount >= (select avg(purchase_amount) from customer)

--Q3. Which are the top 5 products that have the highest average customer review ratings?

select top 5 item_purchased, round(avg(review_rating),2) as 'Average Product Rating'
from customer 
group by item_purchased 
order by avg(review_rating) desc

--Q4. What is the difference in average purchase amount between Standard Shipping and Express Shipping?

SELECT shipping_type,
       CAST(AVG(CAST(purchase_amount AS decimal(10,2))) AS decimal(10,2)) as avg_purchase
FROM customer
WHERE shipping_type IN ('Standard', 'Express')
GROUP BY shipping_type;

--Q5. Do subscribers spend more money than non-subscribers? Compare their average spending and total revenue.

SELECT subscription_status,
       COUNT(customer_id) AS total_customers,
       
       -- Average spend ko 2 decimal tak fix karne ke liye
       CAST(AVG(CAST(purchase_amount AS decimal(10,2))) AS decimal(10,2)) AS avg_spend,
       
       -- Total revenue ko 2 decimal tak fix karne ke liye
       CAST(SUM(CAST(purchase_amount AS decimal(10,2))) AS decimal(10,2)) AS total_revenue

FROM customer
GROUP BY subscription_status
ORDER BY total_revenue DESC, avg_spend DESC;

--Q6. Which 5 products have the highest percentage of purchases where a discount was applied?

SELECT TOP 5 item_purchased,
       -- Pehle percentage calculate ki, phir usay decimal(10,2) mein convert kiya
       CAST(ROUND(100.0 * SUM(CASE WHEN discount_applied = 'Yes' THEN 1 ELSE 0 END) / COUNT(*), 2) AS decimal(10,2)) AS discount_rate
FROM customer
GROUP BY item_purchased
ORDER BY discount_rate DESC;

--Q7. segment customers into New, Returning, and Loyal based on their total number of previous purchased, and show the count of each segment?

with customer_type as (
select customer_id, previous_purchases,
case
     when previous_purchases = 1 then 'New'
	 when previous_purchases between 2 and 10 then 'Returning'
	 else 'loyal' 
	 end as customer_segment
from customer 
)
select customer_segment, count(*) as 'Number of Customer'
from customer_type
group by customer_segment

--Q8. What are the top 3 most purchased products in each product category?

with item_counts as(
select category,
item_purchased,
count(customer_id) as total_orders,
ROW_NUMBER() over(partition by category order by count(customer_id) desc) as item_rank
from customer
group by category, item_purchased
)
select item_rank, category, item_purchased, total_orders
from item_counts
where item_rank <=3;

--Q9. Are customers who buy repeatedly (more than 5 past purchases) more likely to subscribe?

select subscription_status,
count(customer_id) as repeat_buyers
from customer
where previous_purchases > 5
group by subscription_status

--Q10. How much revenue is contributed by each age group?

select age_group,
sum(purchase_amount) as total_revenue 
from customer 
group by age_group
order by total_revenue desc