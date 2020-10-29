USE Tuesday_Exercise;

SELECT * FROM Planets;
SELECT * FROM planets1;

INSERT INTO planets1(PlanetName, diameter)
VALUES ('Venus', 3000),
('Jupiter', 25000),
('Saturn', 22000),
('Mercury', 1020),
('Neptune', 4400),
('Uranus', 5500);

CREATE FUNCTION totalPlanets
RETURN number IS
Total number(2) = 0
BEGIN
SELECT COUNT(*) INTO total
FROM planets1
Return total
END;

SELECT totalPlanets

-- Trying something else from www.databasejournal.com website Arta shared --

CREATE TABLE ud_function_exercise (
employeeID int NOT NULL PRIMARY KEY,
employeeName varchar(255) NOT NULL,
payRate money,
hoursWorked numeric
);

SELECT * FROM ud_function_exercise;

INSERT INTO ud_function_exercise
VALUES (1000, 'Jim', 20, 40),
(2000, 'Cindy', $15, 40),
(3000, 'Kim', $17.50, 40),
(4000, 'Roger', 33.25, 20);

-- I will now create a user-defined function that calculates the total pay for each employee --

CREATE FUNCTION uf_employeePAY(@rate money, @hours int)
RETURNS money
AS
BEGIN
DECLARE @totalPAY money;
SELECT @totalPAY = @rate * @hours;
RETURN @totalPAY;
END

SELECT *, dbo.uf_employeePAY(payRate, hoursWorked)
FROM ud_function_exercise
WHERE employeeID = 3000

DROP FUNCTION dbo.uf_employeePAY

-- this finally worked --

-- okay, let's use the same information to create a user-defined function that makes TABLE as shown in databasejournal.com --
-- from a large database of books and reader ratings I want to extract a simple table with just title and author --

SELECT * FROM booksWIZARD;

CREATE FUNCTION uf_bookLIST(@rating float)
RETURNS @bookLISTtable TABLE
(
title varchar(1000),
authors varchar(1000)
)
AS
BEGIN
INSERT INTO @bookLISTtable
	SELECT booksWIZARD.title, booksWIZARD.authors
	FROM booksWIZARD
	WHERE average_rating = @rating
	RETURN
END;

SELECT *
FROM uf_bookLIST()

DROP FUNCTION dbo.uf_bookLIST

