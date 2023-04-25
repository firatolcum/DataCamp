
----------------------------------WORKING WITH DATES AND TIMES--------------------------------------------------------

----------------1. FORMATTING DATES FOR REPORTING-------------------------------------------------------

DECLARE @SomeTime DATETIME2(7) = '2018-06-14 16:29:36.2248991'
SELECT 
	DATEADD(DAY,DATEDIFF(DAY, 0, @SomeTime),0)

-----CAST() FUNCTION------
-- Useful for converting one data type to another data type, including date types.
-- No control over formatting.

DECLARE
	@SomeDate DATETIME2(3) = '1991-06-04 08:00:09',
	@SomeString NVARCHAR(30) = '1991-06-04 08:00:09',
	@OldDateTime DATETIME = '1991-06-04 08:00:09';

SELECT
	CAST(@SomeDate AS NVARCHAR(30)) AS DateToString,
	CAST(@SomeString AS DATETIME2(3)) AS StringToDate,
	CAST(@OldDateTime AS NVARCHAR(30)) AS OldDateToString


------------CONVERT() FUNCTION-------------------------
-- Useful for converting one data type to another data type, including date types.
-- Specific to T-SQL
-- CONVERT() function takes three parameters: a data type, an input and an optional style.

DECLARE
	@SomeDate DATETIME2(3) = '1793-02-21 11:13:19.033';
SELECT
	CONVERT(NVARCHAR(30), @SomeDate, 0) AS DefaultForm,
	CONVERT(NVARCHAR(30), @SomeDate, 1) AS US_mdy,
	CONVERT(NVARCHAR(30), @SomeDate, 101) AS US_mdyyyy,
	CONVERT(NVARCHAR(30), @SomeDate, 120) AS ODBC_sec,
	CONVERT(NVARCHAR(30), @SomeDate, 112) AS ISO_standart



-----FORMAT() FUNCTION----
-- Useful for formatting a date or number in a particular way for reporting.
-- Much more flexibility over formatting from dates to strings than either CAST() or CONVERT().
-- Can be slower as you process more rows.
-- FORMAT() takes three parameters: an input value, a format code, and an optional culture.

DECLARE
	@SomeDate DATETIME2(3) = '1793-02-21 11:13:19.033';
SELECT
	FORMAT(@SomeDate, 'd', 'en-US') AS US_d,
	FORMAT(@SomeDate, 'd', 'de-DE') AS DE_d,
	FORMAT(@SomeDate, 'D', 'de-DE') AS DE_D,
	FORMAT(@SomeDate, 'yyy-MM-dd') AS yMd;



--EXAMPLE-1----------------------------------------------------------------

DECLARE
	@CubsWinWorldSeries DATETIME2(3) = '2016-11-03 00:30:29.245',
	@OlderDateType DATETIME = '2016-11-03 00:30:29.245';
SELECT
	CAST(@CubsWinWorldSeries AS DATE) AS CubsWinDateForm,
	CAST(@CubsWinWorldSeries AS NVARCHAR(30)) AS CubsWinStringForm,
	CAST(@OlderDateType AS DATE) AS OlderDateForm,
	CAST(@OlderDateType AS NVARCHAR(30)) AS OlderStringForm;

---EXAMPLE-2---------------------------------------------------------------------------

DECLARE
	@CubsWinWorldSeries DATETIME2(3) = '2016-11-03 00:30:29.245';

SELECT
	CAST(CAST(@CubsWinWorldSeries AS DATE) AS NVARCHAR(30)) AS DateStringForm;

---EXAMPLE-3-------------------------------------------------------------------------
DECLARE
	@CubsWinWorldSeries DATETIME2(3) = '2016-11-03 00:30:29.245';
SELECT
	CONVERT(DATE, @CubsWinWorldSeries) AS CubsWinDateForm,
	CONVERT(NVARCHAR(30), @CubsWinWorldSeries) AS CubsWinStringForm;

---EXAMPLE-4----------------------------------------------------------------------

DECLARE
	@CubsWinWorldSeries DATETIME2(3) = '2016-11-03 00:30:29.245';
