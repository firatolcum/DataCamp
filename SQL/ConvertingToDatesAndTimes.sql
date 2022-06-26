
----------------------------------CONVERTING TO DATES AND TIMES-------------------------------------

--1. BUILDING DATES FROM PARTS

--A. DATEFROMPARTS(year, month, day)
-- Takes integer values for year, month and day and returns a 'DATE' type.

--B. TIMEFROMPARTS(hour, minute, second, fraction, precision)
-- Takes integer values for hour, minute, second, fraction of a scond and precision(from 0 to 7) and returns 'TIME' data type.

--C. DATETIMEFROMPARTS(year, month, day, hour, minute, second, ms)
-- Goes down to 3-millisecond granularity.

--D. DATETIME2FROMPARTS(year, month, day, hour, minute, second, fraction, precision)
-- For more precision, we can build a 'DATETIME2' from parts using the 'DATETIME2FROMPARTS()' function.
-- It's inputs are the set combination of 'DATEFROMPARTS()' and 'DATETIMEFROMPARTS()'.

--E. SMALLDATETIMEFROMPARTS(year, month, day, hour, minute)

--F. DATETIMEOFFSETFROMPARTS(year, month, day, hour, minute, second, fraction, hour_offset, minute_offet, precision)
-- Takes the 'DATETIME2' fields and adds inputs for the hour and minute offsets from UTC time so you can specify the time zone as well as time.

--EXAMPLE 1--------------------------
SELECT
	DATETIMEFROMPARTS(1918, 11, 11, 05, 45, 17, 995) AS DT,
	DATETIME2FROMPARTS(1918, 11, 11, 05, 45, 17, 0, 0) AS DT20,
	DATETIME2FROMPARTS(1918, 11, 11, 05, 45, 17, 995, 3) AS DT23,
	DATETIME2FROMPARTS(1918, 11, 11, 05, 45, 17, 9951234, 7) AS DT27;


---EXAMPLE 2---------------------------------
SELECT 
	DATETIMEOFFSETFROMPARTS(2009, 8, 14, 21, 00, 00, 0, 5, 30, 0) AS IST,
	DATETIMEOFFSETFROMPARTS(2009, 8, 14, 21, 00, 00, 0, 5, 30, 0) AT TIME ZONE 'UTC' AS UTC;

--There are 3 things to keep in mind when working with the 'FROMPARTS()' series of functions:
------1. If any of your input values i NULL, the result will always be NULL.
------2. If any of your input values is invalid for the date part, you will receive an error message stating that arguments have values which are not valid.
------3. If you set the precision on 'DATETIME2FROMPARTS()' to a number is smaller than can hold the fraction part of your date, you will receive an error.


---EXAMPLE 3---------------------------------------------------
-- Create dates from component parts in the calendar table: calendar year, calendar month, and the day of the month.

SELECT TOP(10)
	DATEFROMPARTS(CalendarYear, CalendarMonth, [Day]) AS CalendarDate
FROM 
	CalendarTable
WHERE 
	CalendarYear = 2017
ORDER BY
	FiscalDayOfYear ASC;

---EXAMPLE 4---------------------------------------------------
--Create dates from the component parts of the calendar table. Use the calendar year, calendar month, and day of month.

SELECT TOP(10)
	CalendarQuarterName, 
	[MonthName], 
	CalendarDayOfYear
FROM
	CalendarTable
WHERE
	DATEFROMPARTS(CalendarYear, CalendarMonth, [Day]) >= '2018-06-01'
	AND
	[DayName] = 'Tuesday'
ORDER BY
	FiscalYear,
	FiscalDayOfYear;

