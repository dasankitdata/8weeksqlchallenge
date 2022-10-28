-- 1. What is the total amount each customer spent at the restaurant?

-- SELECT DISTINCT customer_id, product_id, SUM(m.price) AS AMOUNT_SPENT
-- FROM sales
-- JOIN menu AS m USING(product_id)
-- GROUP BY customer_id
-- ORDER BY customer_id;

-- 2. How many days has each customer visited the restaurant?
-- SELECT DISTINCT customer_id, COUNT( DISTINCT order_date) AS DAYS_ORDERED
-- FROM sales
-- GROUP BY customer_id
-- ORDER BY customer_id;

-- 3. What was the first item from the menu purchased by each customer?

-- solution 1 using window functions
-- SELECT
-- 	distinct customer_id,
--     first_value(product_id) OVER (
-- 		partition by customer_id
--         order by order_date 
--         RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
--         ) AS first_order,
-- 	first_value(order_date) OVER (
-- 		partition by customer_id
--         order by order_date 
--         RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
--         ) AS first_order_date
-- FROM
--     sales;
-- The problem with the above solution is that only the first product is shown of the first order date.
-- Where as if there are 2 orders on the first day we need to get both the product ids.


-- Solution number 2
-- CREATE VIEW when_bought AS
-- SELECT
-- 	customer_id,
--     order_date,
--     product_id,
--     DENSE_RANK() OVER(
-- 		PARTITION BY customer_id
--         ORDER BY order_date
--         RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
-- 	) AS Rank_of_purchase
-- FROM
-- 	sales;

-- -- Using the view
-- SELECT * from when_bought where Rank_of_purchase = 1;


-- Solution number 3
-- SELECT 
--     customer_id, order_date, product_id
-- FROM
--     sales
-- WHERE
--     order_date = (SELECT 
--             MIN(order_date)
--         FROM
--             sales)
-- ORDER BY customer_id;

-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
-- select 
-- 	distinct product_id,
--     m.product_name,
--     count(product_id) over(partition by product_id) as no_of_orders 
-- from 
-- 	sales
-- join menu as m using (product_id)
-- order by 
-- 	no_of_orders desc 
-- limit 1;


-- 5. Which item was the most popular for each customer?
-- create view orders as
-- select 
-- 	customer_id,
-- 	product_id,
--     count(product_id) as no_of_orders,
--     dense_rank() over(partition by customer_id 
--     order by count(customer_id) desc) as order_rank
-- from sales
-- group by customer_id, product_id;

-- -- create view order_ranks as
-- select 
-- 	customer_id, 
-- 	product_id,
--     no_of_orders
-- from
-- 	orders
-- where
-- 	order_rank =1;

-- 6. Which item was purchased first by the customer after they became a member?
-- create view member_orders as
-- select 
-- 	s.customer_id, 
--     s.order_date, 
--     s.product_id, 
--     m.join_date,
--     dense_rank() over(partition by s.customer_id order by order_date) as rank_order
-- from 
-- 	members as m
-- join 
-- 	sales as s using(customer_id)
-- where 
-- 	s.order_date >= m.join_date
-- order by 
-- 	s.customer_id, 
--     s.order_date;
--     
-- select * from member_orders where rank_order = 1;



-- 7. Which item was purchased just before the customer became a member?
-- create view per_mem_orders as
-- select 
-- 	s.customer_id, 
--     s.order_date, 
--     s.product_id, 
--     m.join_date,
--     dense_rank() over(partition by s.customer_id order by order_date desc) as rank_order
-- from 
-- 	members as m
-- join 
-- 	sales as s using(customer_id)
-- where 
-- 	s.order_date < m.join_date
-- order by 
-- 	s.customer_id, 
--     s.order_date;

-- select * from per_mem_orders where rank_order = 1;


-- 8. What is the total items and amount spent for each member before they became a member?
-- select 
-- 	distinct s.customer_id, 
--     count(s.customer_id) over(partition by s.customer_id) as items_ordered,
--     sum(mn.price) over(partition by s.customer_id) as amount_ordered
-- from sales as s 
-- join members as m using(customer_id)
-- join menu as mn using(product_id)
-- where s.order_date < m.join_date
-- order by s.customer_id;

-- select s.customer_id,
-- 	count(s.product_id) as total_items,
--     sum(mn.price) as amount_spent
-- from sales as s
-- join members as m using(customer_id)
-- join menu as mn using(product_id)
-- where s.order_date < m.join_date
-- group by s.customer_id
-- order by s.customer_id;


-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
-- create view point_table as
-- select 
--     *,    
--     case when product_name = "sushi" then price*20
--     else price*10
--     end as points
-- from 
-- 	menu;

-- select 
-- 	s.customer_id,
--     sum(pt.points) as total_points 
-- from sales as s 
-- join point_table as pt using(product_id)
-- group by s.customer_id;


-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - 
-- how many points do customer A and B have at the end of January?
-- create view qten as
-- select
-- s.customer_id as customer,s.product_id,me.product_name as prod_name,me.price,
-- case
-- when me.product_name = 'sushi' then price*20
-- when s.order_date < m.join_date then price*10
-- when s.order_date <= date_add(m.join_date, interval 6 day) then price*20
-- else price*10
-- end as points,
-- s.order_date,m.join_date, date_add(m.join_date, interval 6 day) as first_week
-- from sales as s
-- join members as m using(customer_id)
-- join menu as me using(product_id)
-- where s.order_date < '2021-02-01' 
-- order by s.customer_id, s.order_date;

-- select customer, sum(points) from qten group by customer order by customer;