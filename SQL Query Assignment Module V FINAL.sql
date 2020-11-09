USE Module_V;

SELECT * FROM masterModuleV ORDER BY studentID ASC;
SELECT * FROM studentTable ORDER BY studentID ASC;
SELECT * FROM marksTable ORDER BY marksID ASC;
SELECT * FROM gradeTable ORDER BY gradeID ASC;
SELECT * FROM gradeCalculations ORDER BY studentID ASC;

SELECT dbo.ufn_marksCount (10019) AS testResult;
SELECT dbo.ufn_marksSum (10019) AS testResult;
SELECT dbo.ufn_marksAverage (10019) AS testResult;

DROP TABLE masterModuleV;
DROP TABLE studentTable;
DROP TABLE marksTable;
DROP TABLE gradeTable;
DROP TABLE gradeCalculations;

DROP FUNCTION ufn_marksCount;
DROP FUNCTION ufn_marksSum;
DROP FUNCTION ufn_marksAverage;

-- Basic Checking for duplicate studentID which is an ideal Candidate Key and therefore should be unique --

SELECT studentID, COUNT(studentID) occurences
FROM masterModuleV
GROUP BY studentID
HAVING COUNT(studentID) > 1;

-- Three duplicates found so lets view entire record to determine if truly duplicate --

SELECT First_name, COUNT(First_name) occurrences, Lastname, COUNT(Lastname) occurrences
FROM masterModuleV
GROUP BY First_name, Lastname
HAVING COUNT(First_name) > 1 AND COUNT(Lastname) > 1;

-- Nothing found so duplicate student IDs do not represent duplicated records - lets confirm visually --

SELECT * FROM masterModuleV
WHERE studentID = 35932 OR studentID = 47058 OR studentID = 64698
ORDER BY studentID;

-- Lets see if the students with identical student IDs are in the databse under other student ID numbers --

SELECT * FROM masterModuleV
WHERE
First_name = 'Lynde' AND Lastname = 'Ducker'
OR First_name = 'Tallulah' AND Lastname = 'Lynes'
OR First_name = 'Chen' AND Lastname = 'Dumbleton'
OR First_name = 'Jaye' AND Lastname = 'Margett'
OR First_name = 'Aurea' AND Lastname = 'Longea'
OR First_name = 'Claudian' AND Lastname = 'Burree'
ORDER BY studentID;

-- There are not so there were erroneous student ID numbers entered for 3 students --
-- Change three of the studentID values to unique numbers so that the studentID attribute can be use as a Primary Key --

UPDATE masterModuleV
SET studentID = 99944
WHERE First_Name = 'Tallulah' and Lastname = 'Lynes';

UPDATE masterModuleV
SET studentID = 99966
WHERE First_Name = 'Jaye' and Lastname = 'Margett';

UPDATE masterModuleV
SET studentID = 99988
WHERE First_Name = 'Claudian' and Lastname = 'Burree';

-- The master table remains in violation of 1NF since there are multiple columns storing similar data (ie two assignment columns etc) --
-- I will create an ERD in Excel to determine my table structure and then return to code the into reality --

-- I have determined the need for a Student Table, and Marks Table to remove the 1NF violations --

CREATE TABLE studentTable
(
studentID INT NOT NULL PRIMARY KEY,
firstName VARCHAR(25) NOT NULL,
lastName VARCHAR(25)NOT NULL
);

CREATE TABLE marksTable
(
marksID INT IDENTITY(10000,5) NOT NULL PRIMARY KEY,
studentID INT NOT NULL FOREIGN KEY REFERENCES studentTable(studentID),
markType VARCHAR(25),
markEarned DEC(5,2)
);

INSERT INTO studentTable(studentID, firstName, lastName)
SELECT studentID, First_name, Lastname
FROM masterModuleV;

INSERT INTO marksTable(studentID, markType, markEarned)
SELECT studentID, 'Midterm', Midtermexam
FROM masterModuleV
UNION
SELECT studentID, 'Final', Finalexam
FROM masterModuleV
UNION
SELECT studentID, 'Assignment1', assignment1
FROM masterModuleV
UNION
SELECT studentID, 'Assignment2', assignment2
FROM masterModuleV;

-- The created student table and the marks table are both 3NF compliant --

-- Three columns remain unaddressed in the master table: Totalpoints, Studentaverage, Grade --
-- Totalpoints and Studentaverage are both calculated from the values in the marks table and therefore does not need to be stored in the DB --
-- Grade is "calculated" based on the Studentaverage so it also does not need to be stored in the DB --
-- However, assigning Grade woudl benefit from a grade table containing criteria for assessing letter grade --

-- This will create a 3NF compliant grade table --
-- Using standard Ontario grade ranges which seemed to be closest to what was used in the original data --

