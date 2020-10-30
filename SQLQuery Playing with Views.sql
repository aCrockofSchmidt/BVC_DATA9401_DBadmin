-- Data was successfully imported from a CSV file downloaded from Kaggle and then manipulated in Excel to fix errors --

SELECT * FROM booksWIZARD

-- The table imported with datetime data type but only had date information so the resulting field had lots of zeros --
-- The following command changed the publication_date data type to DATE to remove the time related zeros --

ALTER TABLE booksWIZARD
ALTER COLUMN publication_date DATE;

-- it was successful --

-- I will now create a VIEW to show only book title, author, and average rating is greater than 4 --

CREATE VIEW booksHighlyRated AS
SELECT title, authors, average_rating
FROM booksWIZARD
WHERE average_rating > 4;

SELECT * FROM booksHighlyRated

-- it was successful on first try --

SELECT * FROM booksHighlyRated
ORDER BY average_rating;

-- the above worked but default order is ascending --

SELECT * FROM booksHighlyRated
ORDER BY average_rating DESC;

-- the above again worked and the VIEW table is now shown in descending order of rating --

-- I see some authors are shown as NOT A BOOK and I would like to delete those records --

DELETE booksHighlyRated
WHERE authors = 'NOT A BOOK';

-- awesome, that worked too --
-- but are those records still in the booksWIZARD table? --

SELECT * FROM booksWIZARD
ORDER BY average_rating DESC;

-- hmmm that showed the table and sorted it correctly but I'm not seeing the NOT A BOOK author field showing up --

SELECT * FROM booksWIZARD
WHERE authors = 'NOT A BOOK';

-- weird, so it found two instances but they have average_rating below 4 which would have been left out of my VIEW prior to removing NOT A BOOK records --
-- so the records I deleted in my VIEW are not showing up in the TABLE so something is amiss --

-- I am simply typing this to make my branch file different than my main file as I am unable to create a pull request when MAIN and BRANCH are identical --

SELECT * FROM booksWIZARD;

USE Tuesday_Exercise;

SELECT * FROM booksWIZARD;

TRUNCATE TABLE booksWIZARD;

DROP TABLE booksWIZARD;

-- I successfully truncated the table which removed all the records and then dropped the table entirely --
-- I was then able to recreate the full table from scratch using an import task --

SELECT * FROM booksHighlyRated
ORDER BY average_rating DESC;

DELETE FROM booksHighlyRated
WHERE authors = 'NOT A BOOK';

SELECT * FROM booksWIZARD
ORDER BY average_rating DESC;

SELECT * FROM booksWIZARD
WHERE authors = 'NOT A BOOK';

-- I tried this twice and YES, deleting a record from a VIEW deletes it from the base TABLE!!!! --
-- There appears to be confirmation of this online as well --



