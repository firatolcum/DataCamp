
----------------------------------FUNCTIONS FOR MANIPULATING DATA IN SQL SERVER--------------------------------------------------------

--1. CHOOSING THE APPROPRIATE DATA TYPE--------------------------------------------------------
--Categories of Data Types:
  --A. Exact numerics
	--> Stores the literal representation of the number's value.
	--A.1 Whole Numbers:
		 --Smallint >> 2 Bytes
		 --tinyint  >> 1 Byte
		 --int		>> 4 Bytes
		 --bigint	>> 8 Bytes
	--A.2 Decimal Numbers:
		 --Numeric, decimal, money, smallmoney
		 --Precision      --Storage
		 --1-9				5 Bytes	
		 --10-19			9 Bytes
		 --20-28			13 Bytes
		 --29-38			17 Bytes
		 --Precision is an integer representing the total number of digits a number can have.

  --B. Approximate numerics
	   --Float
	   --Real
	   --> Float and Real store approximate numeric values.
	   --> You should use these types carefully and avýid using them in WHERE clause with an equality operator.
	   
  --C. Date and time
	   --Data type			--Format						--Accuracy
	   --time				  hh:mm:ss[.nnnnnnn]			  100 nanoseconds
	   --date				  YYY-MM-DD						  1 day
	   --smalldatetime		  YYYY-MM-DD hh:mm:ss			  1 minute
	   --datetime			  YYY-MM-DD hh:mm:ss[.nnn]		  0.00333 second
	   --datetime2			  YYY-MM-DD hh:mm:ss[.nnnnnnn]	  100 nanoseconds

  --D. Character strings
	   --> Charcter data types store character strings(ASCII).
	   --> ASCII types are used to store strings with English characters.
	   --Char
	   --Varchar
	   --Text

  --E. Unicode character strings
	   --> Unicode data types are used for storing Unicode data(non-ASCII).
	   --> With Unicode types, you can store characters from all languages around the world(like Japanese).
	   --Nchar
	   --Nvarchar
	   --Ntext
 
  --F. Other data types
	   --Binary, image, cursor, rowversion, uniqueidentifier, xml, spatial geometry / geography types


--Example-1
--Add a new column with the correct data type, for storing the last date a person voted ("2018-01-17").
ALTER TABLE voters
ADD last_vote_date DATE;

--Add a new column called last_vote_time, to keep track of the most recent time when a person voted ("16:55:00").
ALTER TABLE voters
ADD last_vote_time TIME;

--Add a new column,last_login, storing the most recent time a person accessed the application ("2019-02-02 13:44:00").
ALTER TABLE voters
ADD last_login DATETIME2;


--NOTE-1 : 
	-- Keep in mind: For comparing two values, they need to be of the same type. Otherwise:
		--1. SQL Server converts from one type to another(IMPLICIT). Performed automatically, behind the scenes.
		--2. The developer explicitly converts the data(EXPLICIT). Performed with the functions CAST() and CONVERT().
	-- Data Type Precedence:
		--1. User-defined data types(highest)
		--2. datetime
		--3. date
		--4. float
		--5. decimal
		--6. int
		--7. bit
		--8. nvarchar
		--9. varchar
		--10 binary(lowest)

--Implicit Conversion Example-1 :
SELECT 
	company,
	bean_type,
	cocoa_percent
FROM
	ratings
WHERE
	cocoa_percent > '0.5'

--Implicit Conversion Example-2 :

SELECT 
	company,
	bean_type,
	cocoa_percent
FROM
	ratings
WHERE
	cocoa_percent > GETDATE()


--Explicit Conversion Example-1 :

SELECT 
	CAST(3.14 AS INT) AS DECIMAL_TO_INT,
	CAST('3.14' AS DECIMAL(3, 2)) AS STRING_TO_DECIMAL,
	CAST(GETDATE() AS NVARCHAR(20)) AS DATE_TO_STRING,
	CAST(GETDATE() AS FLOAT) AS DATE_TO_FLOAT


SELECT 
	CONVERT(INT, 3.14) AS DECIMAL_TO_INT,
	CONVERT(DECIMAL(3,2), '3.14') STRING_TO_DECIMAL,
	CONVERT(NVARCHAR(20), GETDATE(), 104) AS DATE_TO_STRING,--The number 104 is a code for date format.
	CONVERT(FLOAT, GETDATE()) AS DATE_TO_FLOAT

--CAST() vs. CONVERT():
  --1. CAST() comes from the SQL standart and CONVERT() is SQL Server specific.
  --2. CAST() is available in most database products.
  --3. CONVERT() performs slightly better in SQL Server.


--Explicit Conversion Example-2 :
SELECT 
	-- Transform the year part from the birthdate to a string
	first_name + ' ' + last_name + ' was born in ' + CAST(YEAR(birthdate) AS nvarchar) + '.' 
FROM voters;


--Explicit Conversion Example-3 :
SELECT 
	-- Transform to int the division of total_votes to 5.5
	CAST(total_votes / 5.5 AS INT) AS DividedVotes
FROM voters;


--Explicit Conversion Example-4 :
SELECT 
	first_name,
	last_name,
	total_votes
FROM voters
-- Transform the total_votes to char of length 10
WHERE CAST(total_votes AS VARCHAR(10)) LIKE '5%';


--Explicit Conversion Example-5 :
SELECT 
	email,
    -- Convert birthdate to varchar show it like: "Mon dd,yyyy" 
    CONVERT(VARCHAR, birthdate, 107) AS birthdate
FROM voters;


--Explicit Conversion Example-6 :
SELECT 
	company,
    bean_origin,
    -- Convert the rating column to an integer
    CONVERT(INT,rating) AS rating
FROM ratings;


--Explicit Conversion Example-7 :
SELECT 
	company,
    bean_origin,
    rating
FROM ratings
-- Convert the rating to an integer before comparison
WHERE CONVERT(INT, rating) = 3;


