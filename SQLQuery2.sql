CREATE TABLE camping_trips (
trip_number INT PRIMARY KEY,
location VARCHAR (100),
arrival DATE,
departure DATE,
campground VARCHAR (100)
);

SELECT * FROM camping_trips

INSERT INTO camping_trips (
trip_number,
arrival,
departure,
campground
)
VALUES (
1,
'20210524',
'20210527',
'Mt Kidd'
);

SELECT * FROM camping_trips

UPDATE camping_trips
SET location = 'Kananaskis'
WHERE trip_number = 1;

SELECT * FROM camping_trips

INSERT INTO camping_trips (trip_number, location, arrival, departure, campground)
VALUES (2, 'Cypress Hills', '20210630', '20210703', 'Old Baldy'),
(3, 'Gull Lake', '20210802', '20210805', 'Lakeview'),
(4, 'Banff', '20210901', '20210904', 'Two Jack Lake');

SELECT * FROM camping_trips

DELETE FROM camping_trips WHERE location = 'Gull Lake';

SELECT * FROM camping_trips

UPDATE camping_trips SET campground = 'Firerock' WHERE campground = 'Old Baldy';

INSERT INTO camping_trips (trip_number, location, campground)
VALUES (5, 'BC', 'Marble Canyon'), (6, 'BC', 'Redstreak');

ALTER TABLE camping_trips ALTER COLUMN arrival DATE NOT NULL;

UPDATE camping_trips 
SET arrival = '20210101'
WHERE arrival IS NULL;

UPDATE camping_trips 
SET departure = '20210101'
WHERE departure IS NULL;

ALTER TABLE camping_trips ALTER COLUMN arrival DATE NOT NULL;

INSERT INTO camping_trips (trip_number, location, campground) VALUES (7, 'Saskatchewan', 'Frenchman Valley');

INSERT INTO camping_trips (trip_number, location, arrival, departure, campground) VALUES (7,'Saskatchewan', '20210915', '20210918', 'Frenchman Valley');

UPDATE camping_trips
SET location = 'Kootenay NP'
WHERE location = 'BC';

UPDATE camping_trips
SET arrival = '20210815', departure = '20210819'
WHERE campground = 'Marble Canyon';

UPDATE camping_trips
SET arrival = '20210819', departure = '20210822'
WHERE campground = 'Redstreak';

INSERT INTO camping_trips
VALUEs (8, 'Saskatchewan', '2021-09-18', '2021-09-21', 'Battleford');