--EXAMPLE 5---------------------------
--Neil Armstrong and Buzz Aldrin landed the Apollo 11 Lunar Module--nicknamed The Eagle--on the moon on July 20th, 1969 at 20:17 UTC. 
--They remained on the moon for approximately 21 1/2 hours, taking off on July 21st, 1969 at 18:54 UTC.
SELECT
	-- Mark the date and time the lunar module touched down
    -- Use 24-hour notation for hours, so e.g., 9 PM is 21
	DATETIME2FROMPARTS(1969, 7, 20, 20, 17, 00, 000, 0) AS TheEagleHasLanded,
	-- Mark the date and time the lunar module took back off
    -- Use 24-hour notation for hours, so e.g., 9 PM is 21
	DATETIMEFROMPARTS(1969, 7, 21, 18, 54, 00, 000) AS MoonDeparture;

------------------------------------------------------------------------------------------------------------------------------------------------
--2. TRANSLATING DATE STRINGS

--A. CAST()
	SELECT CAST('09/14/99' AS DATE) AS USDate;
	-- CAST() is fast and is the ANSI standart, so it makes sense to use this as a default.

--B.CONVERT()
	SELECT CONVERT(DATETIME2(3), 'April 4, 2019 11:52:29.998 PM') AS April4
	-- Because 'CONVERT()' is not an ANSI standart, it is probably better to use 'CAST()' instead of 'CONVERT()'for this type of conversion.

--C.PARSE()
	SELECT PARSE('25 Dezember 2015' AS DATE USING 'de-de') AS Weihnachten;
	-- The PARSE() function lets us translate locale-specific dares.
	-- It uses the .NET framework to perfomr string translation, which makes it a powerful function.

--D. The Cost of Parsing
	--Function  	Conversions Per Second
	--CONVERT()		251,997
	--CAST()		240,347
	--PARSE()		12,620

--E. Setting Language
	SET LANGUAGE 'FRENCH'
	DECLARE
		@FrenchDate NVARCHAR(30) = N'18 avril 2019',
		@FrenchNumberDate NVARCHAR(30) = N'18/4/2019';
	SELECT
		CAST(@FrenchDate AS DATETIME),
		CAST(@FrenchNumberDate AS DATETIME);
	-- You can use this command to change the language in your current session.
	-- This command changes the way SQL Server parses strings dor dates and displays error and warning messages.
	SET LANGUAGE 'English'

--EXAMPLE-1-------------------------------------------
--Review the data in the dbo.Dates table which has been pre-loaded for you. 
--Then use the CAST() function to convert these dates twice: once into a DATE type and once into a DATETIME2(7) type.

SELECT
	d.DateText AS String,
	-- Cast as DATE
	CAST(d.DateText AS DATE) AS StringAsDate,
	-- Cast as DATETIME2(7)
	CAST(d.DateText AS DATETIME2(7)) AS StringAsDateTime2
FROM dbo.Dates d;

--EXAMPLE 2-----------------------------------------------
--In this exercise, we will once again look at a table called dbo.Dates. 
--This time around, we will get dates in from our German office. 
--In order to handle German dates, we will need to use SET LANGUAGE to change the language in our current session to German.
--This affects date and time formats and system messages.

SET LANGUAGE 'GERMAN'

SELECT
	d.DateText AS String,
	-- Convert to DATE
	CONVERT(DATE, d.DateText) AS StringAsDate,
	-- Convert to DATETIME2(7)
	CONVERT(DATETIME2(7), d.DateText) AS StringAsDateTime2
FROM dbo.Dates d;

--EXAMPLE 3----------------------------------------------------------------------------------
--We will once again use the dbo.Dates table, this time parsing all of the dates as German using the de-de locale.
SELECT
	d.DateText AS String,
	-- Parse as DATE using German
	PARSE(d.DateText AS DATE USING 'de-de') AS StringAsDate,
	-- Parse as DATETIME2(7) using German
	PARSE(d.DateText AS DATETIME2(7) USING 'de-de') AS StringAsDateTime2
FROM dbo.Dates d;

----------------------------------------------------------------------------------------------------------------------
--3. WORKING WITH OFFSETS
--A. DATETIMEOFFSET()
	-- Made up of three key components: a date, a time, and a UTC offset.
		-- Date Part    Example
		-- Date			2019-04-10
		-- Time			12:59:02.3908505
		-- UTC Offet	-04:00