--Explicit Conversion Example-8 :
SELECT 
	first_name,
    last_name,
	-- Convert birthdate to varchar(10) and show it as yy/mm/dd. This format corresponds to value 11 of the "style" parameter.
	CONVERT(VARCHAR(10), birthdate, 11) AS birthdate,
    gender,
    country
FROM voters
WHERE country = 'Belgium' 
    -- Select only the female voters
	AND gender = 'F'
    -- Select only people who voted more than 20 times  
    AND total_votes > 20;


--Explicit Conversion Example-9 :
SELECT
	first_name,
    last_name,
	-- Convert birthdate to varchar(10) to show it as yy/mm/dd
	CONVERT(varchar(10), birthdate, 11) AS birthdate,
    gender,
    country,
    -- Convert the total_votes number to nvarchar
    'Voted ' + CAST(total_votes AS NVARCHAR(10)) + ' times.' AS comments
FROM voters
WHERE country = 'Belgium'
    -- Select only the female voters
	AND gender = 'F'
    -- Select only people who voted more than 20 times
    AND total_votes > 20;



--2. MANIPULATING TIME--------------------------------------------------------
     --Common mistakes when working with dates and time:
	   --> Inconsistent date time formats or patterns.
	   --> Arithmetic operations.
	   --> Issues with time zones.

	 --Time zones in SQL Server:
	   --> Local time zone
	   --> UTC time zone(Universal Time Coordinate)

	 --Functions that return the date and time of the operating system:
	   --1. Higher-precision functions:
			--SYSDATETIME(): Returns the computer's date and time, without timezone information.
			--SYSUTCDATETIME(): Returns the computer's date and time as UTC.
			--SYSDATETIMEOFFSET(): Returns the computer's date and time, together with timezone offset.

	   --2. Lower-precision functions:
			--GETDATE(): Returns the current date.
			--GETUTCDATE(): Returns the current date as UTC.
			--CURRENT_TIMESTAMP: Equivalent with GETDATE(), the only difference CURRENT_TIMESTAMP is called without the parantheses.
	
	 --Functions returning date and time parts:
	   -- YEAR(): Returns the year from the specified date.
	   -- MONTH(): Returns the month from the specified date.
	   -- DAY(): Returns the day part from a given date.
	   -- DATENAME(): Returns a character string representing the specified date part of the given date.
	   -- DATEPART(): This works in the same way as DATENAME(), the difference being that the returned values are all integers.
	   -- DATEFROMPARTS(): Receives 3 parameters(year, month, day) and the function generates a date.

	 --Performing arithmetic operations on dates:
	   --Operations using arithmetic operators(+, -):
		 --> Performing arithmetic opreations directly on two dates or between a date and a number is possible in SQL Server.
	   --DATEADD(): With DATEADD(), you add a date part to a date and the result wil be a new date.
	   --DATEDIFF(): With DATEADD(), you can find the difference in time units between two dates.

	 --Validating if an expression is a date:
	   --ISDATE(): Determines whether an expression is a valid date data type.Accepts one parameter.
		 --ISDATE() expression    --Return type
		 --date, time, datetime	    1
		 --datetime2				0
		 --other type				0
	 --There are functions that can impact the output of ISDATE().
	   --SET DATEFORMAT {format}
			--> Set the order of the date parts for interpretig strings as dates.
			--> Valid formats: mdy, dmy, ymd, ydm, myd, dym.
	   --SET LANGUAGE {language}
			--> Sets the language for the session.
			--> Implicitly sets the setting of SET DATEFORMAT.
			--> Valid languages: English, Italian, Spanish, etc.


--High-precision functions example:
SELECT 
	SYSDATETIME() AS [SYSDATETIME],
	SYSDATETIMEOFFSET() AS [SYSDATETIMEOFFSET],
	SYSUTCDATETIME() AS [SYSUTCDATETIME]


--Low-precision functions example:
SELECT
	CURRENT_TIMESTAMP AS [CURRENT_TIMESTAMP],
	GETUTCDATE() AS [GETUTCDATE]

--Retrieving only the date:
SELECT
	CONVERT(DATE, SYSDATETIME()) AS [SYSDATETIME],
	CONVERT(DATE, SYSDATETIMEOFFSET()) AS [SYSDATETIMEOFFSET],
	CONVERT(DATE, SYSUTCDATETIME()) AS [SYSUTCDATETIME],
	CONVERT(DATE, CURRENT_TIMESTAMP) AS [CURRENT_TIMESTAMP],
	CONVERT(DATE, GETDATE()) AS [GETDATE],
	CONVERT(DATE, GETUTCDATE()) AS [GETUTCDATE]

--Retrieving only the time:
SELECT
	CONVERT(TIME, SYSDATETIME()) AS [SYSDATETIME],
	CONVERT(TIME, SYSDATETIMEOFFSET()) AS [SYSDATETIMEOFFSET],
	CONVERT(TIME, SYSUTCDATETIME()) AS [SYSUTCDATETIME],
	CONVERT(TIME, CURRENT_TIMESTAMP) AS [CURRENT_TIMESTAMP],
	CONVERT(TIME, GETDATE()) AS [GETDATE],
	CONVERT(TIME, GETUTCDATE()) AS [GETUTCDATE]

--Example-3------------------------
--Select the current date in UTC time (Universal Time Coordinate) using two different functions.
SELECT
	SYSUTCDATETIME() AS UTC_HighPrecision,
	GETUTCDATE() AS UTC_LowPrecision


--Example-4------------------------
--Select the local system's date, including the timezone information.
SELECT SYSDATETIMEOFFSET() AS Timezone


--Example-4------------------------
--Use two functions to query the system's local date, without timezone information. Show the dates in different formats.
SELECT
	CONVERT(VARCHAR(24), SYSDATETIME(), 107) AS HighPrecision,
	CONVERT(VARCHAR(24), CURRENT_TIMESTAMP, 102) AS LowPrecision


