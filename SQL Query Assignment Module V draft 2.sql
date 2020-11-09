USE Module_V;

SELECT * FROM masterModuleV
Order By studentID ASC;

-- Basic Checking for duplicate studentID which is a Candidate Key --

SELECT studentID, COUNT(studentID) occurences
FROM masterModuleV
GROUP BY studentID
HAVING COUNT(studentID) > 1;

-- Three duplicates found so lets check entire record to determine if truly duplicate --

SELECT * FROM masterModuleV
WHERE studentID = 35932 OR studentID = 47058 OR studentID = 64698
ORDER BY studentID;

-- They are not duplicates but rather appear to be improperly duplicated student ID --
-- Let's see if these particular students are present with other student ID numbers --

SELECT * FROM masterModuleV
WHERE
First_name = 'Lynde' AND Lastname = 'Ducker'
OR First_name = 'Tallulah' AND Lastname = 'Lynes'
OR First_name = 'Chen' AND Lastname = 'Dumbleton'
OR First_name = 'Jaye' AND Lastname = 'Margett'
OR First_name = 'Aurea' AND Lastname = 'Longea'
OR First_name = 'Claudian' AND Lastname = 'Burree'
ORDER BY studentID;

-- There are no duplicate students so there is an error in the studentID column --
-- Change three of the studentID values to unique numbers so that the studentID attribute can be use as a PK --

UPDATE masterModuleV
SET studentID = 99944
WHERE First_Name = 'Tallulah' and Lastname = 'Lynes';

UPDATE masterModuleV
SET studentID = 99966
WHERE First_Name = 'Jaye' and Lastname = 'Margett';

UPDATE masterModuleV
SET studentID = 99988
WHERE First_Name = 'Claudian' and Lastname = 'Burree';

-- This has successfully removed all duplicate records in the master table --

-- The master table remains in violation of 1NF since there are multiple columns storing similar data (ie two assignment columns etc) --
-- I will create an ERD in Excel to determine my table structure and then return to code the into reality --

-- Step One - I have determined the need for a Student Table, Exam Table, and Assignment Table --
-- The following code will create those three tables and populate them with data from the mast table --

CREATE TABLE studentTable
(
studentID INT NOT NULL PRIMARY KEY,
firstName VARCHAR(25) NOT NULL,
lastName VARCHAR(25)NOT NULL
);

CREATE TABLE marksTable
(
marksID INT IDENTITY(1000,1) NOT NULL PRIMARY KEY,
studentID INT NOT NULL FOREIGN KEY REFERENCES studentTable(studentID),
marksType VARCHAR(25),
marksMark FLOAT
);

INSERT INTO studentTable(studentID, firstName, lastName)
SELECT studentID, First_name, Lastname
FROM masterModuleV;

INSERT INTO marksTable(studentID, marksType, marksMark)
SELECT studentID, 'midterm', Midtermexam
FROM masterModuleV
UNION
SELECT studentID, 'final', Finalexam
FROM masterModuleV
UNION
SELECT studentID, '1', assignment1
FROM masterModuleV
UNION
SELECT studentID, '2', assignment2
FROM masterModuleV;


SELECT * FROM studentTable
ORDER BY studentID;

SELECT * FROM marksTable
ORDER BY marksID;

DROP TABLE studentTable;
DROP TABLE marksTable;

-- Student Table Exam Table and Assignment Table have been created and properly populated

-- The above tables are 3NF compliant, however, three columns remain in master table: totalpoints, studentaverage, grade --
-- Totalpoints and Studentaverage are both calculated from the combined marks so do not need to be entered into DB separately --
-- the Grade is assigned based on the average so it is a calculated value as well that could benefit from a grade table to store the letters --

-- This will create a small grade table to store the letter values for each grade range --

CREATE TABLE gradeLetters
(
gradeID INT NOT NULL IDENTITY PRIMARY KEY,
gradeLetter VARCHAR(2),
gradeMin FLOAT,
gradeMax FLOAT
);

-- Using standard Ontario grade ranges which seemed to be closest to what was in the original data --

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

SELECT * FROM gradeLetters;
DROP TABLE gradeLetters;

-- At this point, I do believe all four tables are 3NF compliant --
-- 1NF: I removed repeated groups and addressed redundant records --
-- 2NF: Any identified partial dependencies are computed columns and therefore not needed in the DB --
-- 3NF: The final grade was identified as a transient dependency since it is dependent on the average marks which are then dependent on the students --
-- NOTE: Partial and transient dependencies in this example were somewhat irrelevant because we are dealing with a single course rather than a bunch of courses --


-- I will now create a consolidated table summarizing each students results --
-- I need two user-defined functions to do the calculations that will define each of my computed columns in the combined results table --

-- Create user-defined function to calculate marksTotal and marksAverage from the exams and assignments tables --

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
SELECT @marksSum = SUM(marksMark) * 100
FROM marksTable
WHERE studentID = @student
RETURN @marksSum
END;

CREATE FUNCTION ufn_marksAverage (@student INT)
RETURNS DEC(2,2)
AS
BEGIN
DECLARE @marksAverage DEC(2,2)
SELECT @marksAverage = (dbo.ufn_marksSum(studentID)/100) / dbo.ufn_marksCount(studentID)
FROM marksTable
WHERE studentID = @student
RETURN @marksAverage
END;


SELECT dbo.ufn_marksCount (99966) AS testResult;
SELECT dbo.ufn_marksSum (99966) AS testResult;
SELECT dbo.ufn_marksAverage (99966) AS testResult;

DROP FUNCTION ufn_marksCount;
DROP FUNCTION ufn_marksSum;
DROP FUNCTION ufn_marksAverage;

-- Creating Grade Summary Table --

CREATE TABLE gradeSummary
(
studentID INT NOT NULL PRIMARY KEY,
);

INSERT INTO gradeSummary (studentID)
SELECT studentID
FROM masterModuleV;

ALTER TABLE gradeSummary
ADD
marksTotal AS dbo.ufn_marksSum(studentID),
marksAverage AS dbo.ufn_marksAverage(studentID);
marksGrade AS dbo.ufn_marksGrade(studentID);

SELECT * FROM gradeSummary;

DROP TABLE gradeSummary;

-- Creating JOIN table Summarizing students and final marks --

SELECT studentTable.studentID, studentTable.firstName, studentTable.lastName, gradeSummary.marksTotal, gradeSummary.marksAverage, gradeLetters.gradeLetter
FROM studentTable
INNER JOIN gradeSummary
ON studentTable.studentID = gradeSummary.studentID
INNER JOIN gradeLetters
ON dbo.ufn_marksAverage(studentTable.studentID)*100 BETWEEN gradeLetters.gradeMin AND gradeLetters.gradeMax
ORDER BY studentTable.lastName, studentTable.firstName