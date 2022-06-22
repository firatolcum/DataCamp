
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






--3. WORK WITH LAG() AND LEAD()










--4. FINDING MAXIMUM LEVELS OF OVERLAP


