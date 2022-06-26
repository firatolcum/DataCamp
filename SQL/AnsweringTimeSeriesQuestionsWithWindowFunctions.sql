
----------------------------------ANSWERING TIME SERIES QUESTIONS WITH WINDOW FUNCTIONS--------------------------------------------------------
--1 USING AGGREGATION FUNCTIONS OVER WINDOWS
--A. Ranking Functions:
--a. ROW_NUMBER():
	 -- Unique, ascending integer value starting from 1.
--b. RANK():
	 --Ascending integer value starting from 1. Can have ties. Can skip numbers.
--c. DENSE_RANK():
	 --Ascending integer value starting from 1. Can have ties. Will not skip numbers.

-- All ranking functions require an OVER() clause with an ORDER BY clause inside it.

CREATE TABLE Scores(
Team VARCHAR(3),
RunsScored INT
)

INSERT INTO Scores
VALUES
('AZ',8),('AZ',7),('AZ',7),('FLA',6),('FLA',6),('FLA',3);

SELECT *
FROM Scores


--Calculating Row Numbers:
SELECT
	RunsScored,
	ROW_NUMBER() OVER(ORDER BY RunsScored DESC) AS row_num
FROM
	Scores


--Calculating Ranks and Dense Ranks:
SELECT
	RunsScored,
	RANK() OVER(ORDER BY RunsScored DESC) AS rank_,
	DENSE_RANK() OVER(ORDER BY RunsScored DESC) AS dense_rank_
FROM
	Scores


--Partitions:
/* In addition an ORDER BY clause the OVER() clause in a window function can accept a PARTITION BY clause
which splits up the window by some column or set of columns.*/
SELECT
	Team,
	RunsScored,
	ROW_NUMBER() OVER(PARTITION BY Team ORDER BY RunsScored DESC) AS row_num
FROM 
	Scores


--B. Aggregate Functions:
	 --Aggregate functions include functions like AVG(), COUNT(), MAX(), MIN() and SUM(), as well as others.

--Example 1-----------------------------
SELECT
	Team,
	RunsScored,
	MAX(RunsScored) OVER(PARTITION BY Team) AS MaxRunsScore
FROM 
	Scores

--Example 2-----------------------------
SELECT 
	Team,
	RunsScored,
	MAX(RunsScored) OVER() AS MaxRunsScore
FROM 
	Scores
ORDER BY RunsScored DESC;

--Example 3-----------------------------
SELECT 
	IncidentDate, 
	NumberOfIncidents,
	ROW_NUMBER() OVER(ORDER BY NumberOfIncidents DESC) AS RowNum,
	RANK() OVER(ORDER BY NumberOfIncidents DESC) AS rank_,
	DENSE_RANK() OVER(ORDER BY NumberOfIncidents DESC) AS DenseRank
FROM
	IncidentRollupTable
WHERE
	IncidentTypeID = 3 AND NumberOfIncidents >= 8

--Example 4-----------------------------
SELECT
	IncidentDate,
	NumberOfIncidents,
	SUM(NumberOfIncidents) OVER() AS SumOfIncidents,
	MIN(NumberOfIncidents) OVER() AS LowestNumberOfIncidents,
	MAX(NumberOfIncidents) OVER() AS HighestNumberOfIncidents,
	COUNT(NumberOfIncidents) OVER() AS CountOfIncidents
FROM
	IncidentRollupTable
WHERE 
	IncidentDate BETWEEN '2019-07-01' AND '2019-07-31' AND IncidentTypeID = 3;

--2. CALCULATING RUNNING TOTALS AND MOVING AVERAGES

DROP TABLE Scores

CREATE TABLE Scores(
Team VARCHAR(3),
Game INT,
RunsScored INT
)

INSERT INTO Scores
VALUES
('AZ', 1, 8),('AZ',2, 6),('AZ', 3, 3),('FLA', 1, 7),('FLA', 2, 7),('FLA',3, 6);

SELECT *
FROM Scores