--Example-4------------------------
--Use two functions to retrieve the current time, in Universal Time Coordinate.
SELECT
	CAST(SYSUTCDATETIME() AS TIME) AS HighPrecision,
	CAST(GETUTCDATE() AS TIME) AS LowPrecision


--Example-5------------------------
SELECT	
	first_name,
	first_vote_date,
	YEAR(first_vote_date) AS first_vote_year,
	MONTH(first_vote_date) AS first_vote_month,
	DAY(first_vote_date) AS first_vote_day
FROM
	voters


--Example-6------------------------
DECLARE @date datetime = '2019-03-24'
SELECT
	YEAR(@date) AS year_,
	DATENAME(YEAR, @date) AS year_name,
	MONTH(@date) AS month_,
	DATENAME(MONTH, @date) AS month_name,
	DAY(@date) AS day_,
	DATENAME(DAY, @date) AS day_name,
	DATENAME(WEEKDAY, @date) AS weekday_


--Example-7------------------------
DECLARE @date datetime = '2019-03-24'
SELECT
	DATEPART(YEAR, @date) AS year_,
	DATENAME(YEAR, @date) AS year_name,
	DATEPART(MONTH, @date) AS month_,
	DATENAME(MONTH, @date) AS month_name


--Example-8------------------------
SELECT DATEFROMPARTS(2019, 3, 12) AS new_date


--Example-9------------------------
SELECT 
	YEAR('2019-03-05') AS date_year,
	MONTH('2019-03-05') AS date_month,
	DAY('2019-03-05') as date_day,
	DATEFROMPARTS(YEAR('2019-03-05'), MONTH('2019-03-05'), DAY('2019-03-05')) AS reconstructed_date


--Example-10------------------------
--Select information from the voters table, including the name of the month when they first voted.
SELECT 
	first_name,
	last_name,
	first_vote_date,
	DATENAME(MONTH, first_vote_date) AS first_vote_month
FROM voters;


--Example-11------------------------
--Select information from the voters table, including the day of the year when they first voted.
SELECT 
	first_name,
	last_name,
	first_vote_date,
	DATENAME(DAYOFYEAR, first_vote_date) AS first_vote_dayofyear
FROM voters;


--Example-12------------------------
--Select information from the voters table, including the day of the week when they first voted.
SELECT 
	first_name,
	last_name,
	first_vote_date,
	DATENAME(WEEKDAY,first_vote_date) AS first_vote_dayofweek
FROM voters;


--Example-13------------------------
SELECT 
	first_name,
	last_name,
   	-- Extract the month number of the first vote
	DATEPART(MONTH,first_vote_date) AS first_vote_month1,
	-- Extract the month name of the first vote
    DATENAME(MONTH,first_vote_date) AS first_vote_month2,
	-- Extract the weekday number of the first vote
	DATEPART(WEEKDAY,first_vote_date) AS first_vote_weekday1,
    -- Extract the weekday name of the first vote
	DATENAME(WEEKDAY,first_vote_date) AS first_vote_weekday2
FROM voters;


--Example-14------------------------
SELECT 
	first_name,
	last_name,
    -- Select the year of the first vote
   	YEAR(first_vote_date) AS first_vote_year, 
    -- Select the month of the first vote
	MONTH(first_vote_date) AS first_vote_month,
    -- Create a date as the start of the month of the first vote
	DATEFROMPARTS(YEAR(first_vote_date), MONTH(first_vote_date), 1) AS first_vote_starting_month
FROM voters;


--Example-15------------------------
DECLARE @date1 datetime = '2019-01-01';
DECLARE @date2 datetime = '2019-01-01';
SELECT
	@date2 + 1 AS add_one,                              --In SQL Server, the date is first converted to an integer
	@date2 - 1 AS subtract_one,--Unexpected result		--and then it's being added to the initial date as an increase in number of days.
	@date2 + @date1 AS add_dates,--Unexpected result
	@date2 - @date1 AS subtract_date--Unexpected result


--Example-15------------------------
SELECT 
	first_name,
	birthdate,
	DATEADD(YEAR, 5, birthdate) AS fifth_birthday,
	DATEADD(YEAR, -5, birthdate) AS subtract_5years,
	DATEADD(DAY, 30, birthdate) AS add_30days,
	DATEADD(DAY, -30, birthdate) AS subtract_30days
FROM 
	voters

--Example-15------------------------
SELECT
	first_name,
	birthdate,
	first_vote_date,
	DATEDIFF(YEAR, birthdate, first_vote_date) AS age_years,
	DATEDIFF(QUARTER, birthdate, first_vote_date) AS age_quarters,
	DATEDIFF(DAY, birthdate, first_vote_date) AS age_days,
	DATEDIFF(HOUR, birthdate, first_vote_date) AS age_hours
FROM 
	voters


--Example-15-----------------------
--Retrieve the date when each voter had their 18th birthday.
SELECT 
	first_name,
	birthdate,
	DATEADD(YEAR, 18, birthdate) AS eighteenth_birthday
  FROM voters;


--Example-16-----------------------
--Add five days to the first_vote_date, to calculate the date when the vote was processed.
SELECT 
	first_name,
	first_vote_date,
	DATEADD(DAY,5,first_vote_date) AS processing_vote_date
  FROM voters;


--Example-17-----------------------
--Calculate what day it was 476 days ago.
SELECT
	DATEADD(DAY,-476, GETDATE()) AS date_476days_ago;


--Example-18-----------------------
--Calculate the number of years since a participant celebrated their 18th birthday until the first time they voted.
SELECT
	first_name,
	birthdate,
	first_vote_date,
	DATEDIFF(YEAR, DATEADD(YEAR, 18, birthdate), first_vote_date) AS adult_years_until_vote
FROM voters;


--Example-18-----------------------
--How many weeks have passed since the beginning of 2019 until now?
SELECT 
	DATEDIFF(WEEK, '2019-01-01', GETDATE()) AS weeks_passed;


