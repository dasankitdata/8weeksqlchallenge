-- VERIFIED
-- create view extex_name as
-- select e.order_id, e.customer_id, e.pizza_id, rn1.topping_name exclusion1, rn2.topping_name exclusion2, rn3.topping_name extra1, rn4.topping_name extra2
-- from extraexclu as e
-- left join pizza_toppings as rn1 on e.exclusion1=rn1.topping_id
-- left join pizza_toppings as rn2 on e.exclusion2=rn2.topping_id
-- left join pizza_toppings as rn3 on e.extra1=rn3.topping_id
-- left join pizza_toppings as rn4 on e.extra2=rn4.topping_id;

-- VERIFIED
-- create view c_recipes_name as
-- select r.pizza_id, r.topping_id, p.topping_name
-- from c_recipes as r join pizza_toppings as p using(topping_id) order by r.pizza_id;


-- VERIFIED
-- create view pname as
-- select pizza_id, group_concat(topping_name separator ', ') listing
-- from c_recipes_name
-- group by pizza_id;

-- VERIFIED
-- create view fullnames as
-- select order_id, customer_id, e.pizza_id, p.listing as ogIngredient, exclusion1, exclusion2, extra1, extra2
-- from extex_name as e
-- join pname as p on e.pizza_id = p.pizza_id;

-- VERIFIED
-- create view ex1 as
-- select
-- 	order_id,
--     customer_id,
--     pizza_id,
--     ogIngredient,
--     exclusion1,
--     exclusion2,
--     extra1,
--     extra2,
--     case
-- 		when exclusion1 is not null then REPLACE(ogIngredient, (exclusion1), '')
-- 		else ogIngredient
-- 	end as ex_orders
-- from fullnames;

-- VERIFIED
-- create view ex2 as
-- select
-- 	order_id,
--     customer_id,
--     pizza_id,
--     ogIngredient,
--     exclusion1,
--     exclusion2,
--     extra1,
--     extra2,
-- 	case
-- 		when exclusion2 is not null then REPLACE(ex_orders, (exclusion2), '')
-- 		else ex_orders
-- 	end as ex2_orders
-- from ex1;

-- VERIFIED
-- create view ex3 as
-- select
-- 	order_id,
--     customer_id,
--     pizza_id,
--     ogIngredient,
--     exclusion1,
--     exclusion2,
--     extra1,
--     extra2,
--     case
-- 		when extra1 is not null then replace(ex2_orders, extra1, concat('2x ',extra1))
--         else ex2_orders
-- 	end as ex3_orders
-- from
-- 	ex2;

-- VERIFIED
-- create view ex4 as
-- select
-- 	order_id,
--     customer_id,
--     pizza_id,
--     ogIngredient,
--     exclusion1,
--     exclusion2,
--     extra1,
--     extra2,
--     case
-- 		when extra2 is not null then replace(ex3_orders, extra2, concat('2x', extra2))
--         else ex3_orders
-- 	end as ex4_orders
-- from
-- 	ex3;
    
-- select
-- 	e.order_id,
--     e.customer_id,
--     e.pizza_id,
--     concat(p.pizza_name,' - ',TRIM(BOTH ',' FROM replace(e.ex4_orders,', ,',','))) as PizzaOrdered
-- from
-- 	ex4 as e
-- join pizza_names as p on e.pizza_id = p.pizza_id;


/*
C.6. What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?
*/

-- create view q6_1 as
-- select order_id, customer_id, r.toppings as pizzastuff, exclusion1, exclusion2, extra1, extra2
-- from extraexclu as e
-- join pizza_recipes as r on e.pizza_id = r.pizza_id;

-- create view q6_2 as
-- select *,
-- case
-- 	when extra1 is not null and extra2 is null then concat(pizzastuff,', ',extra1)
--     when extra1 is not null and extra2 is not null then concat(pizzastuff,', ',extra1,', ', extra2)
--     else pizzastuff
-- end as pizzastuff1
-- from q6_1;

-- create view q6_3 as
-- select
-- order_id,
-- customer_id,
-- exclusion1,
-- exclusion2,
-- case
-- 	when exclusion1 is not null then replace(pizzastuff1, concat(exclusion1,', '),'')
--     else pizzastuff1
-- end as pizzastuff2
-- from q6_2;

-- create view q6_4 as
-- select
-- row_number() over() orders,
-- order_id,
-- customer_id,
-- case
-- 	when exclusion2 is not null then replace(pizzastuff2, concat(exclusion2,', '),'')
--     else pizzastuff2
-- end as allIngredients
-- from q6_3;


-- create view c_ingredients as
-- select
--   orders, order_id, customer_id,
--   cast(SUBSTRING_INDEX(SUBSTRING_INDEX(allIngredients, ',', numbers.n), ',', -1) as unsigned) as ingredients
-- from
--   numbers inner join q6_4
--   on CHAR_LENGTH(allIngredients)-CHAR_LENGTH(REPLACE(allIngredients, ',', ''))>=numbers.n-1
-- order by orders, order_id, customer_id;

-- select
--     p.topping_name,
--     count(ingredients) as timesadded
-- from
-- 	c_ingredients as i
-- join
-- 	pizza_toppings as p on ingredients = p.topping_id
-- group by
-- 	ingredients
-- order by
-- 	timesadded desc,
-- 	p.topping_name;