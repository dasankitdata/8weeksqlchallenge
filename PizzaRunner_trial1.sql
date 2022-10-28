/*
the above steps are used for cleaning the messy data and messy data types
to access the cleaned tables use the views creted.
rest of the tables are clean and can be taken from the original schema
*/  

-- A.1. How many pizzas were ordered?
-- SELECT COUNT(order_id) as no_pizza_ordered from c_customer_orders;

-- A.2. How many unique customer orders were made?
-- SELECT COUNT(DISTINCT order_id) as unique_orders from c_customer_orders;
-- SELECT DISTINCT customer_id from c_customer_orders;

-- A.3. How many successful orders were delivered by each runner?
-- SELECT 
-- 	runner_id,
--     count(runner_id)
-- FROM
-- 	c_runner_orders
-- WHERE
-- 	c_cancellation IS NULL
-- GROUP BY
-- 	runner_id
-- ORDER BY
-- 	runner_id;

-- A.4. How many of each type of pizza was delivered?
-- SELECT
-- 	c.pizza_id,
--     p.pizza_name,
--     count(c.pizza_id) AS no_of_pizza_ordered
-- FROM
-- 	c_customer_orders as c
-- 	JOIN 
-- 		c_runner_orders as r USING(order_id)
-- 	JOIN
-- 		pizza_names as p USING(pizza_id)
-- WHERE
-- 	r.c_cancellation IS NULL
-- GROUP BY
-- 	c.pizza_id;

-- A.5. How many Vegetarian and Meatlovers were ordered by each customer?
-- SELECT
-- 	customer_id,
--     pizza_id,
--     COUNT(pizza_id) as no_of_pizza
-- FROM
-- 	c_customer_orders
-- GROUP BY
-- 	customer_id,
--     pizza_id
-- ORDER BY
-- 	customer_id;

-- A.6. What was the maximum number of pizzas delivered in a single order?
-- SELECT 
--     c.order_id, COUNT(c.order_id) AS max_pizza_order
-- FROM
--     c_customer_orders AS c
--         JOIN
--     c_runner_orders AS r USING (order_id)
-- WHERE
--     r.c_cancellation IS NULL
-- GROUP BY c.order_id
-- ORDER BY max_pizza_order DESC
-- LIMIT 1;

-- A.7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
-- select * from c_customer_orders as c join c_runner_orders as r using(order_id);

-- select 
-- c.customer_id,
-- sum(
-- 	case
-- 		when c.c_exclusions is null and c.c_extras is null then 1
--         else 0
-- 	end
--     ) as no_change_orders,
-- sum(
-- 	case
-- 		when c.c_exclusions is not null or c.c_extras is not null then 1
--         else 0
-- 	end
--     ) as change_orders
-- from c_customer_orders as c
-- join c_runner_orders as r using(order_id)
-- where r.c_cancellation is null
-- group by c.customer_id;

-- A.8. How many pizzas were delivered that had both exclusions and extras?

-- select
-- c.customer_id,
-- sum(
-- 	case when c.c_exclusions is not null and c.c_extras is not null then 1
--     else 0
-- 	end
-- ) as OrdersExclusionExtras
-- from c_customer_orders as c join c_runner_orders as r using(order_id)
-- where r.c_cancellation is null
-- group by c.customer_id;

-- A.9. What was the total volume of pizzas ordered for each hour of the day?
-- try to extract the date and hour from the timestamp into 2 seperate coulmns along with order id.

-- select date(order_time), hour(order_time), count(order_id) from c_customer_orders group by date(order_time), hour(order_time);

-- SELECT 
-- 	hour(order_time) as HourOfDay,
-- 	count(order_id) as NoOrdered
-- FROM
-- 	c_customer_orders
-- GROUP BY
-- 	HourOfDay
-- ORDER BY
-- 	1;

-- A.10. What was the volume of orders for each day of the week?

-- select 
-- dayname(order_time) WeekOfDay, 
-- count(order_id) NoOrdered 
-- from c_customer_orders 
-- group by WeekOfDay 
-- order by weekday(order_time);


-- B.1. How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)

-- select 
-- week(registration_date, 1) as week_number,
-- count(runner_id) as runner_signed
-- from runners
-- group by week_number;

