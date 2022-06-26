
----------------------------------AGGREGATING TIME SERIES DATA--------------------------------------------------------
--1. BASIC AGGREGATE FUNCTIONS
--A. Key Aggregation Funtions
   --Counts:			Other Aggregates:
   --COUNT()			SUM()
   --COUNT_BIG()		MIN()
   --COUNT(DISTINCT)	MAX()

--What counts with COUNT():
--Number of Rows:		Non-NULL Values:
--COUNT(*)				COUNT(d.Year)
--COUNT(1)
--COUNT(1/0)	

--Example-1-----------------

SELECT
	COUNT(DISTINCT CalendarYear) AS Years,
	COUNT(DISTINCT NULLIF(CalendarYear, 2010)) AS Y2
FROM CalendarTable

--Example-2-----------------

SELECT
	MAX(CASE WHEN IncidentTypeID = 1 THEN IncidentDate ELSE NULL END) AS I1,
	MAX(CASE WHEN IncidentTypeID = 2 THEN IncidentDate ELSE NULL END) AS I2
FROM IncidentRollupTable

--Example-3-----------------

SELECT 
	IncidentType,
	COUNT(1) AS NumberOfRows,
	SUM(NumberOfIncidents) AS TotalNumberOfIncidents,
	MIN(NumberOfIncidents) AS MinNumberOfIncidents,
	MAX(NumberOfIncidents) AS MaxNumberOfIncidents,
	MIN(IncidentDate) As MinIncidentDate,
	MAX(IncidentDate) AS MaxIncidentDate
FROM 
	IncidentRollupTable irt, IncidentTypeTable itt
WHERE 
	irt.IncidentTypeID = itt.IncidentTypeID 
	AND
	IncidentDate BETWEEN '2019-08-01' AND '2019-10-31'
GROUP BY IncidentType

--Example-4-----------------
--Return the count of distinct incident type IDs as NumberOfIncidentTypes
--Return the count of distinct incident dates as NumberOfDaysWithIncidents

SELECT
	COUNT(DISTINCT IncidentTypeID) AS NumberOfIncidentTypes,
	COUNT(DISTINCT IncidentDate) AS NumberOfDaysWithIncidents
FROM 
	IncidentRollupTable
WHERE
	IncidentDate BETWEEN '2019-08-01' AND '2019-10-31';

--Example-5-----------------
--In this scenario, management would like us to tell them, by incident type, how many "big-incident" days we have had versus "small-incident" days. 
--Management defines a big-incident day as having more than 5 occurrences of the same incident type on the same day,
--and a small-incident day has between 1 and 5.


SELECT 
	IncidentType,
	SUM(CASE WHEN NumberOfIncidents > 5 THEN 1 ELSE 0 END) AS NumberOfBigIncidentDays,
	SUM(CASE WHEN NumberOfIncidents <=5 THEN 1 ELSE 0 END) AS NumberOfSmallIncidentDays
FROM  
	IncidentRollupTable irt, IncidentTypeTable itt
WHERE 
	irt.IncidentTypeID = itt.IncidentTypeID 
	AND
	IncidentDate BETWEEN '2019-08-01' AND '2019-10-31'
GROUP BY
	IncidentType;


--2. STATISTICAL AGGREGATE FUNCTIONS

--AVG()		>>	Mean
--STDEV()	>>	Standart Deviation
--STDEVP()	>>	Population Standart Deviation
--VAR()		>>	Variance
--VARP()	>>	Population Variance

--SQL Server doesn't have a media function built-in.What we do have is the PERCENTILE_COUNT() function.
--The PERCENTILE_COUNT() function takes a parameter, which is the percentile you'd like.

---Example 1-------------------------------------- :
SELECT TOP(1)
	PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY SomeVal DESC) OVER () AS MedianIncidents
FROM LargeTable

---Example 2-------------------------------------- :
SELECT
	it.IncidentType,
	AVG(ir.NumberOfIncidents) AS MeanNumberOfIncidents,
	AVG(CAST(ir.NumberOfIncidents AS DECIMAL(4,2))) AS MeanNumberOfIncidents,
	STDEV(ir.NumberOfIncidents) AS NumberOfIncidentsStandardDeviation,
	VAR(ir.NumberOfIncidents) AS NumberOfIncidentsVariance,
	COUNT(1) AS NumberOfRows
FROM dbo.IncidentRollupTable ir
	INNER JOIN dbo.IncidentTypeTable it
		ON ir.IncidentTypeID = it.IncidentTypeID
	INNER JOIN dbo.CalendarTable c
		ON ir.IncidentDate = c.Date
