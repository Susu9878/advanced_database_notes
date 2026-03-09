-- Review update
--lesson 10
SELECT *, MAX(years_employed) FROM employees ;
SELECT *, AVG(years_employed) FROM employees group by role;
SELECT *, SUM(years_employed) FROM employees group by building;

--lesson 11
SELECT COUNT(*) FROM employees WHERE role = "Artist";
SELECT role, COUNT(*) FROM employees GROUP BY role;
SELECT role, SUM(years_employed) FROM employees WHERE role = "Engineer";

--freesql oracle
--try it 1
SELECT COUNT(distinct shape) AS number_of_shapes,
       Stddev(distinct weight) AS distinct_weight_stddev
FROM   bricks;

--try it 2
SELECT shape, SUM(weight) AS shape_weight
FROM   bricks
GROUP BY shape
ORDER BY shape ASC;

--try it 3
SELECT shape, SUM(weight)
FROM   bricks
GROUP  BY shape
HAVING SUM(weight) < 4;