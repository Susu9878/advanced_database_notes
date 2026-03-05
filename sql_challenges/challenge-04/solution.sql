-- free sql try it
--1
select b.*,
       count(*) over (
         partition by shape
       ) bricks_per_shape,
       median ( weight ) over (
         partition by shape
       ) median_weight_per_shape
from   bricks b
order  by shape, weight, brick_id;

--2
select b.brick_id, b.weight,
       round ( avg ( weight ) over (
         order by brick_id
       ), 2 ) running_average_weight
from   bricks b
order  by brick_id;

--3
select b.*,
       min ( colour ) over (
         order by brick_id
         rows between 2 preceding and 1 preceding
       ) first_colour_two_prev,
       count (*) over (
         order by weight
         range between current row and 1 following
       ) count_values_this_and_next
from   bricks b
order  by weight;

--4
with totals as (
  select b.*,
         sum ( weight ) over (
           partition by shape
         ) weight_per_shape,
         sum ( weight ) over (
           order by brick_id 
         ) running_weight_by_id
  from   bricks b
)
select * from totals
where  weight_per_shape > 4 AND running_weight_by_id > 4
order  by brick_id  

-- datalemur top 3 salaries
WITH top_salary AS (
  SELECT name, salary, department_id,
    DENSE_RANK() OVER (
      PARTITION BY department_id ORDER BY salary DESC) AS ranking
  FROM employee
)

SELECT ts.name, ts.salary, d.department_name
FROM top_salary AS ts
INNER JOIN department AS d
  ON d.department_id = ts.department_id
WHERE ts.ranking <= 3
ORDER BY d.department_name ASC, ts.salary DESC, ts.name ASC;