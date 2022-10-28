-- create view c_customer_orders as
--  select 
--  	order_id,
--      customer_id,
--      pizza_id,
--      order_time,
--      case
--  		when exclusions = '' then nullif(exclusions, '')
--          when exclusions = 'null' then nullif(exclusions, 'null')
--          else exclusions
--  	end as c_exclusions,
--      case
--  		when extras = '' then nullif(extras, '')
--          when extras = 'null' then nullif(extras, 'null')
--          else extras
--  	end as c_extras
--  from 
--  	customer_orders;

-- select * from customer_orders;
-- select * from c_customer_orders;
    
-- UPDATE runner_orders
-- SET distance = REPLACE(distance,' ','');

-- UPDATE runner_orders
-- SET distance = concat(distance,'km')
-- where
-- distance != 'null'
-- and
-- distance not like '%km';

-- update runner_orders
-- set distance = left(distance, length(distance)-2)
-- where
-- distance != 'null';

-- update runner_orders
-- set duration = left(duration, 2)
-- where
-- duration != 'null';

-- create view c_runner_orders as
-- select
-- 	order_id,
--     runner_id,
--     cast(
-- 			case
-- 				when pickup_time = '' then nullif(pickup_time, '')
-- 				when pickup_time = 'null' then nullif(pickup_time, 'null')
-- 				else pickup_time
-- 			end 
-- 			-- as c_pickup_time
--         as datetime
--         ) as c_pickup_time,
-- 	case
--  		when cancellation = '' then nullif(cancellation, '')
--         when cancellation = 'null' then nullif(cancellation, 'null')
-- 		else cancellation
--  	end as c_cancellation,
-- 	convert(
--     case
-- 		when distance = 'null' then nullif(distance, 'null')
-- 		else distance
-- 	end,
--     decimal(5,2))
--     as c_distance_km,
--     convert(
--     case
-- 		when duration = 'null' then nullif(distance, 'null')
-- 		else duration
-- 	end,
--     unsigned)
--     as c_duration_min
-- from
-- 	runner_orders;

-- select * from c_runner_orders;
-- select * from c_customer_orders;

/*
the above steps are used for cleaning the messy data and messy data types
to access the cleaned tables use the views creted.
rest of the tables are clean and can be taken from the original schema
*/  