WHERE
	c.CalendarQuarter = 2
	AND c.CalendarYear = 2020
GROUP BY
it.IncidentType;



---Example 3-------------------------------------- :

SELECT DISTINCT
	it.IncidentType,
	AVG(CAST(ir.NumberOfIncidents AS DECIMAL(4,2)))
	    OVER(PARTITION BY it.IncidentType) AS MeanNumberOfIncidents,
    --- Fill in the missing value
	PERCENTILE_CONT(0.5)
    	-- Inside our group, order by number of incidents DESC
    	WITHIN GROUP (ORDER BY ir.NumberOfIncidents DESC)
        -- Do this for each IncidentType value
        OVER (PARTITION BY it.IncidentType) AS MedianNumberOfIncidents,
	COUNT(1) OVER (PARTITION BY it.IncidentType) AS NumberOfRows
FROM dbo.IncidentRollupTable ir
	INNER JOIN dbo.IncidentTypeTable it
		ON ir.IncidentTypeID = it.IncidentTypeID
	INNER JOIN dbo.CalendarTable c
		ON ir.IncidentDate = c.Date
WHERE
	c.CalendarQuarter = 2
	AND c.CalendarYear = 2020;


--3. DOWNSAMPLING AND UPSAMPLING DATA

--Downsampling:										Upsampling:
--Aggregate data									Disaggregare data
--Can usually sum or count results					Need an allocation rule
--Provides a higher-level picture of the data		Provides artificial granularity
--Acceptable for most purposes						Acceptable for data generation, calculated averages

--Downsampling is much more common and much more acceptable in the business world than Upsampling.

--Example:
SELECT CAST('2019-08-11 06:21:16' AS DATE) 

--Further Downsampling Example:
SELECT DATEDIFF(HOUR, 0, '2019-08-11 06:21:16')
SELECT DATEADD(HOUR, DATEDIFF(HOUR, 0, '2019-08-11 06:21:16'), 0)

--Example 3-----------------------------------
SELECT
	-- Downsample to a daily grain
    -- Cast CustomerVisitStart as a date
	CAST(dsv.CustomerVisitStart AS DATE) AS Day,
	SUM(dsv.AmenityUseInMinutes) AS AmenityUseInMinutes,
	COUNT(1) AS NumberOfAttendees
FROM dbo.DaySpaVisitTable dsv
WHERE
	dsv.CustomerVisitStart >= '2020-06-11'
	AND dsv.CustomerVisitStart < '2020-06-23'
GROUP BY
	-- When we use aggregation functions like SUM or COUNT,
    -- we need to GROUP BY the non-aggregated columns
	CAST(dsv.CustomerVisitStart AS DATE)
ORDER BY
	Day;


--Example 4-----------------------------------
SELECT
	-- Downsample to a weekly grain
	DATEPART(WEEK, dsv.CustomerVisitStart) AS Week,
	SUM(dsv.AmenityUseInMinutes) AS AmenityUseInMinutes,
	-- Find the customer with the largest customer ID for that week
	MAX(dsv.CustomerID) AS HighestCustomerID,
	COUNT(1) AS NumberOfAttendees
FROM dbo.DaySpaVisitTable dsv
WHERE
	dsv.CustomerVisitStart >= '2020-01-01'
	AND dsv.CustomerVisitStart < '2021-01-01'
GROUP BY
	-- When we use aggregation functions like SUM or COUNT,
    -- we need to GROUP BY the non-aggregated columns
	DATEPART(WEEK, dsv.CustomerVisitStart)
ORDER BY
	Week;


--Example 5-----------------------------------

SELECT
	-- Determine the week of the calendar year
	c.CalendarWeekOfYear,
	-- Determine the earliest DATE in this group
    -- This is NOT the DayOfWeek column
	MIN(c.FirstDayOfWeek) AS FirstDateOfWeek,
	ISNULL(SUM(dsv.AmenityUseInMinutes), 0) AS AmenityUseInMinutes,
	ISNULL(MAX(dsv.CustomerID), 0) AS HighestCustomerID,
	COUNT(dsv.CustomerID) AS NumberOfAttendees
FROM dbo.CalendarTable c
	LEFT OUTER JOIN dbo.DaySpaVisitTable dsv
		-- Connect dbo.Calendar with dbo.DaySpaVisit
		-- To join on CustomerVisitStart, we need to turn 
        -- it into a DATE type
		ON c.Date = CAST(dsv.CustomerVisitStart AS DATE)
WHERE
	c.CalendarYear = 2020