--B. SWITCHOFFSET()
	-- This function allows us to change the timezone of a given input string.
	-- If you pass in a DATETIME() or DATETIME2(), this function assumes you are in UTC.
	-- You can also pass in a DATETIMEOFSET() to move from one known time zoneto another.

DECLARE @SomeDate DATETIMEOFFSET = '2019-04-10 12:59:02.3908505 -04:00';
SELECT SWITCHOFFSET(@SomeDate, '-07:00') AS LATime;


--C. TODATETIMEOFFSET()
	-- This function takes two parameters: an input date and a time zone.From there, it generates a DATETIMEOFFSET().
	
DECLARE @SomeDate DATETIME2(3) = '2019-04-10 12:59:02.390';
SELECT TODATETIMEOFFSET(@SomeDate, '-04:00') AS EDT;

DECLARE @SomeDate DATETIME2(3) = '2016-09-04 02:28:29.681';
SELECT TODATETIMEOFFSET(DATEADD(HOUR, 7, @SomeDate), '+02:00') AS BonnTime;

--D. For SWITCHOFFSET() and TODATETIMEOFFET(), you need to know the offset number.
  -- If you don't know that, you can look it up using a Dynamic Management View called 'sys'.
  -- This returns time zones and current UTC offsets.

SELECT 
	tzi.name,
	tzi.current_utc_offset,
	tzi.is_currently_dst
FROM 
	sys.time_zone_info tzi
WHERE
	tzi.name LIKE '%Time Zone%';


--EXAMPLE 1----------------------------------

DECLARE
	@OlympicsUTC NVARCHAR(50) = N'2016-08-08 23:00:00';
SELECT
	-- Fill in the time zone for Brasilia, Brazil
	SWITCHOFFSET(@OlympicsUTC, '-03:00') AS BrasiliaTime,
	-- Fill in the time zone for Chicago, Illinois
	SWITCHOFFSET(@OlympicsUTC, '-05:00') AS ChicagoTime,
	-- Fill in the time zone for New Delhi, India
	SWITCHOFFSET(@OlympicsUTC, '+05:30') AS NewDelhiTime;


-----EXAMPLE-2-------------------------------------------------
DECLARE
	@OlympicsClosingUTC DATETIME2(0) = '2016-08-21 23:00:00';

SELECT
	-- Fill in 7 hours back and a '-07:00' offset
	TODATETIMEOFFSET(DATEADD(HOUR, -7, @OlympicsClosingUTC), '-07:00') AS PhoenixTime,
	-- Fill in 12 hours forward and a '+12:00' offset.
	TODATETIMEOFFSET(DATEADD(HOUR, 12, @OlympicsClosingUTC), '+12:00') AS TuvaluTime;


--4. HANDLING INVALID DATES----------------------------------------------------------------------------------------

--A. Error-safe Date Conversion Functions

--'Unsafe' Functions			Safe Functions
--CAST()						TRY_CAST()
--CONVERT()						TRY_CONVERT()
--PARSE()						TRY_PARSE()

--Using the 'unsafe' functions on the left will work just fine with good data,
--but if you have a single invalid date, these functions will return an error, causing your query to fail.
--By contrast the 'safe' functions on the right will handle invalid dates by converting them to NULL.


--EXAMPLES----------
--1. When everything goes right:
SELECT
	PARSE('01/08/2019' AS DATE USING 'en-us') AS January8US,
	PARSE('01/08/2019' AS DATE USING 'fr-fr') AS August1FR;

--2. When everything goes wrong:
SELECT
	PARSE('01/13/2019' AS DATE USING 'en-us') AS January13US,
	PARSE('01/13/2019' AS DATE USING 'fr-fr') AS Smarch1FR;

--3. Doing right when everything goes wrong:
SELECT
	TRY_PARSE('01/13/2019' AS DATE USING 'en-us') AS January13US,
	TRY_PARSE('01/13/2019' AS DATE USING 'fr-fr') AS Smarch1FR;

--EXTRA EXAMPLE-1-----------------------------------------

