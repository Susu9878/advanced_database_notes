-- lesson 1
SELECT title   FROM movies;
SELECT director   FROM movies;
SELECT director, title   FROM movies;
SELECT year, title   FROM movies;
SELECT * FROM movies;

-- lesson 2
SELECT * FROM movies WHERE id = 6;
SELECT * FROM movies WHERE year BETWEEN 2000 AND 2010;
SELECT * FROM movies WHERE year NOT BETWEEN 2000 AND 2010;
SELECT title, year FROM movies WHERE year <= 2003;

-- lesson 3
SELECT * FROM movies WHERE title LIKE "Toy Story%";
SELECT * FROM movies WHERE director = "John Lasseter";
SELECT * FROM movies WHERE director != "John Lasseter";
SELECT * FROM movies WHERE TITLE LIKE "WALL-%";

-- lesson 4
SELECT DISTINCT director FROM movies ORDER BY director ASC;
SELECT * FROM movies ORDER BY year DESC LIMIT 4;
SELECT title FROM movies ORDER BY title ASC LIMIT 5;
SELECT title FROM movies ORDER BY title ASC LIMIT 5 OFFSET 5;

-- lesson 5
SELECT * FROM north_american_cities WHERE country = "Canada";
SELECT * FROM north_american_cities WHERE country = "United States" ORDER BY latitude DESC;
SELECT * FROM north_american_cities WHERE longitude < -87.629798 ORDER BY longitude ASC
SELECT * FROM north_american_cities WHERE country = "Mexico" ORDER BY population DESC LIMIT 2;
SELECT * FROM north_american_cities WHERE country = "United States" ORDER BY population DESC LIMIT 2 OFFSET 2;