--Example-18-----------------------
DECLARE @date1 NVARCHAR(20) = '2019-05-05'
DECLARE @date2 NVARCHAR(20) = '2019-01-XX'
DECLARE @date3 CHAR(20) = '2019-05-05 12:45:59.9999999'
DECLARE @date4 CHAR(20) = '2019-05-05 12:45:59'
SELECT
	ISDATE(@date1) AS valid_date,
	ISDATE(@date2) AS invalid_date,
	ISDATE(@date3) AS valid_datetime2,
	ISDATE(@date4) AS valid_datetime


--Example-18-----------------------
DECLARE @date1 NVARCHAR(20) = '12-30-2019'
DECLARE @date2 NVARCHAR(20) = '30-12-2019'
SET DATEFORMAT dmy;
SELECT
	ISDATE(@date1) AS invalid_dmy,
	ISDATE(@date2) AS valid_dmy


--Example-19-----------------------
SET LANGUAGE English;
SELECT
	ISDATE('12-30-2019') AS mdy,
	ISDATE('30-12-2019') AS dmy;

SET LANGUAGE French;
SELECT
	ISDATE('12-30-2019') AS mdy,
	ISDATE('30-12-2019') AS dmy;


--Example-20-----------------------
--Set the correct date format so that the variable @date1 is interpreted as a valid date.
DECLARE @date1 NVARCHAR(20) = '2018-30-12';
SET DATEFORMAT ydm;
SELECT ISDATE(@date1) AS result;


--Example-20-----------------------
--Set the correct date format so that the variable @date1 is interpreted as a valid date.
DECLARE @date1 NVARCHAR(20) = '15/2019/4';
SET DATEFORMAT dym;
SELECT ISDATE(@date1) AS result;


--Example-20-----------------------
--Set the correct date format so that the variable @date1 is interpreted as a valid date.
DECLARE @date1 NVARCHAR(20) = '10.13.2019';
SET DATEFORMAT mdy;
SELECT ISDATE(@date1) AS result;


--Example-21-----------------------
--Set the correct date format so that the variable @date1 is interpreted as a valid date.
DECLARE @date1 NVARCHAR(20) = '18.4.2019';
SET DATEFORMAT dmy;
SELECT ISDATE(@date1) AS result;


--Example-21-----------------------
--Find out on which day of the week each participant voted 
SELECT
	first_name,
    last_name,
    birthdate,
	first_vote_date,
	DATENAME(WEEKDAY, first_vote_date) AS first_vote_weekday
FROM voters;


--Example-22-----------------------
--Calculate the age of each participant when they first joined the voting contest.
SELECT
	first_name,
    last_name,
    birthdate,
	first_vote_date,
	DATEDIFF(YEAR, birthdate, first_vote_date) AS age_at_first_vote	
FROM voters;


--Example-23-----------------------
--Calculate the current age of each participant. Remember that you can use functions as parameters for other functions.
SELECT
	first_name,
    last_name,
    birthdate,
	first_vote_date,
	DATEDIFF(YEAR, birthdate, GETDATE()) AS current_age
FROM voters;


--3. WORKING WITH STRINGS--------------------------------------------------------

--A. Functions for positions:
  --1. LEN(): 
	--> Returns the number of characters of the provided string excluding the blanks at the end.
	--> It has only one parameter:the string whose length you want to calculate.
  --2. CHARINDEX()
	--> Looks for a character expression in a given string.
	--> Returns its starting position.
	--> It has 2 mandatory parameters and 1 optional parameter:
		--the expression we are looking for, the string in which we do the search, a value expressing the starting position of te search.
  --3. PATINDEX()
	--> It is similar to CHARINDEX() but more powerful.
	--> Returns the starting position of a pattern in an expression.
	--> You can use wildcard characters in the expression you are looking for.
		--Wildcard:		Explanation:
		--%				Match any string of any length(including zero length).
		--_				Match on a single character.
		--[]			Match on any character in the [] brackets(for example [abc] would match on a, b or c characters).

--B. Functions for string transformation:
  --1. LOWER():
	--> Converts all characters from a string to lowercase.
  --2. UPPER():
	--> Converts all characters from a string to uppercase.
  --3. LEFT():
	--> Returns the specified number of characters from the beginning of the string.
	--> Receive 2 parameters.The string you are working with and the number of characters you need from it.
  --4. RIGHT():
	--> Returns the specified number of characters from the end of the string.
	--> Receive 2 parameters.The string you are working with and the number of characters you need from it.
  --5. LTRIM():
	--> Returns a string after removing the leading blanks.
  --6. RTRIM():
	--> Returns a string after removing the trailing blanks.
  --7. TRIM():
	--> Returns a string after removing the blanks or other specified characters.
  --8. REPLACE():
	--> Returns a string where all occurences of an expression are replaced with another one.
	--> Receive 3 parameters:
		--The expression in which we are performing the search, the expression we are searching for, and then the replacement.
  --9. SUBSTRING():
	--> Returns part of a string.
	--> This function needs 3 parameters:
		--The expression from which you want to extract substring, starting position of your substring and number of characters you want to return.

--C. Functions manipulating groups of strings:
  --1. CONCAT():
	--> You can concatenate a series of strings using CONCAT().
	--> CONCAT() joins values together.
  --2. CONCAT_WS():
	--> You can concatenate a series of strings using CONCAT_WS().
	--> CONCAT_WS(), meaning concat with seperator.
	--> Receives a character value as the first parameter, which is called 'the seperator'.
	--Keep in mind:
		/* The advantage of using functions instead of joining together values with the '+' operator is that 
		   you can concatenate all data types, not only strings. */
  --3. STRING_AGG():
	--> Concatenates the values of string expressions and places seperator values between them.
	--> It also has an optional clause. STRING_AGG(expression, seperator) [<order_clause>]
  --4.STRING_SPLIT(string, seperator):
	--> Divides a string into smaller pieces, based on a sperator.
	--> Returns a single column table.
	--> Because the result of the function is a table, it cannot be used as a column in the SELECT clause.
	--> You can only use it in the FROM clause, just like a normal table.

