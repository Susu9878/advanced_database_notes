-- lesson 6
SELECT * FROM movies join boxoffice on movies.id = boxoffice.movie_id;
SELECT * FROM movies join boxoffice on movies.id = boxoffice.movie_id where international_sales > domestic_sales;
SELECT * FROM movies join boxoffice on movies.id = boxoffice.movie_id ORDER BY rating DESC;

-- lesson 7
SELECT DISTINCT building FROM employees;
SELECT * FROM buildings;
SELECT DISTINCT building_name, role FROM buildings LEFT JOIN employees ON building = building_name;

-- interview question
SELECT pages.page_id FROM pages LEFT JOIN page_likes ON pages.page_id = page_likes.page_id 
WHERE page_likes.page_id IS NULL ORDER BY PAGES.page_id ASC;