-- B.2. What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?
create view otime_ptime as
select
c.order_id as oid,
r.runner_id as rid,
c.order_time as otime,
r.c_pickup_time as ptime,
timestampdiff(minute, c.order_time, r.c_pickup_time) as arrivetime_min
from c_runner_orders as r
join c_customer_orders as c using(order_id)
where r.c_cancellation is null
group by c.order_id;

-- select rid, arrivetime_min from otime_ptime order by 1;
-- select rid, avg(arrivetime_min) from otime_ptime group by 1 order by 1;

-- B.3. Is there any relationship between the number of pizzas and how long the order takes to prepare?
create view pizzaTime as
select
c.order_id,
count(c.order_id) noOfPizza,
o.arrivetime_min as timetaken
from c_customer_orders as c
join otime_ptime as o
on c.order_id = o.oid
group by c.order_id
order by noOfPizza desc;

-- select noOfPizza, avg(timetaken) as avgtime from pizzatime group by noOfPizza order by avgtime desc;

-- B.4. What was the average distance travelled for each customer?
-- select c.customer_id,
-- round(avg(r.c_distance_km),2) as avgDist
-- from c_runner_orders as r join c_customer_orders as c on r.order_id = c.order_id
-- where r.c_cancellation is null
-- group by c.customer_id;

-- B.5. What was the difference between the longest and shortest delivery times for all orders?
/* the duration column in the runner_orders table give the time taken to deliver the order
thus the max and min of the same coulmn would give the required answer */
-- select (max(c_duration_min)-min(c_duration_min)) as diff_of_maxmin from c_runner_orders where c_cancellation is null;

-- B.6. What was the average speed for each runner for each delivery and do you notice any trend for these values?

-- select
-- runner_id,
-- order_id,
-- c_distance_km,
-- round(avg(c_distance_km*60/c_duration_min) over(partition by order_id),2) as avg_speedkmph,
-- round(avg(c_distance_km*60/c_duration_min) over(partition by runner_id),2) as avg_runner_speedkmph
-- from c_runner_orders
-- where c_cancellation is null
-- order by runner_id;

-- B.7. What is the successful delivery percentage for each runner?
-- select runner_id,
-- round((sum(case when c_cancellation is null then 1 else 0 end)/count(order_id))*100,2) as successfulOrders
-- from c_runner_orders
-- group by runner_id;

-- CREATE TABLE numbers (
--   n INT PRIMARY KEY);
-- INSERT INTO numbers VALUES (1),(2),(3),(4),(5),(6),(7),(8),(9),(10),(11),(12);


-- C.1. What are the standard ingredients for each pizza?
create view c_recipes as
select
  pizza_id,
  cast(SUBSTRING_INDEX(SUBSTRING_INDEX(toppings, ',', numbers.n), ',', -1) as unsigned) as topping_id
from
  numbers inner join pizza_recipes
  on CHAR_LENGTH(toppings)-CHAR_LENGTH(REPLACE(toppings, ',', ''))>=numbers.n-1
order by pizza_id, topping_id;

-- select
-- r.pizza_id,
-- n.pizza_name,
-- GROUP_CONCAT(t.topping_name SEPARATOR ', ') as ingredients
-- from c_recipes as r
-- join pizza_toppings as t using(topping_id)
-- join pizza_names as n using(pizza_id)
-- group by r.pizza_id, n.pizza_name;

-- C.2. What was the most commonly added extra?
-- WITH normal_extra AS (
-- 	select
-- 	order_id,
-- 	customer_id,
-- 	cast(SUBSTRING_INDEX(SUBSTRING_INDEX(c_extras, ',', numbers.n), ',', -1) as unsigned) as c_extras
-- from
--   numbers inner join c_customer_orders
--   on CHAR_LENGTH(c_extras)-CHAR_LENGTH(REPLACE(c_extras, ',', ''))>=numbers.n-1
-- order by order_id
-- )
-- select
-- ne.c_extras as Extras,
-- p.topping_name,
-- count(c_extras) as No_ordered
-- from normal_extra as ne
-- join pizza_toppings as p on ne.c_extras = p.topping_id
-- group by c_extras;


-- C.3. What was the most common exclusion?
-- WITH normal_extra AS (
-- 	select
-- 	order_id,
-- 	customer_id,
-- 	cast(SUBSTRING_INDEX(SUBSTRING_INDEX(c_exclusions, ',', numbers.n), ',', -1) as unsigned) as c_exclusions
-- from
--   numbers inner join c_customer_orders
--   on CHAR_LENGTH(c_exclusions)-CHAR_LENGTH(REPLACE(c_exclusions, ',', ''))>=numbers.n-1
-- order by order_id
-- )
-- select
-- ne.c_exclusions as Exclusions, p.topping_name, count(c_exclusions) as No_ordered
-- from normal_extra as ne join pizza_toppings as p on ne.c_exclusions = p.topping_id
-- group by c_exclusions;