--Example-1-----------------------
SELECT LEN('Do you know the length of this sentence?') AS length


--Example-2-----------------------
SELECT DISTINCT TOP(5)
	bean_origin,
	LEN(bean_origin) AS length
FROM ratings


--Example-3-----------------------
SELECT
	CHARINDEX('chocolate', 'White chocolate is not real chocolate'),
	CHARINDEX('chocolate', 'White chocolate is not real chocolate', 10),
	CHARINDEX('chocolates', 'White chocolate is not real chocolate');


--Example-4-----------------------
SELECT
	PATINDEX('%chocolate%', 'White chocolate is not real chocolate'),
	PATINDEX('%ch_c%', 'White chocolate is not real chocolate');


--Example-5-----------------------
--Calculate the length of each broad_bean_origin. Order the results from the longest to shortest.
SELECT TOP 10 
	company, 
	broad_bean_origin,
	LEN(broad_bean_origin) AS length
FROM ratings
ORDER BY length DESC;


--Example-6-----------------------
SELECT 
	first_name,
	last_name,
	email 
FROM voters
-- Look for the "dan" expression in the first_name
WHERE PATINDEX('%dan%', first_name) > 0;


--Example-7-----------------------
SELECT 
	first_name,
	last_name,
	email 
FROM voters
-- Look for the "dan" expression in the first_name
WHERE CHARINDEX('dan', first_name) > 0 
    -- Look for last_names that contain the letter "z"
	AND CHARINDEX('z', last_name) > 0;


--Example-8-----------------------
SELECT 
	first_name,
	last_name,
	email 
FROM voters
-- Look for the "dan" expression in the first_name
WHERE CHARINDEX('dan', first_name) > 0 
    -- Look for last_names that do not contain the letter "z"
	AND CHARINDEX('z', last_name) = 0;


--Example-9-----------------------
--Write a query to select the voters whose first name contains the letters "rr".
SELECT 
	first_name,
	last_name,
	email 
FROM voters
WHERE PATINDEX('%rr%', first_name) > 0;


--Example-10-----------------------
--Write a query to select the voters whose first name starts with "C" and has "r" as the third letter.
SELECT 
	first_name,
	last_name,
	email 
FROM voters
WHERE PATINDEX('C_r%', first_name) > 0;


--Example-11-----------------------
--Select the voters whose first name contains an "a" followed by other letters, then a "w", followed by other letters.
SELECT 
	first_name,
	last_name,
	email 
FROM voters
WHERE PATINDEX('%a%w%', first_name) > 0;


--Example-12-----------------------
--Write a query to select the voters whose first name contains one of these letters: "x", "w" or "q".
SELECT 
	first_name,
	last_name,
	email 
FROM voters
WHERE PATINDEX('%[xwq]%', first_name) > 0;


--Example-13-----------------------
SELECT 
	country,
	LOWER(country) AS country_lowercase,
	UPPER(country) AS country_uppercase
FROM
	voters;


--Example-14-----------------------
SELECT 
	country,
	LEFT(country, 3) AS country_prefix,
	email,
	RIGHT(email, 4) AS email_domain
FROM 
	voters


--Example-15-----------------------
SELECT REPLACE('I like apples, apples are good.', 'apple', 'orange') AS result;


--Example-16-----------------------
SELECT SUBSTRING('123456789', 5, 3) AS result;


--Example-17-----------------------
--Select information from the ratings table, excluding the unknown broad_bean_origins.
--Convert the broad_bean_origins to lowercase when comparing it to the '%unknown%' expression.
SELECT 
	company,
	bean_type,
	broad_bean_origin,
	'The company ' +  company + ' uses beans of type "' + bean_type + '", originating from ' + broad_bean_origin + '.'
FROM ratings
WHERE
	broad_bean_origin NOT LIKE '%unknown%';


--Example-18-----------------------
--Restrict the query to make sure that the bean_type is not unknown.
--Convert the bean_type to lowercase and compare it with an expression that contains the '%unknown%' word.
SELECT 
	company,
	bean_type,
	broad_bean_origin,
	'The company ' +  company + ' uses beans of type "' + bean_type + '", originating from ' + broad_bean_origin + '.'
FROM ratings
WHERE 
	LOWER(broad_bean_origin) NOT LIKE '%unknown%'
    AND bean_type NOT LIKE '%unknown%';


--Example-19-----------------------
--Format the message so that company and broad_bean_origin are uppercase.
SELECT 
	company,
	bean_type,
	broad_bean_origin,
	'The company ' +  UPPER(company) + ' uses beans of type "' + bean_type + '", originating from ' + UPPER(broad_bean_origin) + '.'
FROM ratings
WHERE 
	LOWER(broad_bean_origin) NOT LIKE '%unknown%'
    AND LOWER(bean_type) NOT LIKE '%unknown%';


--Example-20-----------------------
--Select information from the voters table, including a new column called part1, containing only the first 3 letters from the first name.
SELECT 
	first_name,
	last_name,
	country,
	LEFT(first_name, 3) AS part1
FROM voters;


--Example-21-----------------------
--Add a new column to the previous query, containing the last 3 letters from the last name.
SELECT 
	first_name,
	last_name,
	country,
	LEFT(first_name, 3) AS part1,
	RIGHT(last_name, 3) AS part2
FROM voters;


--Example-22-----------------------
--Add another column to the previous query, containing the last 2 digits from the birth date.
SELECT 
	first_name,
	last_name,
	country,
	LEFT(first_name, 3) AS part1,
	RIGHT(last_name, 3) AS part2,
	RIGHT(birthdate, 2) AS part3
FROM voters;


