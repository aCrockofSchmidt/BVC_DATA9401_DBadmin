USE Tuesday_Exercise

SELECT * FROM booksWIZARD

SELECT title, authors, average_rating, num_pages
FROM booksWIZARD
WHERE num_pages BETWEEN 100 AND 200
ORDER by num_pages DESC

SELECT title, authors, average_rating, num_pages
FROM booksWIZARD
WHERE authors LIKE '%Agatha%'
AND num_pages >100
ORDER by num_pages DESC

-- DISTINCT --

SELECT DISTINCT publisher
FROM booksWIZARD

SELECT *
FROM booksWIZARD
WHERE average_rating >= 4.75 AND num_pages >= 400 OR publisher = 'Harvard University Press'
ORDER BY average_rating DESC

-- BETWEEN --

SELECT *
FROM booksWIZARD
WHERE average_rating BETWEEN 3 AND 4
ORDER BY average_rating DESC

-- NOT --

SELECT *
FROM booksWIZARD
WHERE NOT (publisher = 'Harvard University Press' OR publisher = 'Random House')
ORDER BY publisher ASC

-- UNION --

SELECT title, publisher, num_pages, average_rating
FROM booksWIZARD
WHERE num_pages = 503
UNION
SELECT title, publisher, num_pages, average_rating
FROM WIZARDbooks
WHERE average_rating = 4.72
ORDER BY num_pages

-- Experimenting to understand columns chosen implications --

SELECT title, average_rating
FROM booksWIZARD
WHERE average_rating = 2
UNION
SELECT publisher, num_pages
FROM WIZARDbooks
WHERE num_pages = 503

-- note in the above that the results show the results from both SELECT statements but put them in columns labeled only by the first SELECT --


-- Trying INTERSECT --

SELECT * FROM booksWIZARD
WHERE average_rating BETWEEN 2.00 AND 4.00
INTERSECT
SELECT * FROM WIZARDbooks
WHERE average_rating BETWEEN 3.00 AND 5.00

-- If the two tables have a different set of columns that don't all fully match, you must be more specific than * to get it to work --

SELECT title, average_rating FROM booksWIZARD
WHERE average_rating BETWEEN 2.00 AND 4.00
INTERSECT
SELECT title, average_rating FROM booksCLIPPED
WHERE average_rating BETWEEN 3.00 AND 5.00 

SELECT * FROM booksCLIPPED

-- Trying EXCEPT --

SELECT * FROM booksWIZARD
WHERE average_rating BETWEEN 2.00 AND 4.00
EXCEPT
SELECT * FROM WIZARDbooks
WHERE average_rating BETWEEN 3.00 AND 5.00


SELECT title, average_rating FROM booksWIZARD
WHERE average_rating BETWEEN 2.00 AND 4.00
EXCEPT
SELECT title, average_rating FROM booksCLIPPED
WHERE average_rating BETWEEN 3.00 AND 5.00 

-- neither of these are working as expected and I don't know why --