--Running Totals
SELECT 
	*,
	SUM(RunsScored) OVER(PARTITION BY Team ORDER BY Game ASC RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS TotalRuns
FROM 
	Scores

--RANGE and ROWS

--RANGE											ROWS
--Specify a range of results					Specify number of rows to include
--Duplicates processed all at once				Duplicates processed a row at a time
-- Only supports UNBOUNDED and CURRENT ROW		Support UNBOUNDED, CURRENT ROW and number of rows

--Calculating Moving Averages
SELECT 
	*,
	AVG(RunsScored) OVER(PARTITION BY Team ORDER BY Game ASC ROWS BETWEEN 1 PRECEDING AND CURRENT ROW) AS AvgRuns
FROM
	Scores

--EXAMPLE 1------------------------------------
SELECT
	IncidentDate,
	IncidentTypeID,
	NumberOfIncidents,
	SUM(NumberOfIncidents) OVER(PARTITION BY IncidentTypeID ORDER BY IncidentDate) AS CumulativeNumOfIncidents
FROM
	IncidentRollupTable ir
INNER JOIN CalendarTable c
ON ir.IncidentDate = c.Date
WHERE
	C.CalendarYear = 2019 AND C.CalendarMonth = 7
	AND ir.IncidentTypeID IN (1,2)
ORDER BY
	ir.IncidentTypeID,
	ir.IncidentDate

--EXAMPLE 2-------------------------------------
/* Instead of looking at a running total from the beginning of time until now, 
management would like to see the average number of incidents over the past 7 days--that is, 
starting 6 days ago and ending on the current date. 
Because this is over a specified frame which changes over the course of our query, 
this is called a moving average. 
Note: SQL Server does not have the ability to look at ranges of time in window functions, 
	  so we will need to assume that there is one row per day and use the ROWS clause.*/

SELECT
	ir.IncidentDate,
	ir.IncidentTypeID,
	ir.NumberOfIncidents,
	AVG(ir.NumberOfIncidents) OVER(PARTITION BY ir.IncidentTypeID ORDER BY ir.IncidentDate ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS MeanNumberOfIncidents
FROM 
	IncidentRollupTable ir
INNER JOIN CalendarTable c
ON ir.IncidentDate = c.Date
WHERE
	C.CalendarYear = 2019 AND C.CalendarMonth IN (7, 8)
	AND ir.IncidentTypeID = 1
ORDER BY
	ir.IncidentTypeID,
	ir.IncidentDate
-- If we have gaps in the data, we can drive from the Calendar table and LEFT OUTER JOIN to IncidentRollup, filling in missing days with 0 values.


--3. WORK WITH LAG() AND LEAD()
--The LAG() and LEAD() functions give us the ability to link together past, present, and future in the same query.
--LAG() gives you a prior row in a window given a particular partition strategy and ordering.
--LEAD() gives you a next row in a window given a particular partition strategy and ordering.
--Both LAG() and LEAD() take an optional second paramater which represents the number of rows back to look.
--LAG() and LEAD() execute after the WHERE clause.


--EXAMPLE 1-------------------------------
SELECT
	CustomerID,
	MonthStartDate,
	NumberOfVisits,
	LAG(NumberOfVisits) OVER(PARTITION BY CustomerID ORDER BY MonthStartDate) AS Prior	
FROM
	DaySpaRollupTable

--EXAMPLE 2-------------------------------
SELECT
	CustomerID,
	MonthStartDate,
	NumberOfVisits,
	LEAD(NumberOfVisits) OVER(PARTITION BY CustomerID ORDER BY MonthStartDate) AS Next	
FROM
	DaySpaRollupTable

--EXAMPLE 3-------------------------------
SELECT
	CustomerID,
	MonthStartDate,
	NumberOfVisits,
	LAG(NumberOfVisits, 2) OVER(PARTITION BY CustomerID ORDER BY MonthStartDate) AS Prior2,
	LAG(NumberOfVisits, 1) OVER(PARTITION BY CustomerID ORDER BY MonthStartDate) AS Prior1	
FROM
	DaySpaRollupTable

--EXAMPLE 4-------------------------------
WITH T1 AS
(
SELECT
	CustomerID,
	MonthStartDate,
	NumberOfVisits,
	LAG(NumberOfVisits, 2) OVER(PARTITION BY CustomerID ORDER BY MonthStartDate) AS Prior
FROM
	DaySpaRollupTable
)
SELECT *
FROM T1
WHERE MonthStartDate > '2019-08-30'

--EXAMPLE 5-------------------------------
/*In this exercise, we want to compare the number of security incidents by day for incident types 1 and 2 during July of 2019, 
specifically the period starting on July 2nd and ending July 31st.*/
WITH T1 AS
(
SELECT
	i.IncidentDate,
	i.IncidentTypeID,
	NumberOfIncidents AS CurrentDayIncidents,
	LAG(NumberOfIncidents) OVER(PARTITION BY IncidentTypeID ORDER BY IncidentDate) AS PriorDayIncidents,
	LEAD(NumberOfIncidents) OVER(PARTITION BY IncidentTypeID ORDER BY IncidentDate) AS NextDayIncidents
FROM 
	IncidentRollupTable i
INNER JOIN CalendarTable c
ON i.IncidentDate = c.Date
)
SELECT *
FROM T1
WHERE IncidentDate BETWEEN '2019-07-02' AND '2019-07-31'
	  AND IncidentTypeID IN (1, 2)


--EXAMPLE 6 --------------------------------------------------
/*In this exercise, we want to compare the number of security incidents by day for incident types 1 and 2 during July of 2019, 
specifically the period starting on July 2nd and ending July 31st. 
Management would like to see a rolling four-day window by incident type to see if there are any significant trends, 
starting two days before and looking one day ahead. */

WITH T1 AS
(
SELECT
	i.IncidentDate,
	i.IncidentTypeID,
	NumberOfIncidents AS CurrentDayIncidents,
	LAG(NumberOfIncidents, 2) OVER(PARTITION BY IncidentTypeID ORDER BY IncidentDate) AS Trailing2Day,
	LAG(NumberOfIncidents, 1) OVER(PARTITION BY IncidentTypeID ORDER BY IncidentDate) AS Trailing1Day,
	LEAD(NumberOfIncidents, 1) OVER(PARTITION  BY IncidentTypeID ORDER BY IncidentDate) AS NextDay
FROM 
	IncidentRollupTable i
INNER JOIN CalendarTable c
ON i.IncidentDate = c.Date
)
SELECT *
FROM T1
WHERE IncidentDate BETWEEN '2019-07-02' AND '2019-07-31'
	  AND IncidentTypeID IN (1, 2)


--EXAMPLE 7 --------------------------------------------------
/* Something you might have noticed in the prior two exercises is that we don't always have incidents on every day of the week, 
so calling LAG() and LEAD() the "prior day" is a little misleading; it's really the "prior period." 
Someone in management noticed this as well and, at the end of July, wanted to know the number of days between incidents. 
To do this, we will calculate two values: the number of days since the prior incident and the number of days until the next incident.
Recall that DATEDIFF() gives the difference between two dates. We can combine this with LAG() and LEAD() to get our results.*/

SELECT 
	IncidentDate,
	IncidentTypeID,
	DATEDIFF(DAY, LAG(IncidentDate, 1) OVER(PARTITION BY IncidentTypeID ORDER BY IncidentDate), IncidentDate) AS DaysSinceLastIncident,
	DATEDIFF(DAY, IncidentDate, LEAD(IncidentDate, 1) OVER(PARTITION BY IncidentTypeID ORDER BY IncidentDate)) AS DaysUntilNextIncident
FROM IncidentRollupTable
WHERE IncidentDate BETWEEN '2019-07-02' AND '2019-07-31' AND IncidentTypeID IN (1, 2)
ORDER BY IncidentTypeID, IncidentDate