SELECT
	CONVERT(NVARCHAR(30), @CubsWinWorldSeries, 0) AS DefaultForm,
	CONVERT(NVARCHAR(30), @CubsWinWorldSeries, 3) AS UK_dmy,
	CONVERT(NVARCHAR(30), @CubsWinWorldSeries, 1) AS US_mdy,
	CONVERT(NVARCHAR(30), @CubsWinWorldSeries, 103) AS UK_dmyyyy,
	CONVERT(NVARCHAR(30), @CubsWinWorldSeries, 101) AS US_mdyyyy;

---EXAMPLE 5------------------------------------------------------------------

DECLARE
	@Python3ReleaseDate DATETIME2(3) = '2008-12-03 19:45:00.033';
SELECT
	-- Fill in the function call and format parameter
	FORMAT(@Python3ReleaseDate, 'd', 'en-US') AS US_d,
	FORMAT(@Python3ReleaseDate, 'd', 'de-DE') AS DE_d,
	-- Fill in the locale for Japan
	FORMAT(@Python3ReleaseDate, 'd', 'jp-JP') AS JP_d,
	FORMAT(@Python3ReleaseDate, 'd', 'zh-cn') AS CN_d;

---EXAMPLE-6-----------------------------------------------------------------------

DECLARE
	@Python3ReleaseDate DATETIME2(3) = '2008-12-03 19:45:00.033';
SELECT
	-- Fill in the format parameter
	FORMAT(@Python3ReleaseDate, 'D', 'en-US') AS US_D,
	FORMAT(@Python3ReleaseDate, 'D', 'de-DE') AS DE_D,
	-- Fill in the locale for Indonesia
	FORMAT(@Python3ReleaseDate, 'D', 'id-ID') AS ID_D,
	FORMAT(@Python3ReleaseDate, 'D', 'zh-cn') AS CN_D;

---EXAMPLE-7-----------------------------------------------------------------

DECLARE
	@Python3ReleaseDate DATETIME2(3) = '2008-12-03 19:45:00.033';
SELECT
	-- 20081203
	FORMAT(@Python3ReleaseDate, 'yyyyMMdd') AS F1,
	-- 2008-12-03
	FORMAT(@Python3ReleaseDate, 'yyyy-MM-dd') AS F2,
	-- Dec 03+2008 (the + is just a "+" character)
	FORMAT(@Python3ReleaseDate, 'MMM dd+yyyy') AS F3,
	-- 12 08 03 (month, two-digit year, day)
	FORMAT(@Python3ReleaseDate, 'MM yy dd') AS F4,
	-- 03 07:45 2008.00
    -- (day hour:minute year.second)
	FORMAT(@Python3ReleaseDate, 'dd hh:mm yyyy.ss') AS F5;


-------2. WORKING WITH CALENDER TABLES-------------------------------------------------

--A calender table is a table which stores date information for easy retrieval.
--Contents of a calender table:
	--1. General Columns:
		--A. Date
		--B. Day Name
		--C. Is Weekend
	--2. Calendar Year
		--A. Calendar Month
		--B. Calendar Quarter
		--C. Calendar Year
	--3. Fiscal Year
		--A. Fiscal Week of Year
		--B. Fiscal Quarter
		--C. Fiscal First Day of Year
	--4. Specialized Columns
		--A. Holiday Name
		--B. Lunar Details
		--C. ISO Week of Year

-- Building a calendar table:
CREATE TABLE  dbo.Calendar
(
	DateKey INT NOT NULL,
	[Date] DATE NOT NULL,
	[Day] TINYINT NOT NULL,
	[DayOfWeek] TINYINT NOT NULL,
	[DayName] VARCHAR(10) NOT NULL,
)



--A quick note on APPLY() Function:
----APPLY() executes a function for each row in a result set.

--EXAMPLE-1-----------------------------------------------------------

-- Find Tuesdays in December for calendar years 2008-2010
SELECT
	c.Date
FROM dbo.Calendar c
WHERE
	c.MonthName = 'December'
	AND c.DayName = 'Tuesday'
	AND c.CalendarYear BETWEEN 2008 AND 2010
ORDER BY
	c.Date;

---EXAMPLE-2-------------------------------------------------------------

-- Find fiscal week 29 of fiscal year 2019
SELECT
	c.Date
FROM dbo.Calendar c
WHERE
    -- Instead of month, use the fiscal week
	c.FiscalWeekOfYear = 29
    -- Instead of calendar year, use fiscal year
	AND c.FiscalYear = 2019
ORDER BY
	c.Date ASC;

