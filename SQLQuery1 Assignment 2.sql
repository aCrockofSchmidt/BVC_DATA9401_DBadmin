USE Tuesday_Exercise;

SELECT * FROM masterUFO
ORDER BY id;

SELECT * FROM incidentUFO
ORDER BY incidentTimestamp;

SELECT * FROM descriptionUFO;

DROP TABLE incidentUFO;
DROP TABLE descriptionUFO;

-- fixing NULL values in master table to make JOIN results clearer --

UPDATE masterUFO
SET shape = 'undisclosed'
WHERE shape IS NULL;

UPDATE masterUFO
SET state = 'undisclosed'
WHERE state IS NULL;

UPDATE masterUFO
SET duration = 'undisclosed'
WHERE duration IS NULL;

-- Parent Table --

CREATE TABLE incidentUFO
(
incidentID INT NOT NULL PRIMARY KEY,
incidentTimestamp DATETIME,
incidentCity VARCHAR(250),
incidentState VARCHAR(15)
);

INSERT INTO incidentUFO (incidentID, incidentTimestamp, incidentCity, incidentState)
SELECT id, occurred_date_time, city, state
FROM masterUFO;

-- Child Table --

CREATE TABLE descriptionUFO
(
descriptionID INT NOT NULL IDENTITY(10000,10) PRIMARY KEY,
incidentID INT FOREIGN KEY REFERENCES incidentUFO (incidentID),
descriptionShape VARCHAR(50),
descriptionSummary VARCHAR(500),
descriptionDuration VARCHAR(100)
);

INSERT INTO descriptionUFO (incidentID, descriptionShape, descriptionSummary, descriptionDuration)
SELECT id, shape, summary, duration
FROM masterUFO;

-- both tables are created and populated properly ~ YAY --


-- INNER JOIN --

-- this will take the City attribute from the incidentUFO table and join it with the Shape attribut from the descriptionUFO table--
-- where the incidentID is equivalent in both tables --

SELECT incidentUFO.incidentCity, descriptionUFO.descriptionShape
FROM incidentUFO
INNER JOIN descriptionUFO
ON incidentUFO.incidentID = descriptionUFO.incidentID;

-- LEFT OUTER JOIN --

SELECT incidentUFO.incidentCity, descriptionUFO.descriptionShape
FROM incidentUFO
LEFT OUTER JOIN descriptionUFO
ON incidentUFO.incidentID = descriptionUFO.incidentID;

-- both the INNER and OUTER JOINS are giving the same answer --
-- I believe this is a problem with the way the assignment is designed since my tables are just two halves of same table --
-- this is nothing missing or added to one or the other table and they have a solely 1 to 1 relationship between them --



-- I will delect rows to both my tables to make them smaller and then I will remove or add some fields to make them different --
-- This will hopefully make the assignment function better to see the differences between INNER and OUTER JOINS --

DELETE incidentUFO WHERE incidentID > 16000;
DELETE descriptionUFO WHERE incidentID > 16000;

-- IMPORTANT: I was forced to do the delete on child table first, then parent table --
-- This is referential integrity! --


-- In my child table I will now replace any incidentID field ending in a 7 with NULL --

UPDATE descriptionUFO
SET incidentID = NULL
WHERE RIGHT(incidentID,1) = 7; 

-- Holy smokes it worked NOTE: when putting a NULL into an INT field, do not use quotes --



-- INNER JOIN --
-- result should be 33 of 37 records in tables since the child table has 4 null values in incidentID

SELECT incidentUFO.incidentCity, descriptionUFO.descriptionShape, incidentUFO.incidentID, descriptionUFO.incidentID
FROM incidentUFO
INNER JOIN descriptionUFO
ON incidentUFO.incidentID = descriptionUFO.incidentID
ORDER BY incidentCity DESC;

-- LEFT OUTER JOIN --
-- result should be all 37 records since 33 records match and 4 NULL values in child table will appear in child column --

SELECT incidentUFO.incidentCity, descriptionUFO.descriptionShape, incidentUFO.incidentID, descriptionUFO.incidentID
FROM incidentUFO
LEFT OUTER JOIN descriptionUFO
ON incidentUFO.incidentID = descriptionUFO.incidentID
ORDER BY descriptionShape DESC;

-- RIGHT OUTER JOIN --
-- result should be all 37 records since 33 records match and 4 NULL values from child table will appear in parent table column --

SELECT incidentUFO.incidentCity, descriptionUFO.descriptionShape, incidentUFO.incidentID, descriptionUFO.incidentID
FROM incidentUFO
RIGHT OUTER JOIN descriptionUFO
ON incidentUFO.incidentID = descriptionUFO.incidentID
ORDER BY incidentCity DESC;

-- FULL OUTER JOIN --
-- result will be 41 records since 33 records match and 4 NULL values in child table will be included twice, once from parent column and once from child column --

SELECT incidentUFO.incidentCity, descriptionUFO.descriptionShape, incidentUFO.incidentID, descriptionUFO.incidentID
FROM incidentUFO
FULL OUTER JOIN descriptionUFO
ON incidentUFO.incidentID = descriptionUFO.incidentID
ORDER BY incidentCity DESC;



-- UNION --

SELECT incidentCITY
FROM incidentUFO
WHERE incidentSTATE = 'OK'
UNION
SELECT descriptionSHAPE
FROM descriptionUFO
WHERE descriptionShape = 'Oval';

-- INTERSECT --

SELECT incidentID
FROM incidentUFO
WHERE incidentID BETWEEN '15840' AND '15870'
INTERSECT
SELECT incidentID
FROM descriptionUFO
WHERE incidentID BETWEEN '15860' AND '15880';

-- EXCEPT --

SELECT incidentID
FROM incidentUFO
WHERE incidentID BETWEEN '15840' AND '15870'
EXCEPT
SELECT incidentID
FROM descriptionUFO
WHERE incidentID BETWEEN '15860' AND '15880';


-- I don't understand why EXCEPT doesn't return the non-matching results from Table 2 as well --

SELECT incidentID
FROM incidentUFO
EXCEPT
SELECT incidentID
FROM descriptionUFO

SELECT incidentID
FROM incidentUFO
INTERSECT
SELECT incidentID
FROM descriptionUFO

SELECT incidentCITY
FROM incidentUFO
UNION
SELECT descriptionSHAPE
FROM descriptionUFO
















-- this does not work --

CREATE TABLE incidentUFO
INSERT INTO incidentUFO
(
incidentID INT NOT NULL PRIMARY KEY,
incidentTimestamp DATETIME,
incidentCity VARCHAR(250),
incidentState VARCHAR(10)
)
SELECT id, occurred_date_time, city, state
FROM masterUFO;






