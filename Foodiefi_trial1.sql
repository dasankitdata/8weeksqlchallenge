-- select
-- s.customer_id,
-- p.plan_name,
-- p.price,
-- sum(price) over(partition by customer_id) as totalspent,
-- s.start_date
-- from subscriptions as s
-- left join plans as p
-- using(plan_id)
-- where s.customer_id <=19;

-- 1. How many customers has Foodie-Fi ever had?
-- select count(distinct customer_id) from subscriptions;

-- 2. What is the monthly distribution of trial plan start_date values for our dataset - use the start of the month as the group by value
-- select min(start_date), max(start_date)
-- from subscriptions;

-- select
-- distinct monthname(start_date),
-- count(plan_id) over(
-- 	partition by monthname(start_date)
--     order by month(start_date)
--     )
-- from subscriptions
-- where plan_id=0
-- order by month(start_date);

-- select monthname(start_date),count(plan_id)
-- from subscriptions
-- where plan_id = 0
-- group by monthname(start_date)
-- order by month(start_date);

-- 3. What plan start_date values occur after the year 2020 for our dataset? Show the breakdown by count of events for each plan_name
-- select
-- p.plan_name,
-- count(p.plan_name)
-- from subscriptions as s
-- left join plans as p using(plan_id)
-- where year(start_date)>2020
-- group by p.plan_name;

-- What is the customer count and percentage of customers who have churned rounded to 1 decimal place?
-- with churns as
-- (
-- 	select count(distinct customer_id) as churned
--     from subscriptions s join plans p using(plan_id)
--     where plan_name = 'churn'
-- )
-- select
-- 	churned,
--     concat(round(churned/count(distinct customer_id)*100, 1),'%') as percent_churn
--     from subscriptions join churns;

-- 5.How many customers have churned straight after their initial free trial - what percentage is this rounded to the nearest whole number?
-- select * from subscriptions
-- left join plans using(plan_id) order by customer_id;

-- SET @totalCustomers=(SELECT COUNT(DISTINCT customer_id) FROM subscriptions);

-- with maxp as(
-- select
-- customer_id,
-- plan_id
-- ,count(plan_id) over(partition by customer_id) as no_of_plans,
-- coalesce(lead(plan_id) over(partition by customer_id),0) as max_plan
-- from subscriptions)
-- select
-- count(customer_id) no_of_churns,
-- concat(round((count(customer_id)/@totalCustomers)*100,0),'%') churn_per
-- from maxp
-- where no_of_plans = 2 and max_plan=4;

-- 6.What is the number and percentage of customer plans after their initial free trial?
-- with tempt as(
-- SELECT
-- customer_id,
-- plan_id,
-- RANK() OVER(PARTITION BY customer_id 
-- 	ORDER BY start_date
--     ) as plan_order
-- FROM subscriptions
-- WHERE plan_id != 0
-- )
-- select
-- p.plan_name,
-- count(t.plan_id) as no_of_subs,
-- round(count(t.plan_id)/@totalCustomers*100, 2) as prectent_subs
-- from tempt as t join plans as p using(plan_id)
-- where t.plan_order = 1
-- group by p.plan_name
-- order by t.plan_id;

-- 7. What is the customer count and percentage breakdown of all 5 plan_name values at 2020-12-31?
-- with tempt as
-- (
-- select
-- customer_id,
-- plan_id,
-- rank() over(
-- 	partition by customer_id order by start_date desc) as ranks
-- from subscriptions
-- where start_date <= '2020-12-31'
-- )
-- select plan_id, count(plan_id),
-- round(count(plan_id)/1000*100,1) as per_customer
-- from tempt
-- where ranks = 1
-- group by plan_id
-- order by plan_id;

-- 8. How many customers have upgraded to an annual plan in 2020?
-- select
-- p.plan_name,
-- count(distinct customer_id)
-- from
-- subscriptions s
-- join plans p using(plan_id)
-- where p.plan_name='pro annual' and year(start_date)='2020'
-- ;

-- 9. How many days on average does it take for a customer to an annual plan from the day they join Foodie-Fi?

-- with tempt as
-- (
-- select
-- customer_id,
-- plan_id,
-- start_date as annual_start
-- from subscriptions
-- where plan_id=3
-- )
-- select
-- s.customer_id,
-- -- s.plan_id,
-- s.start_date,
-- -- t.plan_id,
-- t.annual_start,
-- datediff(t.annual_start, s.start_date) as no_of_days,
-- round(avg(datediff(t.annual_start, s.start_date)) over() ,0) as avg_no_days
-- from
-- subscriptions s join
-- tempt t on s.customer_id = t.customer_id
-- where s.plan_id=0;

-- 10. Can you further breakdown this average value into 30 day periods (i.e. 0-30 days, 31-60 days etc)
-- 0-30
-- 31-60
-- 61-90
-- 91-120....

-- create view v1 as
-- SELECT 
-- 	customer_id, 
-- 	start_date AS join_date
-- FROM subscriptions
-- WHERE plan_id = 0;

-- create view v2 as
-- select
-- 	customer_id,
--     start_date as annual_date
-- from subscriptions
-- where plan_id=3;

-- create view v3 as
-- select v1.customer_id,
-- 	v1.join_date,
--     v2.annual_date,
--     datediff(v2.annual_date, v1.join_date)  as ddiff,
--     ceil(datediff(v2.annual_date, v1.join_date)/30) as buck
-- from v1
-- inner join v2 using(customer_id);

-- select
-- 	case
-- 		when buck = 1 or buck = 0 then CONCAT('0 - 30 days')
--         else concat((((buck-1)*30)+1), ' - ', (buck*30),' days')
-- 	end as period,
--     count(customer_id) as n_cust,
--     round(avg(ddiff),2) as avg_days
-- from v3
-- group by buck
-- order by ddiff;


-- How many customers downgraded from a pro monthly to a basic monthly plan in 2020?

-- WITH downgraded_customers AS(
--   SELECT
--     CASE 
--       WHEN 
--         plan_id = 2  -- pro monthly plan 
--         AND
--         LEAD(plan_id) OVER (PARTITION BY customer_id ORDER BY start_date) = 1  -- basic monthly plan
--       THEN 1
--       ELSE 0
--     END as is_downgraded
--   FROM subscriptions
-- )

-- SELECT 
--     SUM(is_downgraded) AS total_downgrads
-- FROM
--     downgraded_customers;
 