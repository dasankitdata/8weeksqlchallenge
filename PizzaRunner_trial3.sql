/*
If a Meat Lovers pizza costs $12 and 
Vegetarian costs $10 and there were no charges for changes - 
how much money has Pizza Runner made so far if there are no delivery fees?
*/

-- with d1 as(
-- select
-- distinct e.pizza_id,
-- p.pizza_name,
-- count(e.pizza_id) over( partition by e.pizza_id) as num_pizza
-- from extraexclu as e join pizza_names as p using(pizza_id))
-- select
-- concat(sum(
-- 	case
-- 		when pizza_name='Meatlovers' then num_pizza*12
--         else num_pizza*10
-- 	end
--     ),'$') as TotalEarned
-- from d1;

/*
What if there was an additional $1 charge for any pizza extras?
Add cheese is $1 extra
*/

-- with prices as
-- (select
-- order_id,
-- customer_id,
-- pizza_id,
-- case
-- 	when pizza_id = 1 and extra1 is null and extra2 is null then 12
--     when pizza_id = 1 and extra1 = 'Cheese' and extra2 is null then 12+1+1
--     when pizza_id = 1 and extra1 is not null and extra2 is null then 12+1
--     when pizza_id = 1 and extra1 = 'Cheese' and extra2 is  not null then 12+1+1+1
--     when pizza_id = 1 and extra1 is not null and extra2 = 'Cheese' then 12+1+1+1
--     when pizza_id = 1 and extra1 is not null and extra2 is not null then 12+1+1
--     when pizza_id = 2 and extra1 is null and extra2 is null then 10
--     when pizza_id = 2 and extra1 = 'Cheese' and extra2 is null then 10+1+1
--     when pizza_id = 2 and extra1 is not null and extra2 is null then 10+1
--     when pizza_id = 2 and extra1 = 'Cheese' and extra2 is  not null then 10+1+1+1
--     when pizza_id = 2 and extra1 is not null and extra2 = 'Cheese' then 10+1+1+1
--     else 
--     -- pizza_id = 2 and extra1 is not null and extra2 is not null then 
--     10+1+1
-- end as Pricing
-- from extex_name)
-- select
-- sum(Pricing) as Total_2
-- from prices;

/*
The Pizza Runner team now wants to add an additional ratings system that allows customers to rate their runner, 
how would you design an additional table for this new dataset - 
generate a schema for this new table and insert your own data for ratings for each successful customer order between 1 to 5.
*/

/*
If a Meat Lovers pizza was $12 and Vegetarian $10 fixed prices
with no cost for extras and each runner is paid $0.30 per kilometre traveled -
how much money does Pizza Runner have left over after these deliveries?
*/

-- with t1 as
-- (
-- select
-- *,
-- round(r.c_distance_km*0.32, 2) as dist_price
-- from c_customer_orders
-- join c_runner_orders as r using(order_id))
-- select
-- sum(case
-- 	when pizza_id = 1 then 12+dist_price
-- 	else 10+dist_price
-- end) as total_price
-- from t1
-- where dist_price is not null;