--Example-23-----------------------
/*Create an alias for each voter with the following parts: 
the first 3 letters from the first name concatenated with the last 3 letters from the last name, 
followed by the _ character and the last 2 digits from the birth date.*/
SELECT 
	first_name,
	last_name,
	country,
	LEFT(first_name, 3) AS part1,
    RIGHT(last_name, 3) AS part2,
    RIGHT(birthdate, 2) AS part3,
    LEFT(first_name, 3) + RIGHT(last_name, 3) + '_' + RIGHT(birthdate, 2) AS Alias
FROM voters;


--Example-24-----------------------
--Select 5 characters from the email address, starting with position 3.
SELECT 
	email,
	SUBSTRING(email, 3, 5) AS some_letters
FROM voters;


--Example-25-----------------------
--Extract the fruit names from the following sentence: "Apples are neither oranges nor potatoes".
DECLARE @sentence NVARCHAR(200) = 'Apples are neither oranges nor potatoes.'
SELECT
	SUBSTRING(@sentence, 1, 6) AS fruit1,
	SUBSTRING(@sentence, 20, 7) AS fruit2;


--Example-26-----------------------
--Add a new column in the query in which you replace the "yahoo.com" in all email addresses with "live.com".
SELECT 
	first_name,
	last_name,
	email,
	REPLACE(email, 'yahoo.com', 'live.com') AS new_email
FROM voters;


--Example-27-----------------------
--Replace the character "&" from the company name with "and".
SELECT 
	company AS initial_name,
	REPLACE(company, '&', 'and') AS new_name 
FROM ratings
WHERE CHARINDEX('&', company) > 0;


--Example-28-----------------------
--Remove the string "(Valrhona)" from the company name "La Maison du Chocolat (Valrhona)".
SELECT 
	company AS old_company,
	REPLACE(company, '(Valrhona)', '') AS new_company,
	bean_type,
	broad_bean_origin
FROM ratings
WHERE company = 'La Maison du Chocolat (Valrhona)';


--Example-29-----------------------
SELECT
	CONCAT('Apples', 'and', 'oranges') AS result_concat,
	CONCAT_WS(' ', 'Apples', 'and', 'oranges') AS result_concat_ws,
	CONCAT_WS('***', 'Apples', 'and', 'oranges') AS result_concat_ws2


--Example-30-----------------------
SELECT 
	STRING_AGG(first_name, ',') AS list_of_names
FROM
	voters


--Example-31-----------------------
SELECT 
	STRING_AGG(CONCAT(first_name, ' ', last_name, '(', first_vote_date, ')'), CHAR(13)) AS list_of_names
FROM
	voters


--Example-32-----------------------
SELECT 
	YEAR(first_vote_date) AS voting_year,
	STRING_AGG(first_name, ', ') AS voters
FROM
	voters
GROUP BY
	YEAR(first_vote_date);


--Example-33-----------------------
SELECT 
	YEAR(first_vote_date) AS voting_year,
	STRING_AGG(first_name, ', ') WITHIN GROUP (ORDER BY first_name ASC) AS voters
FROM
	voters
GROUP BY
	YEAR(first_vote_date)


--Example-34-----------------------
SELECT *
FROM string_split('1,2,3,4', ',')


--Example-35-----------------------
--Create a message similar to this one: "Chocolate with beans from Belize has a cocoa percentage of 0.6400" for each result of the query.
--Use the + operator to concatenate data and the ' ' character as a separator.
DECLARE @string1 NVARCHAR(100) = 'Chocolate with beans from';
DECLARE @string2 NVARCHAR(100) = 'has a cocoa percentage of';
SELECT 
	bean_type,
	bean_origin,
	cocoa_percent,
	@string1 + ' ' + bean_origin + ' ' + @string2 + ' ' + CAST(cocoa_percent AS nvarchar) AS message1
FROM ratings
WHERE 
	company = 'Ambrosia' 
	AND bean_type <> 'Unknown';


--Example-36-----------------------
--Create the same message, using the CONCAT() function.
DECLARE @string1 NVARCHAR(100) = 'Chocolate with beans from';
DECLARE @string2 NVARCHAR(100) = 'has a cocoa percentage of';
SELECT 
	bean_type,
	bean_origin,
	cocoa_percent,
	CONCAT(@string1, ' ', bean_origin, ' ', @string2, ' ', cocoa_percent) AS message2
FROM ratings
WHERE 
	company = 'Ambrosia' 
	AND bean_type <> 'Unknown';


--Example-37-----------------------
--Create the same message, using the CONCAT_WS() function. Evaluate the difference between this method and the previous ones.
DECLARE @string1 NVARCHAR(100) = 'Chocolate with beans from';
DECLARE @string2 NVARCHAR(100) = 'has a cocoa percentage of';
SELECT 
	bean_type,
	bean_origin,
	cocoa_percent,
	CONCAT_WS(' ', @string1, bean_origin, @string2, cocoa_percent) AS message3
FROM ratings
WHERE 
	company = 'Ambrosia' 
	AND bean_type <> 'Unknown';


--Example-38-----------------------
/*Create a list with all the values found in the bean_origin column for the companies: 
'Bar Au Chocolat', 'Chocolate Con Amor', 'East Van Roasters'. The values should be separated by commas (,).*/
SELECT
	STRING_AGG(bean_origin, ', ') AS bean_origins
FROM ratings
WHERE company IN ('Bar Au Chocolat', 'Chocolate Con Amor', 'East Van Roasters');


--Example-39-----------------------
/*Create a list with the values found in the bean_origin column for each of the companies: 
'Bar Au Chocolat', 'Chocolate Con Amor', 'East Van Roasters'. The values should be separated by commas (,). */
SELECT 
	company,
	STRING_AGG(bean_origin, ',') AS bean_origins
FROM ratings
WHERE company IN ('Bar Au Chocolat', 'Chocolate Con Amor', 'East Van Roasters')
GROUP BY company;


--Example-40-----------------------
--Arrange the values from the list in alphabetical order.
SELECT 
	company,
	STRING_AGG(bean_origin, ',') WITHIN GROUP (ORDER BY bean_origin ASC) AS bean_origins
