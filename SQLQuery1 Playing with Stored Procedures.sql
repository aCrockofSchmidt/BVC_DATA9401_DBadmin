USE Tuesday_Exercise

SELECT * FROM booksWIZARD
ORDER BY authors ASC

-- I will now create a Stored Procedure that allows me to show all records from a specified author and rating --

CREATE PROCEDURE sp_AuthorRating
@author varchar(500), @rating varchar(500)
AS
SELECT * FROM booksWIZARD
WHERE authors = @author AND average_rating > @rating

EXEC sp_AuthorRating 'Dr. Seuss', 3

DROP PROCEDURE sp_AuthorRating