GROUP BY
	-- When we use aggregation functions like SUM or COUNT,
    -- we need to GROUP BY the non-aggregated columns
	c.CalendarWeekOfYear
ORDER BY
	c.CalendarWeekOfYear;


--4. GROUPING BY ROLLUP, CUBE, AND GROUPUNG SETS
--A. HIERARCHICAL ROLLUPS WITH ROLLUP
	 --The WITH ROLLUP clause comes after GROUP BY and tells SQL Server to roll up the data.
	 --ROLLUP will take each combination of the first column followed by each matching value in the second column, and so on.
	 --ROLLUP is great for a summary of hierarchical data.

--B. CARTESIAN AGGREGATION WITH CUBE
	 --For cases where you want to see the full combination of all aggregations between columns, CUBE is at our disposal.
	 --The CUBE operator works just like ROLLUP, sliding in right after the GROUP BY clause.

--C. DEFINE GROUPING SETS WITH GROUPING SETS
	 --With GROUPING SETS, we control the levels of aggregation and can include any combination of aggregates we need.
	 --You can create any ROLLUP or CUBE operation with a series of GROUPING SETS.

--Example 1-----------------------------------
SELECT
	c.CalendarYear,
	c.CalendarQuarterName,
	c.CalendarMonth,
    -- Include the sum of incidents by day over each range
	SUM(ir.NumberOfIncidents) AS NumberOfIncidents
FROM dbo.IncidentRollupTable ir
	INNER JOIN dbo.CalendarTable c
		ON ir.IncidentDate = c.Date
WHERE
	ir.IncidentTypeID = 2
GROUP BY
	-- GROUP BY needs to include all non-aggregated columns
	c.CalendarYear,
	c.CalendarQuarterName,
	c.CalendarMonth
-- Fill in your grouping operator
WITH ROLLUP
ORDER BY
	c.CalendarYear,
	c.CalendarQuarterName,
	c.CalendarMonth;


--Example 2-----------------------------------

SELECT
	-- Use the ORDER BY clause as a guide for these columns
    -- Don't forget that comma after the third column if you
    -- copy from the ORDER BY clause!
	ir.IncidentTypeID,
	c.CalendarQuarterName,
	c.WeekOfMonth,
	SUM(ir.NumberOfIncidents) AS NumberOfIncidents
FROM dbo.IncidentRollupTable ir
	INNER JOIN dbo.CalendarTable c
		ON ir.IncidentDate = c.Date
WHERE
	ir.IncidentTypeID IN (3, 4)
GROUP BY
	-- GROUP BY should include all non-aggregated columns
	ir.IncidentTypeID,
	c.CalendarQuarterName,
	c.WeekOfMonth
-- Fill in your grouping operator
WITH CUBE
ORDER BY
	ir.IncidentTypeID,
	c.CalendarQuarterName,
	c.WeekOfMonth;

--Example 3-----------------------------------

SELECT
	c.CalendarYear,
	c.CalendarQuarterName,
	c.CalendarMonth,
	SUM(ir.NumberOfIncidents) AS NumberOfIncidents
FROM dbo.IncidentRollupTable ir
	INNER JOIN dbo.CalendarTable c
		ON ir.IncidentDate = c.Date
WHERE
	ir.IncidentTypeID = 2
-- Fill in your grouping operator here
GROUP BY GROUPING SETS
(
  	-- Group in hierarchical order:  calendar year,
    -- calendar quarter name, calendar month
	(CalendarYear, CalendarQuarterName, CalendarMonth),
  	-- Group by calendar year
	(CalendarYear),
    -- This remains blank; it gives us the grand total
	()
)
ORDER BY
	c.CalendarYear,
	c.CalendarQuarterName,
	c.CalendarMonth;


--Example 4-----------------------------------

SELECT
	c.CalendarYear,
	c.CalendarMonth,
	c.DayOfWeek,
	c.IsWeekend,
	SUM(ir.NumberOfIncidents) AS NumberOfIncidents
FROM dbo.IncidentRollupTable ir
	INNER JOIN dbo.CalendarTable c
		ON ir.IncidentDate = c.Date
GROUP BY GROUPING SETS
(
    -- Each non-aggregated column from above should appear once
  	-- Calendar year and month
	(CalendarYear, CalendarMonth),
  	-- Day of week
	(DayOfWeek),
  	-- Is weekend or not
	(IsWeekend),
    -- This remains empty; it gives us the grand total
	()
)
ORDER BY
	c.CalendarYear,
	c.CalendarMonth,
	c.DayOfWeek,
	c.IsWeekend;