DECLARE
	@GoodDateINTL NVARCHAR(30) = '2019-03-01 18:23:27.920',
	@GoodDateDE NVARCHAR(30) = '13.4.2019',
	@GoodDateUS NVARCHAR(30) = '4/13/2019',
	@BadDate NVARCHAR(30) = N'SOME BAD DATE';
SELECT
	-- Fill in the correct data type based on our input
	TRY_CONVERT(DATETIME2(3), @GoodDateINTL) AS GoodDateINTL,
	-- Fill in the correct function
	TRY_CONVERT(DATE, @GoodDateDE) AS GoodDateDE,
	TRY_CONVERT(DATE, @GoodDateUS) AS GoodDateUS,
	-- Fill in the correct input parameter for BadDate
	TRY_CONVERT(DATETIME2(3), @BadDate) AS BadDate;

--EXTRA EXAMPLE-2-----------------------------------------

DECLARE
	@GoodDateINTL NVARCHAR(30) = '2019-03-01 18:23:27.920',
	@GoodDateDE NVARCHAR(30) = '13.4.2019',
	@GoodDateUS NVARCHAR(30) = '4/13/2019',
	@BadDate NVARCHAR(30) = N'SOME BAD DATE';
SELECT
	-- Fill in the correct data type based on our input
	TRY_CAST(@GoodDateINTL AS DATETIME2(3)) AS GoodDateINTL,
    -- Be sure to match these data types with the
    -- TRY_CONVERT() examples above!
	TRY_CAST(@GoodDateDE AS DATE) AS GoodDateDE,
	TRY_CAST(@GoodDateUS AS DATE) AS GoodDateUS,
	TRY_CAST(@BadDate AS DATETIME2(3)) AS BadDate;

--EXTRA EXAMPLE-3-----------------------------------------

DECLARE
	@GoodDateINTL NVARCHAR(30) = '2019-03-01 18:23:27.920',
	@GoodDateDE NVARCHAR(30) = '13.4.2019',
	@GoodDateUS NVARCHAR(30) = '4/13/2019',
	@BadDate NVARCHAR(30) = N'SOME BAD DATE';
SELECT
	TRY_CAST(@GoodDateINTL AS DATETIME2(3)) AS GoodDateINTL,
    -- Fill in the correct region based on our input
    -- Be sure to match these data types with the
    -- TRY_CAST() examples above!
	TRY_PARSE(@GoodDateDE AS DATE USING 'de-de') AS GoodDateDE,
	TRY_PARSE(@GoodDateUS AS DATE USING 'en-us') AS GoodDateUS,
    -- TRY_PARSE can't fix completely invalid dates
	TRY_PARSE(@BadDate AS DATETIME2(3) USING 'sk-sk') AS BadDate;

--EXTRA EXAMPLE-4-----------------------------------------

WITH EventDates AS
(
    SELECT
        -- Fill in the missing try-conversion function
        TRY_CONVERT(DATETIME2(3), it.EventDate) AT TIME ZONE it.TimeZone AS EventDateOffset,
        it.TimeZone
    FROM dbo.ImportedTimeTable it
        INNER JOIN sys.time_zone_info tzi
			ON it.TimeZone = tzi.name
)
SELECT
    -- Fill in the approppriate event date to convert
	CONVERT(NVARCHAR(50), ed.EventDateOffset) AS EventDateOffsetString,
	CONVERT(DATETIME2(0), ed.EventDateOffset) AS EventDateLocal,
	ed.TimeZone,
    -- Convert from a DATETIMEOFFSET to DATETIME at UTC
	CAST(ed.EventDateOffset AT TIME ZONE 'UTC' AS DATETIME2(0)) AS EventDateUTC,
    -- Convert from a DATETIMEOFFSET to DATETIME with time zone
	CAST(ed.EventDateOffset AT TIME ZONE 'US Eastern Standard Time'  AS DATETIME2(0)) AS EventDateUSEast
FROM EventDates ed;


--EXTRA EXAMPLE-5-----------------------------------------

SELECT *
FROM CalendarTable