FROM ratings
WHERE company IN ('Bar Au Chocolat', 'Chocolate Con Amor', 'East Van Roasters')
GROUP BY company


--Example-41-----------------------
--Split the phrase declared in the variable @phrase into sentences (using the . separator).
DECLARE @phrase NVARCHAR(MAX) = 'In the morning I brush my teeth. In the afternoon I take a nap. In the evening I watch TV.'
SELECT value
FROM string_split(@phrase, '.');


--Example-42-----------------------
--Split the phrase declared in the variable @phrase into individual words.
DECLARE @phrase NVARCHAR(MAX) = 'In the morning I brush my teeth. In the afternoon I take a nap. In the evening I watch TV.'
SELECT value
FROM string_split(@phrase, ' ');


--Example-43-----------------------
/*Select only the voters whose first name has fewer than 5 characters and email address meets these conditions in the same time:
(1) starts with the letter “j”, (2) the third letter is “a” and (3) is created at yahoo.com. */
SELECT
	first_name,
    last_name,
	birthdate,
	email,
	country
FROM voters
WHERE LEN(first_name) < 5
	AND PATINDEX('j_a%@yahoo.com', email) > 0;


--Example-44-----------------------
--Concatenate the first name and last name in the same column and present it in this format: " *** Firstname LASTNAME *** ".
SELECT
	CONCAT('***' , first_name, ' ', UPPER(last_name), '***') AS name,
    last_name,
	birthdate,
	email,
	country
FROM voters
WHERE LEN(first_name) < 5
	AND PATINDEX('j_a%@yahoo.com', email) > 0;       


--Example-45-----------------------
--Mask the year part from the birthdate column, by replacing the last two digits with "XX" (1986-03-26 becomes 19XX-03-26).
SELECT
	CONCAT('***' , first_name, ' ', UPPER(last_name), '***') AS name,
    REPLACE(birthdate, SUBSTRING(CAST(birthdate AS varchar), 3, 2), 'XX') AS birthdate,
	email,
	country
FROM voters
WHERE LEN(first_name) < 5
	AND PATINDEX('j_a%@yahoo.com', email) > 0;    


--4. RECOGNAZING NUMERIC DATA PROPERTIES

--A. Aggregate arithmetic functions:
  --1. COUNT(): Returns the number of items found in a group.
  --2. SUM(): Returns the sum of all values from a group.
  --3. MAX(): Returns the maximum value in the expression.
  --4. MIN(): Retunrs the minimum value in the expression.
  --5. AVG(): Returns the average of the values in the group.

--B. Analytic functions:
  --1. FIRST_VALUE(): Returns the first value in an ordered set. It is used in combination with the OVER() clause.
	   --OVER clause components:
		 --Component:				Status:			Description:
		 --PARTITION BY column		Optional		Divide the result set into partitions.
		 --ORDER BY column			Mandatory		Order the result set
		 --ROW or RANGE frame		Optional		Set the partition limits

		--Partition Limits:
		--Boundary:						Description:
		--UNBOUNDED PRECEDING			First row in the partition.       Default: UNBOUNDED PRECEDING AND CURRENT ROW
		--UNBOUNDED FOLLOWING			Last row in the partition.
		--CURRENT ROW					Current row.
		--PRECEDING						Previous row.
		--FOLLOWING						Next row.

  --2. LAST_VALUE(): Returns the last value in an ordered set.
  --3. LAG(): Accesses data from a previous row in the same result set.
  --4. LEAD(): Accesses data from subsequent row in the same result set.

--C. Mathematical functions:
  --1. ABS(): Returns the absolute value of an expression. Is the non-negative value of the expression.
  --2. SIGN(): Returns the sign of an expression, as an integer.
	   --> -1 (negative numbers)
	   --> 0 ()
	   --> +1 (positive numbers)
  --3. CEILING(): Returns the smallest integer greater than or equal to the expression.
  --4. FLOOR(): Returns the largest integer less than or equal to the expression.
  --5. ROUND(): Returns a numeric value, rounded to the specified length.
  --6. POWER(): Returns the expression raised to the specified power.Receives two parameters:an expression and the power to be raised to.
  --7. SQUARE(): Returns the square of the expression.Receives a numeric expression as parameter and returns its square value.
  --8. SQRT(): Returns the square root of the expression.
  --Keep in mind: The type of the expression is float or can be implicitly converted to float.


 


--Example-1-----------------------
SELECT 
	COUNT(ALL country) AS total_countries,
	COUNT(country) AS total_countries,
	COUNT(DISTINCT country) AS distinct_countries,
	COUNT(*) AS all_voters
FROM
	voters;


--Example-2-----------------------
SELECT 
	SUM(ALL total_votes) AS tot_votes1,
	SUM(total_votes) AS tot_votes2,
	SUM(DISTINCT total_votes) AS dist
FROM
	voters
WHERE
	total_votes = 153


--Example-3-----------------------
SELECT
	MIN(rating) AS min_rating,
	MAX(rating) AS max_rating
FROM
	ratings


--Example-4-----------------------
SELECT 
	AVG(rating) AS avg_rating,
	AVG(DISTINCT rating) AS avg_dist
FROM
	ratings


--Example-5-----------------------
SELECT 
	company,
	AVG(rating) AS avg_rating
FROM
	ratings
GROUP BY 
	company

--Example-6-----------------------
--Count the number of voters for each group.
--Calculate the total number of votes per group.
SELECT 
	gender, 
	COUNT(*) AS voters,
	SUM(total_votes) AS total_votes
FROM voters
GROUP BY gender;


--Example-7-----------------------
--Calculate the average percentage of cocoa used by each company.
SELECT 
	company,
	AVG(cocoa_percent) AS avg_cocoa
FROM ratings
GROUP BY company;


--Example-8-----------------------
--Calculate the minimum rating received by each company.
SELECT 
	company,
	MIN(rating) AS min_rating	