CREATE TABLE gradeTable
(
gradeID INT NOT NULL IDENTITY PRIMARY KEY,
gradeLetter VARCHAR(2),
gradeMin FLOAT,
gradeMax FLOAT
);

INSERT INTO gradeTable (gradeLetter, gradeMin, gradeMax)
VALUES
('A+', 95, 100),
('A', 87, 94.9999),
('A-', 80, 86.9999),
('B+', 77, 79.9999),
('B', 73, 76.9999),
('B-', 70, 72.9999),
('C+', 67, 69.9999),
('C', 63, 66.9999),
('C-', 60, 62.9999),
('D+', 57, 59.9999),
('D', 53, 56.9999),
('D-', 50, 52.9999),
('F', 0, 49.9999);

-- SUMMARY - I have created three 3NF tables --
-- SUMMARY - All data columns in the master table have been addressed --
-- SUMMARY - 1NF: duplicate records and repeated groups have been eliminated --
-- SUMMARY - 2NF: no partial dependencies remain in the tables --
-- SUMMARY - 3NF: no transient dependencies remain in the tables --

-- NOTE - partial and transient dependencies in this example were somewhat irrelevant because we are dealing with a single course rather than many --

-- User-defined functions are needed to calculate/replicate the Totalpoints and Studentaverage data --

CREATE FUNCTION ufn_marksCount (@student INT)
RETURNS INT
AS
BEGIN
DECLARE @marksCount INT
SELECT @marksCount = COUNT(studentID)
FROM marksTable
WHERE studentID = @student
RETURN @marksCount
END;

CREATE FUNCTION ufn_marksSum (@student INT)
RETURNS FLOAT
AS
BEGIN
DECLARE @marksSum FLOAT
SELECT @marksSum = SUM(markEarned) * 100
FROM marksTable
WHERE studentID = @student
RETURN @marksSum
END;

CREATE FUNCTION ufn_marksAverage (@student INT)
RETURNS FLOAT
AS
BEGIN
DECLARE @marksAverage FLOAT
SELECT @marksAverage = (dbo.ufn_marksSum(studentID)/100) / dbo.ufn_marksCount(studentID)
FROM marksTable
WHERE studentID = @student
RETURN @marksAverage
END;

-- A Grade Summary Table is needed to store these calculated values in computed columns --

CREATE TABLE gradeCalculations
(
studentID INT NOT NULL PRIMARY KEY,
);

INSERT INTO gradeCalculations (studentID)
SELECT studentID
FROM studentTable;

ALTER TABLE gradeCalculations
ADD
marksTotal AS dbo.ufn_marksSum(studentID),
marksAverage AS dbo.ufn_marksAverage(studentID);

-- We can now create a summary table using multiple joins of the Student Table, Grade Summary Table and Grade Letters Table --

SELECT studentTable.studentID AS 'Student ID', studentTable.firstName AS 'First Name', studentTable.lastName as 'Last Name',
gradeCalculations.marksTotal 'Total Marks', (gradeCalculations.marksAverage*100) AS '% Average', gradeTable.gradeLetter AS 'Letter Grade'
FROM studentTable
INNER JOIN gradeCalculations
ON studentTable.studentID = gradeCalculations.studentID
LEFT JOIN gradeTable
ON (gradeCalculations.marksAverage*100) BETWEEN gradeTable.gradeMin AND gradeTable.gradeMax
ORDER BY studentTable.lastName, studentTable.firstName

-- We can even recreate the original master table in a similar fashion --

SELECT studentTable.studentID, studentTable.firstName AS 'First_name', studentTable.lastName AS 'Lastname',
PVT.Midtermexam AS 'Midtermexam', PVT.Finalexam AS 'Finalexam', PVT.assignment1, PVT.assignment2,
gradeCalculations.marksTotal AS 'Totalpoints', gradeCalculations.marksAverage AS 'Studentaverage', gradeTable.gradeLetter AS 'Grade'
FROM studentTable
INNER JOIN gradeCalculations
ON studentTable.studentID = gradeCalculations.studentID
LEFT JOIN gradeTable
ON (gradeCalculations.marksAverage*100) BETWEEN gradeTable.gradeMin AND gradeTable.gradeMax
INNER JOIN 
	(SELECT studentID, Assignment1 AS assignment1, Assignment2 AS assignment2, Final AS Finalexam, Midterm AS Midtermexam 
	FROM
	(SELECT studentID, markType, markEarned
	 FROM marksTable) AS SourceTable
	PIVOT
	(
	 SUM(markEarned)
	 FOR markType IN (Assignment1, Assignment2, Final, Midterm)) 
	 AS PivotTable) AS PVT
ON studentTable.studentID = PVT.studentID
ORDER BY studentID

-- FINISHED --