/*
C.4.
Generate an order item for each record in the customers_orders table in the format of one of the following:
Meat Lovers
Meat Lovers - Exclude Beef
Meat Lovers - Extra Bacon
Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers
*/
-- table with the cleaned exclusions and extras
-- CREATE VIEW extraexclu AS
--     SELECT 
--         order_id,
--         customer_id,
--         pizza_id,
--         CAST(SUBSTRING_INDEX(c_exclusions, ',', 1) AS UNSIGNED) AS exclusion1,
--         case
--         when length(c_exclusions) <2 then nullif(1,1)
--         else CAST(SUBSTRING_INDEX(SUBSTRING_INDEX(c_exclusions, ',', 2),',',- 1) AS UNSIGNED) 
--         end
--         AS exclusion2,
--         CAST(SUBSTRING_INDEX(c_extras, ',', 1) AS UNSIGNED) AS extra1,
--         case
--         when length(c_extras)<2 then nullif(1,1)
--         else CAST(SUBSTRING_INDEX(SUBSTRING_INDEX(c_extras, ',', 2),',',- 1) AS UNSIGNED) 
--         end
--         AS extra2
--     FROM
--         c_customer_orders;

-- create temporary table questionc4
-- select
-- e.order_id,
-- e.customer_id,
-- pn.pizza_name,
-- t1.topping_name as exclusion_1,
-- t2.topping_name as exclusion_2,
-- t3.topping_name as extra_1,
-- t4.topping_name as extra_2
-- from extraexclu as e
-- join pizza_names as pn using(pizza_id)
-- left join pizza_toppings as t1 on e.exclusion1=t1.topping_id
-- left join pizza_toppings as t2 on e.exclusion2=t2.topping_id
-- left join pizza_toppings as t3 on e.extra1=t3.topping_id
-- left join pizza_toppings as t4 on e.extra2=t4.topping_id;


-- select order_id,
-- case
-- 	when exclusion_1 is null and exclusion_2 is null and extra_1 is null and extra_2 is null
-- 		then pizza_name
-- 	when exclusion_1 is not null and exclusion_2 is null and extra_1 is null and extra_2 is null
-- 		then concat(pizza_name, " - Exclude ", exclusion_1)
-- 	when exclusion_1 is null and exclusion_2 is null and extra_1 is not null and extra_2 is null
-- 		then concat(pizza_name, " - Extra ", extra_1)
-- 	when exclusion_1 is not null and exclusion_2 is not null and extra_1 is null and extra_2 is null
-- 		then concat(pizza_name, " - Exclude ", exclusion_1,", ",exclusion_2)
-- 	when exclusion_1 is not null and exclusion_2 is null and extra_1 is not null and extra_2 is null
-- 		then concat(pizza_name, " - Exclude ", exclusion_1," - Extra ",extra_1)
-- 	when exclusion_1 is null and exclusion_2 is null and extra_1 is not null and extra_2 is not null
-- 		then concat(pizza_name, " - Extra ", extra_1, ", ",extra_2)
-- 	when exclusion_1 is not null and exclusion_2 is not null and extra_1 is not null and extra_2 is null
-- 		then concat(pizza_name, " - Exclude ", exclusion_1,", ",exclusion_2 ," - Extra ", extra_1)
-- 	when exclusion_1 is not null and exclusion_2 is null and extra_1 is not null and extra_2 is not null
-- 		then concat(pizza_name, " - Exclude ", exclusion_1," - Extra ", extra_1, ", ", extra_2)
-- 	else concat(pizza_name, " - Exclude ", exclusion_1, ", ", exclusion_2, " - Extra ", extra_1, ", ", extra_2)
-- end as OrderDetails
-- from questionc4;

-- drop temporary table questionc4;


/*
C.5.
Generate an alphabetically ordered comma separated ingredient list 
for each pizza order from the customer_orders table and add a 2x in front of any relevant ingredients
For example: "Meat Lovers: 2xBacon, Beef, ... , Salami"
*/

-- Solved in trial 2