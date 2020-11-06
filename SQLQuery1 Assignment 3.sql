USE Tuesday_Exercise;

SELECT * FROM dataAnalyst
SELECT * FROM parseTable;

-- parsing the Job_Location and Company_HQ  attributes into two columns each delimited on the comma --

SELECT
Job_ID as Parse_ID,
PARSENAME(REPLACE(Job_Location,', ','.'), 2) AS Job_City,
PARSENAME(REPLACE(Job_Location,', ','.'), 1) AS Job_State,
PARSENAME(REPLACE(Company_HQ,', ','.'), 2) AS HQ_City,
PARSENAME(REPLACE(Company_HQ,', ','.'), 1) AS HQ_State
INTO parseTable
FROM dataAnalyst

-- insert results into Master Table then drop old columns --

ALTER TABLE dataAnalyst
ADD Job_City VARCHAR(50), Job_State VARCHAR(50), HQ_City VARCHAR(50), HQ_State VARCHAR(50);


UPDATE dataAnalyst
SET Job_City = parseTable.Job_City, Job_State = parseTable.Job_State, HQ_City = parseTable.HQ_City, HQ_State = parseTable.HQ_State
FROM parseTable
WHERE Parse_ID = Job_ID;

ALTER TABLE dataAnalyst
DROP COLUMN Job_Location, Company_HQ;

DROP TABLE parseTable;

-- fix the erroneous capitalisation in Job Title column --

UPDATE dataAnalyst
SET Job_Title = 'Data Analyst'
WHERE Job_Title = 'DATA ANALYST' OR Job_Title = 'Data analyst';

-- this worked but said it affected 261 rows which is all of them --
-- apparently SQL Server is not consider case of strings --




