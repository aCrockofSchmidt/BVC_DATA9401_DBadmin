USE Module_V;

SELECT * FROM masterModuleV ORDER BY studentID ASC;
SELECT * FROM studentTable ORDER BY studentID ASC;
SELECT * FROM marksTable ORDER BY studentID ASC;
SELECT * FROM gradeLetters ORDER BY gradeID ASC;
SELECT * FROM gradeCalculations ORDER BY studentID ASC;

SELECT dbo.ufn_marksCount (10019) AS testResult;
SELECT dbo.ufn_marksSum (10019) AS testResult;
SELECT dbo.ufn_marksAverage (10019) AS testResult;

DROP TABLE masterModuleV;
DROP TABLE studentTable;
DROP TABLE marksTable;
DROP TABLE gradeLetters;
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
studentID INT NOT NULL PRIMARY KEY,
marksAssignment1 DEC(5,2),
marksAssignment2 DEC(5,2),
marksMidterm DEC(5,2),
marksFinal DEC(5,2)
);

INSERT INTO studentTable(studentID, firstName, lastName)
SELECT studentID, First_name, Lastname
FROM masterModuleV;

INSERT INTO marksTable(studentID, marksAssignment1, marksAssignment2, marksMidterm, marksFinal)
SELECT studentID, assignment1, assignment2, Midtermexam, Finalexam
FROM masterModuleV

-- The created student table and the marks table are both 3NF compliant --

-- Three columns remain unaddressed in the master table: Totalpoints, Studentaverage, Grade --
-- Totalpoints and Studentaverage are both calculated from the values in the marks table and therefore does not need to be stored in the DB --
-- Grade is "calculated" based on the Studentaverage so it also does not need to be stored in the DB --
-- However, assigning Grade woudl benefit from a grade table containing criteria for assessing letter grade --

-- This will create a 3NF compliant grade table --

CREATE TABLE gradeLetters
(
gradeID INT NOT NULL IDENTITY PRIMARY KEY,
gradeLetter VARCHAR(2),
gradeMin FLOAT,
gradeMax FLOAT
);

-- Using standard Ontario grade ranges which seemed to be closest to what was used in the original data --

INSERT INTO gradeLetters (gradeLetter, gradeMin, gradeMax)
VALUES
('A+', 95, 100),
('A', 87, 94),
('A-', 80, 86),
('B+', 77, 79),
('B', 73, 76),
('B-', 70, 72),
('C+', 67, 69),
('C', 63, 66),
('C-', 60, 62),
('D+', 57, 59),
('D', 53, 56),
('D-', 50, 52),
('F', 0, 49);

-- SUMMARY - I have created three 3NF tables --
-- SUMMARY - All data columns in the master table have been addressed --
-- SUMMARY - 1NF: duplicate records and repeated groups have been eliminated --
-- SUMMARY - 2NF: no partial dependencies remain in the tables --
-- SUMMARY - 3NF: no transient dependencies remain in the tables --

-- NOTE - partial and transient dependencies in this example were somewhat irrelevant because we are dealing with a single course rather than many --

-- User-defined functions are needed to calculate/replicate the Totalpoints and Studentaverage data --

SELECT count(*) - 1
FROM information_schema.columns
WHERE table_name = 'marksTable';

SELECT
    studentID,
    SUM(quantity) store_stocks
FROM
    production.stocks
GROUP BY
    studentID;







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
SELECT @marksSum = (marksAssignment1 + marksAssignment2 + marksMidterm + marksFinal) * 100
FROM marksTable
WHERE studentID = @student
RETURN @marksSum
END;

CREATE FUNCTION ufn_marksAverage (@student INT)
RETURNS DEC(5,2)
AS
BEGIN
DECLARE @marksAverage DEC(5,2)
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

SELECT studentTable.studentID, studentTable.firstName, studentTable.lastName, gradeSummary.marksTotal, gradeSummary.marksAverage, gradeLetters.gradeLetter
FROM studentTable
INNER JOIN gradeSummary
ON studentTable.studentID = gradeSummary.studentID
INNER JOIN gradeLetters
ON dbo.ufn_marksAverage(studentTable.studentID)*100 BETWEEN gradeLetters.gradeMin AND gradeLetters.gradeMax
ORDER BY studentTable.lastName, studentTable.firstName





-- We can even recreate the original master table in a similar fashion --

SELECT studentTable.studentID, studentTable.firstName, studentTable.lastName,
marksTable.marksMark AS Midterm, marksTable.marksMark AS Final, marksTable.marksMark AS Assignment1, marksTable.marksMark AS Assignment2,
gradeSummary.marksTotal, gradeSummary.marksAverage, gradeLetters.gradeLetter
FROM studentTable
INNER JOIN gradeSummary
ON studentTable.studentID = gradeSummary.studentID
INNER JOIN gradeLetters
ON dbo.ufn_marksAverage(studentTable.studentID)*100 BETWEEN gradeLetters.gradeMin AND gradeLetters.gradeMax
INNER JOIN marksTable
ON studentTable.studentID = marksTable.studentID
AND CASE
WHEN marksTable.marksType = 'midterm'
THEN marksTable.marksMark


INNER JOIN marksTable
ON studentTable.studentID = marksTable.studentID
AND marksTable.marksType = 'final'


ORDER BY studentTable.lastName, studentTable.firstName

-- pivot stuff --

SELECT *
FROM
(SELECT studentID, marksType, marksMark
 FROM marksTable) AS SourceTable
PIVOT
(
 AVG(marksMark)
 FOR marksType IN (Final, Midterm, Assignment1, Assignment2)) 
 AS PivotTable
 ORDER BY studentID;

SELECT studentID, Final, Midterm, Assignment1, Assignment2
FROM
(SELECT studentID, marksType, marksMark
 FROM marksTable) AS SourceTable
PIVOT
(
 AVG(marksMark)
 FOR marksType IN (Final, Midterm, Assignment1, Assignment2)) 
 AS PivotTable
 ORDER BY studentID;