FROM ratings
GROUP BY company;


--Example-9-----------------------
SELECT 
	first_name + ' ' +last_name AS name,
	gender,
	total_votes AS votes,
	FIRST_VALUE(total_votes) OVER(PARTITION BY gender ORDER BY total_votes) AS min_votes,
	LAST_VALUE(total_votes) OVER(PARTITION BY gender ORDER BY total_votes
								 ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS max_votes 
FROM
	voters


--Example-10-----------------------
SELECT 
	broad_bean_origin AS bean_origin,
	rating,
	cocoa_percent,
	LAG(cocoa_percent) OVER(ORDER BY rating) AS percent_lower_rating,
	LEAD(cocoa_percent) OVER(ORDER BY rating) AS percent_higher_rating
FROM
	ratings
WHERE
	company = 'Felchlin'


--Example-11-----------------------
--Create a new column, showing the number of votes recorded for the next person in the list.
--Create a new column with the difference between the current voter's total_votes and the votes of the next person.
SELECT 
	first_name,
	last_name,
	total_votes AS votes,
	LEAD(total_votes) OVER (ORDER BY total_votes) AS votes_next_voter,
	LEAD(total_votes) OVER (ORDER BY total_votes) - total_votes AS votes_diff
FROM voters
WHERE country = 'France'
ORDER BY total_votes;


--Example-12-----------------------
/*Create a new column, showing the cocoa percentage of the chocolate bar that received a lower score, 
with cocoa coming from the same location (broad_bean_origin is the same).
  Create a new column with the difference between the current bar's cocoa percentage and the percentage of the previous bar.*/
SELECT 
	broad_bean_origin AS bean_origin,
	rating,
	cocoa_percent,
	LAG(cocoa_percent) OVER(PARTITION BY broad_bean_origin ORDER BY rating) AS percent_lower_rating
FROM ratings
WHERE company = 'Fruition'
ORDER BY broad_bean_origin, rating ASC;


--Example-13-----------------------
--Retrieve the birth date of the oldest voter from each country.
--Retrieve the birth date of the youngest voter from each country.
SELECT 
	first_name + ' ' + last_name AS name,
	country,
	birthdate,
	FIRST_VALUE(birthdate) 
	OVER (PARTITION BY country ORDER BY birthdate) AS oldest_voter,
	LAST_VALUE(birthdate) OVER (PARTITION BY country ORDER BY birthdate 
								ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS youngest_voter
FROM voters
WHERE country IN ('Spain', 'USA');


--Example-14-----------------------
SELECT
	ABS(-50.4 * 3) AS negative,
	ABS(0.0) AS zero,
	ABS(73.2 + 15 + 8.4) AS positive


--Example-15-----------------------
SELECT
	SIGN(-50.4 * 3) AS negative,
	SIGN(0.0) AS zero,
	SIGN(73.2 + 15 + 8.4) AS positive


--Example-16-----------------------
SELECT 
	CEILING(-50.49) AS ceiling_neg,
	CEILING(73.71) AS ceiling_pos


--Example-17-----------------------
SELECT 
	CEILING(-50.49) AS ceiling_neg,
	FLOOR(-50.49) AS floor_neg,
	CEILING(73.71) AS ceiling_pos,
	FLOOR(73.71) AS floor_pos
	

--Example-18-----------------------
SELECT
	ROUND(-50.493, 1) AS round_neg,
	ROUND(73.7145, 2) AS round_pos


--Example-19-----------------------
SELECT 
	POWER(2, 10) AS pos_num,
	POWER(-2, 10) AS neg_num_even_pow,
	POWER(-2, 11) AS neg_num_odd_pow,
	POWER(2.5, 2) AS float_num,
	POWER(2, 2.72) AS float_pow


--Example-20-----------------------
SELECT
	SQUARE(2) AS pos_num,
	SQUARE(-2) AS neg_num,
	SQUARE(2.5) AS float_num


--Example-21-----------------------
SELECT
	SQRT(16) AS int_num,
	SQRT(2.76) AS float_num


--Example-22-----------------------
DECLARE @number1 DECIMAL(18,2) = -5.4;
DECLARE @number2 DECIMAL(18,2) = 7.89;
DECLARE @number3 DECIMAL(18,2) = 13.2;
DECLARE @number4 DECIMAL(18,2) = 0.003;

DECLARE @result DECIMAL(18,2) = @number1 * @number2 - @number3 - @number4;
SELECT 
	@result AS result,
	ABS(@result) AS abs_result;


--Example-23-----------------------
--Round up the ratings to the nearest integer value.
SELECT
	rating,
	CEILING(rating) AS round_up
FROM ratings;


--Example-24-----------------------
--Round down the ratings to the nearest integer value.
SELECT
	rating,
	FLOOR(rating) AS round_down
FROM ratings;


--Example-25-----------------------
--Round the ratings to a decimal number with only 1 decimal.
SELECT
	rating,
	ROUND(rating, 1) AS round_onedec
FROM ratings;


--Example-26-----------------------
DECLARE @number DECIMAL(4, 2) = 4.5;
DECLARE @power INT = 4;
SELECT
	@number AS number,
	@power AS power,
	POWER(@number, @power) AS number_to_power,
	SQUARE(@number) num_squared,
	SQRT(@number) num_square_root;


--Example-27-----------------------
--Select the number of cocoa flavors the company was rated on.
--Select the lowest, highest and the average rating that each company received.
SELECT 
	company, 
	COUNT(*) AS flavors,
	MIN(rating) AS lowest_score,
	MAX(rating) AS highest_score,
	AVG(rating) AS avg_score	  
FROM ratings
GROUP BY company
ORDER BY flavors DESC;


--Example-28-----------------------
--Round the average rating to 1 decimal and show it as a different column.
SELECT 
	company, 
    ROUND(AVG(rating), 1) AS round_avg_score	
FROM ratings
GROUP BY company
ORDER BY round_avg_score

