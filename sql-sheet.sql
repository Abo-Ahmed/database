


SELECT * FROM ALL_SOURCE WHERE UPPER(TEXT) 
LIKE'%SABB_GLOBAL_CONSTANTS%' 
AND OWNER = 'INMA_EPAY';


SELECT TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_TYPE = 'BASE TABLE' AND TABLE_CATALOG='dbName'

SELECT OWNER , TABLE_NAME
  FROM ALL_TABLES

-- SELECT ALL TABLE NAMES AND ITS COLUMNS 
SELECT DISTINCT TABLE_NAME , COUNT(*) OVER (PARTITION BY TABLE_NAME) NUMBER_OF_COLUMNS FROM USER_TAB_COLUMNS ;


-- SELECT ALL PROCEDURE NAMES AND ITS DEPENDENCIES
-- FIRST SOLUTION
SELECT OWNER , NAME , REFERENCED_NAME , REFERENCED_TYPE FROM ALL_DEPENDENCIES WHERE TYPE = 'PROCEDURE'  ORDER BY NAME ;

-- SECOND SOLUTION
SELECT CREATOR CHEMA , NAME TABLE_NAME , COLCOUNT NUMBER_OF_COLUMNS FROM sysibm.systables
WHERE TYPE = 'T';










Keywords
A collection of keywords used in SQL statements, a description, and where appropriate an example. Some of the more advanced keywords have their own dedicated section later in the cheat sheet.
Where MySQL is mentioned next to an example, this means this example is only applicable to MySQL databases (as opposed to any other database system).


SQL Keywords
Keyword	Description


ADD	Adds a new column to an existing table.
Example: Adds a new column named ‘email_address’ to a table named ‘users’.

ALTER TABLE users
ADD email_address varchar(255);


ADD CONSTRAINT	It creates a new constraint on an existing table, which is used to specify rules for any data in the table.
Example: Adds a new PRIMARY KEY constraint named ‘user’ on columns ID and SURNAME.

ALTER TABLE users
ADD CONSTRAINT user PRIMARY KEY (ID, SURNAME);





ALTER TABLE	Adds, deletes or edits columns in a table. It can also be used to add and delete constraints in a table, as per the above.
Example: Adds a new boolean column called ‘approved’ to a table named ‘deals’.

ALTER TABLE deals
ADD approved boolean;

Example 2: Deletes the ‘approved’ column from the ‘deals’ table

ALTER TABLE deals DROP COLUMN approved;
 



SQL Keywords
Keyword	Description


ALTER COLUMN	Changes the data type of a table’s column.
Example: In the ‘users’ table, make the column ‘incept_date’ into a ‘datetime’ type.

ALTER TABLE users
ALTER COLUMN incept_date datetime;



ALL	Returns true if all of the subquery values meet the passed condition. Example: Returns the users with a higher number of tasks than the user with the highest number of tasks in the HR department (id 2)

SELECT first_name, surname, tasks_no FROM users
WHERE tasks_no > ALL (SELECT tasks FROM user WHERE department_id = 2);


AND	Used to join separate conditions within a WHERE clause.
Example: Returns events located in London, United Kingdom

SELECT * FROM events
WHERE host_country='United Kingdom' AND host_ city='London';



ANY	Returns true if any of the subquery values meet the given condition. Example: Returns products from the products table which have received orders – stored in the orders table – with a quantity of more than 5.

SELECT name FROM products
WHERE productId = ANY (SELECT productId FROM orders WHERE quantity > 5);



AS	Renames a table or column with an alias value which only exists for the duration of the query.
Example: Aliases north_east_user_subscriptions column

SELECT north_east_user_subscriptions AS ne_subs FROM users
WHERE ne_subs > 5;

ASC	Used with ORDER BY to return the data in ascending order.
Example: Apples, Bananas, Peaches, Raddish
 



SQL Keywords
Keyword	Description






BETWEEN	Selects values within the given range.

Example 1: Selects stock with a quantity between 100 and 150.

SELECT * FROM stock
WHERE quantity BETWEEN 100 AND 150;

Example 2: Selects stock with a quantity NOT between 100 and 150. Alternatively, using the NOT keyword here reverses the logic and selects values outside the given range.

SELECT * FROM stock
WHERE quantity NOT BETWEEN 100 AND 150;





CASE	Change query output depending on conditions.
Example: Returns users and their subscriptions, along with a new column called activity_levels that makes a judgement based on the number of subscriptions.

SELECT first_name, surname, subscriptions
CASE WHEN subscriptions > 10 THEN 'Very active' WHEN Quantity BETWEEN 3 AND 10 THEN 'Active' ELSE 'Inactive'
END AS activity_levels FROM users;







CHECK	Adds a constraint that limits the value which can be added to a column. Example 1 (MySQL): Makes sure any users added to the users table are 18 or over.

CREATE TABLE users (
first_name varchar(255), age int,
CHECK (age>=18)
);

Example 2 (MySQL): Adds a check after the table has already been created.

ALTER TABLE users ADD CHECK (age>=18);
 



SQL Keywords
Keyword	Description

 

CREATE DATABASE
 
Creates a new database.
Example: Creates a new database named ‘websitesetup’.

CREATE DATABASE websitesetup;
 

Creates a new table .
Example: Creates a new table called ‘users’ in the ‘websitesetup’ database.

 

CREATE TABLE
 
CREATE TABLE users (
id int,
first_name varchar(255), surname varchar(255), address varchar(255), contact_number int
);
 

Sets a default value for a column;
Example 1 (MySQL): Creates a new table called Products which has a name column with a default value of ‘Placeholder Name’ and an available_ from column with a default value of today’s date.

 



DEFAULT
 
CREATE TABLE products ( id int,
name varchar(255) DEFAULT 'Placeholder Name', available_from date DEFAULT GETDATE()
);

Example 2 (MySQL): The same as above, but editing an existing table.

ALTER TABLE products
ALTER name SET DEFAULT 'Placeholder Name', ALTER available_from SET DEFAULT GETDATE();
 

DELETE
 
Delete data from a table.
Example: Removes a user with a user_id of 674.

DELETE FROM users WHERE user_id = 674;
 

Used with ORDER BY to return the data in descending order.
Example: Raddish, Peaches, Bananas, Apples
 



SQL Keywords
Keyword	Description

 

DROP COLUMN
 
Deletes a column from a table.
Example: Removes the first_name column from the users table.

ALTER TABLE users DROP COLUMN first_name
 

DROP DATABASE
 
Deletes the entire database.
Example: Deletes a database named ‘websitesetup’.

DROP DATABASE websitesetup;
 

 


DROP DEFAULT
 
Removes a default value for a column.
Example (MySQL): Removes the default value from the ‘name’ column in the ‘products’ table.

ALTER TABLE products
ALTER COLUMN name DROP DEFAULT;
 

 

DROP TABLE
 
Deletes a table from a database.
Example: Removes the users table.

DROP TABLE users;
 

Checks for the existence of any record within the subquery, returning true if one or more records are returned.
Example: Lists any dealerships with a deal finance percentage less than 10.

 
EXISTS
 
SELECT dealership_name FROM dealerships
WHERE EXISTS (SELECT deal_name FROM deals WHERE dealership_id = deals.dealership_id AND finance_ percentage < 10);
 

 



FROM
 
Specifies which table to select or delete data from.
Example: Selects data from the users table.

SELECT area_manager FROM area_managers
WHERE EXISTS (SELECT ProductName FROM Products WHERE area_manager_id = deals.area_manager_id AND Price < 20);
 



SQL Keywords
Keyword	Description





IN	Used alongside a WHERE clause as a shorthand for multiple OR conditions. So instead of:

SELECT * FROM users
WHERE country = 'USA' OR country = 'United Kingdom' OR country = 'Russia' OR country = 'Australia';
You can use:

SELECT * FROM users
WHERE country IN ('USA', 'United Kingdom', 'Russia', 'Australia');


INSERT INTO	Add new rows to a table.
Example: Adds a new vehicle.

INSERT INTO cars (make, model, mileage, year) VALUES ('Audi', 'A3', 30000, 2016);


IS NULL	Tests for empty (NULL) values.
Example: Returns users that haven’t given a contact number.

SELECT * FROM users
WHERE contact_number IS NULL;
IS NOT NULL	The reverse of NULL. Tests for values that aren’t empty / NULL.


LIKE	Returns true if the operand value matches a pattern.
Example: Returns true if the user’s first_name ends with ‘son’.

SELECT * FROM users
WHERE first_name LIKE '%son';


NOT	Returns true if a record DOESN’T meet the condition.
Example: Returns true if the user’s first_name doesn’t end with ‘son’.

SELECT * FROM users
WHERE first_name NOT LIKE '%son';


OR	Used alongside WHERE to include data when either condition is true.
Example: Returns users that live in either Sheffield or Manchester.

SELECT * FROM users
WHERE city = 'Sheffield' OR 'Manchester';
 



SQL Keywords
Keyword	Description

 


ORDER BY
 
Used to sort the result data in ascending (default) or descending order through the use of ASC or DESC keywords.
Example: Returns countries in alphabetical order.

SELECT * FROM countries ORDER BY name;
 


ROWNUM
 
Returns results where the row number meets the passed condition.
Example: Returns the top 10 countries from the countries table.
 



 



SELECT
 
Used to select data from a database, which is then returned in a results set.
Example 1: Selects all columns from all users.

SELECT * FROM users;
Example 2: Selects the first_name and surname columns from all users.xx
SELECT first_name, surname FROM users;
 

 

SELECT DISTINCT
 
Sames as SELECT, except duplicate values are excluded.
Example: Creates a backup table using data from the users table.

SELECT * INTO usersBackup2020 FROM users;
 


SELECT INTO
 
Copies data from one table and inserts it into another.
Example: Returns all countries from the users table, removing any duplicate values (which would be highly likely)

SELECT DISTINCT country from users;
 

 

SELECT TOP
 
Allows you to return a set number of records to return from a table.
Example: Returns the top 3 cars from the cars table.

SELECT TOP 3 * FROM cars;
 



SQL Keywords
Keyword	Description



SET	Used alongside UPDATE to update existing data in a table.
Example: Updates the value and quantity values for an order with an id of 642 in the orders table.

UPDATE orders
SET value = 19.49, quantity = 2 WHERE id = 642;
SOME	Identical to ANY.

TOP	Used alongside SELECT to return a set number of records from a table.
Example: Returns the top 5 users from the users table.

SELECT TOP 5 * FROM users;

TRUNCATE TABLE	Similar to DROP, but instead of deleting the table and its data, this deletes only the data.
Example: Empties the sessions table, but leaves the table itself intact.

TRUNCATE TABLE sessions;



UNION	Combines the results from 2 or more SELECT statements and returns only distinct values.
Example: Returns the cities from the events and subscribers tables.

SELECT city FROM events UNION
SELECT city from subscribers;
UNION ALL	The same as UNION, but includes duplicate values.
 



 
 
Comments allow you to explain sections of your SQL statements, or to comment out code and prevent its execution.
In SQL, there are 2 types of comments, single line and multiline.




Single Line Comments
Single line comments start with –. Any text after these 2 characters to the end of the line will be ignored.


Multiline Comments
Multiline comments start with /* and end with */. They stretch across multiple lines until the closing characters have been found.

 
When creating a new table or editing an existing one, you must specify the type of data that each column accepts.



In the below example, data passed to the id column must be an int, whilst the first_name column has a VARCHAR data type with a maximum of 255 characters.


String Data Types

	String Data Types
Data Type	Description

CHAR(size)	Fixed length string which can contain letters, numbers and special characters. The size parameter sets the maximum string length, from 0 – 255 with a default of 1.

VARCHAR(size)	Variable length string similar to CHAR(), but with a maximum string length range from 0 to 65535.
BINARY(size)	Similar to CHAR() but stores binary byte strings.
VARBINARY(size)	Similar to VARCHAR() but for binary byte strings.
TINYBLOB	Holds Binary Large Objects (BLOBs) with a max length of 255 bytes.

TINYTEXT	Holds a string with a maximum length of 255 characters. Use VARCHAR() instead, as it’s fetched much faster.

TEXT(size)	Holds a string with a maximum length of 65535 bytes. Again, better to use VARCHAR().

BLOB(size)	Holds Binary Large Objects (BLOBs) with a max length of 65535 bytes.
MEDIUMTEXT	Holds a string with a maximum length of 16,777,215 characters.
 



	String Data Types
Data Type	Description

MEDIUMBLOB	Holds Binary Large Objects (BLOBs) with a max length of 16,777,215 bytes.
LONGTEXT	Holds a string with a maximum length of 4,294,967,295 characters.

LONGBLOB	Holds Binary Large Objects (BLOBs) with a max length of 4,294,967,295 bytes.


ENUM(a, b, c,
etc…)	A string object that only has one value, which is chosen from a list of values which you define, up to a maximum of 65535 values. If a value is added which isn’t on this list, it’s replaced with a blank value instead. Think of ENUM being similar to HTML radio boxes in this regard.

CREATE TABLE tshirts (color ENUM(‘red’, ‘green’, ‘blue’, ‘yellow’, ‘purple’));

SET(a, b, c, etc…)	A string object that can have 0 or more values, which is chosen from a list of values which you define, up to a maximum of 64 values. Think of SET being similar to HTML checkboxes in this regard.



Numeric Data Types

Numeric Data Types
Data Type	Description

BIT(size)	A bit-value type with a default of 1. The allowed number of bits in a value is set via the size parameter, which can hold values from 1 to 64.

TINYINT(size)	A very small integer with a signed range of -128 to 127, and an unsigned range of 0 to 255. Here, the size parameter specifies the maximum allowed display width, which is 255.

BOOL	Essentially a quick way of setting the column to TINYINT with a size of
1. 0 is considered false, whilst 1 is considered true.
BOOLEAN	Same as BOOL.

SMALLINT(size)	A small integer with a signed range of -32768 to 32767, and an unsigned range from 0 to 65535. Here, the size parameter specifies the maximum allowed display width, which is 255.
 



	Numeric Data Types
Data Type	Description

MEDIUMINT(size)	A medium integer with a signed range of -8388608 to 8388607, and an unsigned range from 0 to 16777215. Here, the size parameter specifies the maximum allowed display width, which is 255.

INT(size)	A medium integer with a signed range of -2147483648 to 2147483647, and an unsigned range from 0 to 4294967295. Here, the size parameter specifies the maximum allowed display width, which is 255.
INTEGER(size)	Same as INT.

BIGINT(size)	A medium integer with a signed range of -9223372036854775808 to 9223372036854775807, and an unsigned range from 0 to 18446744073709551615. Here, the size parameter specifies the maximum allowed display width, which is 255.

FLOAT(p)	A floating point number value. If the precision (p) parameter is between 0 to 24, then the data type is set to FLOAT(), whilst if its from 25 to 53, the data type is set to DOUBLE(). This behaviour is to make the storage of values more efficient.

DOUBLE(size, d)	A floating point number value where the total digits are set by the size parameter, and the number of digits after the decimal point is set by the d parameter.


DECIMAL(size, d)	An exact fixed point number where the total number of digits is set by the size parameters, and the total number of digits after the decimal point is set by the d parameter.

For size, the maximum number is 65 and the default is 10, whilst for d, the maximum number is 30 and the default is 10.
DEC(size, d)	Same as DECIMAL.
 


Date / Time Data Types

	Date / Time Data Types
Data Type	Description

DATE	A simple date in YYYY-MM–DD format, with a supported range from ‘1000-01-01’ to ‘9999-12-31’.


DATETIME(fsp)	A date time in YYYY-MM-DD hh:mm:ss format, with a supported range from ‘1000-01-01 00:00:00’ to ‘9999-12-31 23:59:59’.
By adding DEFAULT and ON UPDATE to the column definition, it automatically sets to the current date/time.



TIMESTAMP(fsp)	A Unix Timestamp, which is a value relative to the number of seconds since the Unix epoch (‘1970-01-01 00:00:00’ UTC). This has a supported range from ‘1970-01-01 00:00:01’ UTC to ‘2038-01-09
03:14:07’ UTC.
By adding DEFAULT CURRENT_TIMESTAMP and ON UPDATE
CURRENT TIMESTAMP to the column definition, it automatically sets to current date/time.

TIME(fsp)	A time in hh:mm:ss format, with a supported range from ‘-838:59:59’ to ‘838:59:59’.
YEAR	A year, with a supported range of ‘1901’ to ‘2155’.
 











Arithmetic Operators

Arithmetic Operators
Operator	Description
+	Add
–	Subtract
*	Multiply
/	Divide
%	Modulo

Bitwise Operator

Bitwise Operator
Operator	Description
&	Bitwise AND
|	Bitwise OR
^	Bitwise exclusive OR

Comparison Operators

	Comparison Operators
Operator	Description
=	Equal to
>	Greater than
<	Less than
>=	Greater than or equal to
<=	Less than or equal to
<>	Not equal to
 
Compound Operators

	Compound Operators
Operator	Description
+=	Add equals
-=	Subtract equals
*=	Multiply equals
/=	Divide equals
%=	Modulo equals
&=	Bitwise AND equals
^-=	Bitwise exclusive equals
|*=

































	Bitwise OR equals
 











String Functions

	String Functions
Name	Description
ASCII	Returns the equivalent ASCII value for a specific character.
CHAR_LENGTH	Returns the character length of a string.
CHARACTER_ LENGTH	
Same as CHAR_LENGTH.
CONCAT	Adds expressions together, with a minimum of 2.
CONCAT_WS	Adds expressions together, but with a separator between each value.

FIELD	Returns an index value relative to the position of a value within a list of values.
FIND IN SET	Returns the position of a string in a list of strings.

FORMAT	When passed a number, returns that number formatted to include commas (eg 3,400,000).

INSERT	Allows you to insert one string into another at a certain point, for a certain number of characters.
INSTR	Returns the position of the first time one string appears within another.
LCASE	Convert a string to lowercase.

LEFT	Starting from the left, extract the given number of characters from a string and return them as another.
LENGTH	Returns the length of a string, but in bytes.
LOCATE	Returns the first occurrence of one string within another,
LOWER	Same as LCASE.
LPAD	Left pads one string with another, to a specific length.
LTRIM	Remove any leading spaces from the given string.




 



	String Functions
Name	Description
MID	Extracts one string from another, starting from any position.

POSITION	Returns the position of the first time one substring appears within another.
REPEAT	Allows you to repeat a string

REPLACE	Allows you to replace any instances of a substring within a string, with a new substring.
REVERSE	Reverses the string.

RIGHT	Starting from the right, extract the given number of characters from a string and return them as another.
RPAD	Right pads one string with another, to a specific length.
RTRIM	Removes any trailing spaces from the given string.
SPACE	Returns a string full of spaces equal to the amount you pass it.
STRCMP	Compares 2 strings for differences
SUBSTR	Extracts one substring from another, starting from any position.
SUBSTRING	Same as SUBSTR
SUBSTRING_ INDEX	Returns a substring from a string before the passed substring is found the number of times equals to the passed number.

TRIM	Removes trailing and leading spaces from the given string. Same as if you were to run LTRIM and RTRIM together.
UCASE	Convert a string to uppercase.
UPPER	Same as UCASE.
 


Numeric Functions

	Numeric Functions
Name	Description
ABS	Returns the absolute value of the given number.
ACOS	Returns the arc cosine of the given number.
ASIN	Returns the arc sine of the given number.
ATAN	Returns the arc tangent of one or 2 given numbers.
ATAN2	Return the arc tangent of 2 given numbers.
AVG	Returns the average value of the given expression.

CEIL	Returns the closest whole number (integer) upwards from a given decimal point number.
CEILING	Same as CEIL.
COS	Returns the cosine of a given number.
COT	Returns the cotangent of a given number.
COUNT	Returns the amount of records that are returned by a SELECT query.
DEGREES	Converts a radians value to degrees.
DIV	Allows you to divide integers.
EXP	Returns e to the power of the given number.

FLOOR	Returns the closest whole number (integer) downwards from a given decimal point number.
GREATEST	Returns the highest value in a list of arguments.
LEAST	Returns the smallest value in a list of arguments.
LN	Returns the natural logarithm of the given number

LOG	Returns the natural logarithm of the given number, or the logarithm of the given number to the given base
LOG10	Does the same as LOG, but to base 10.
 



	Numeric Functions
Name	Description
LOG2	Does the same as LOG, but to base 2.
MAX	Returns the highest value from a set of values.
MIN	Returns the lowest value from a set of values.

MOD	Returns the remainder of the given number divided by the other given number.
PI	Returns PI.

POW	Returns the value of the given number raised to the power of the other given number.
POWER	Same as POW.
RADIANS	Converts a degrees value to radians.
RAND	Returns a random number.
ROUND	Round the given number to the given amount of decimal places.
SIGN	Returns the sign of the given number.
SIN	Returns the sine of the given number.
SQRT	Returns the square root of the given number.
SUM	Returns the value of the given set of values combined.
TAN	Returns the tangent of the given number.
TRUNCATE	Returns a number truncated to the given number of decimal places.
 


Date Functions

	Numeric Functions
Name	Description

ADDDATE	Add a date interval (eg: 10 DAY) to a date (eg: 20/01/20) and return the result (eg: 20/01/30).

ADDTIME	Add a time interval (eg: 02:00) to a time or datetime (05:00) and return the result (07:00).
CURDATE	Get the current date.
CURRENT_DATE	Same as CURDATE.
CURRENT_TIME	Get the current time.
CURRENT_ TIMESTAMP	
Get the current date and time.
CURTIME	Same as CURRENT_TIME.
DATE	Extracts the date from a datetime expression.
DATEDIFF	Returns the number of days between the 2 given dates.
DATE_ADD	Same as ADDDATE.
DATE_FORMAT	Formats the date to the given pattern.

DATE_SUB	Subtract a date interval (eg: 10 DAY) to a date (eg: 20/01/20) and return the result (eg: 20/01/10).
DAY	Returns the day for the given date.
DAYNAME	Returns the weekday name for the given date.
DAYOFWEEK	Returns the index for the weekday for the given date.
DAYOFYEAR	Returns the day of the year for the given date.
EXTRACT	Extract from the date the given part (eg MONTH for 20/01/20 = 01).
FROM DAYS	Return the date from the given numeric date value.
HOUR	Return the hour from the given date.
 



	Numeric Functions
Name	Description
LAST DAY	Get the last day of the month for the given date.
LOCALTIME	Gets the current local date and time.
LOCALTIMESTAMP	Same as LOCALTIME.

MAKEDATE	Creates a date and returns it, based on the given year and number of days values.

MAKETIME	Creates a time and returns it, based on the given hour, minute and second values.
MICROSECOND	Returns the microsecond of a given time or datetime.
MINUTE	Returns the minute of the given time or datetime.
MONTH	Returns the month of the given date.
MONTHNAME	Returns the name of the month of the given date.
NOW	Same as LOCALTIME.
PERIOD_ADD	Adds the given number of months to the given period.
PERIOD_DIFF	Returns the difference between 2 given periods.
QUARTER	Returns the year quarter for the given date.
SECOND	Returns the second of a given time or datetime.
SEC_TO_TIME	Returns a time based on the given seconds.
STR_TO_DATE	Creates a date and returns it based on the given string and format.
SUBDATE	Same as DATE_SUB.

SUBTIME	Subtracts a time interval (eg: 02:00) to a time or datetime (05:00) and return the result (03:00).
SYSDATE	Same as LOCALTIME.
TIME	Returns the time from a given time or datetime.
TIME_FORMAT	Returns the given time in the given format.
 



	Numeric Functions
Name	Description
TIME_TO_SEC	Converts and returns a time into seconds.
TIMEDIFF	Returns the difference between 2 given time/datetime expressions.
TIMESTAMP	Returns the datetime value of the given date or datetime.

TO_DAYS	Returns the total number of days that have passed from ‘00-00- 0000’ to the given date.
WEEK	Returns the week number for the given date.
WEEKDAY	Returns the weekday number for the given date.
WEEKOFYEAR	Returns the week number for the given date.
YEAR	Returns the year from the given date.
YEARWEEK	Returns the year and week number for the given date.
 


Misc Functions

	Numeric Functions
Name	Description
IN	Returns the given number in binary.
BINARY	Returns the given value as a binary string.
CAST	Convert one type into another.
COALESCE	From a list of values, return the first non-null value.
CONNECTION_ID	For the current connection, return the unique connection ID.

CONV	Convert the given number from one numeric base system into another.
CONVERT	Convert the given value into the given datatype or character set.

CURRENT_USER	Return the user and hostname which was used to authenticate with the server.
DATABASE	Get the name of the current database.



GROUP BY	Used alongside aggregate functions (COUNT, MAX, MIN, SUM, AVG) to group the results.

Example: Lists the number of users with active orders.

SELECT COUNT(user_id), active_orders FROM users
GROUP BY active_orders;



HAVING	It’s used in the place of WHERE with aggregate functions.

Example: Lists the number of users with active orders, but only include users with more than 3 active orders.

SELECT COUNT(user_id), active_orders FROM users
GROUP BY active_orders HAVING COUNT(user_id) > 3;
IF	If the condition is true return a value, otherwise return another value.
IFNULL	If the given expression equates to null, return the given value.
 



	Numeric Functions
Name	Description
ISNULL	If the expression is null, return 1, otherwise return 0.

LAST_INSERT_ID	For the last row which was added or updated in a table, return the auto increment ID.

NULLIF	Compares the 2 given expressions. If they are equal, NULL is returned, otherwise the first expression is returned.
SESSION_USER	Return the current user and hostnames.
SYSTEM_USER	Same as SESSION_USER.
USER	Same as SESSION_USER.
VERSION	Returns the current version of the MySQL powering the database.
 
In SQL, Wildcards are special characters used with the LIKE and NOT LIKE keywords which allow us to search data with sophisticated patterns much more efficiently

Wildcards
Name	Description




%	Equates to zero or more characters.
Example 1: Find all users with surnames ending in ‘son’.
SELECT * FROM users
WHERE surname LIKE '%son';

Example 2: Find all users living in cities containing the pattern ‘che’
SELECT * FROM users WHERE city LIKE '%che%';


_	Equates to any single character.
Example: Find all users living in cities beginning with any 3 characters, followed by ‘chester’.
SELECT * FROM users
WHERE city LIKE ' 	chester';






[charlist]	Equates to any single character in the list.
Example 1: Find all users with first names beginning with J, H or M.
SELECT * FROM users
WHERE first_name LIKE '[jhm]%';

Example 2: Find all users with first names beginning letters between A–L.
SELECT * FROM users
WHERE first_name LIKE '[a-l]%';

Example 3: Find all users with first names not ending with letters between n–s.
SELECT * FROM users
WHERE first_name LIKE '%[!n-s]';
 
In relational databases, there is a concept of primary and foreign keys. In SQL tables, these are included as constraints, where a table can have a primary key, a foreign key, or both.



Primary Key
A primary key allows each record in a table to be uniquely identified. There can only be one primary key per table, and you can assign this constraint to any single or combination of columns. However, this means each value within this column(s) must be unique.
Typically in a table, the primary key is an ID column, and is usually paired with the AUTO_ INCREMENT keyword. This means the value increases automatically as new records are created.

Example 1 (MySQL)

Create a new table and set the primary key to the ID column.




Example 2 (MySQL)

Alter an existing table and set the primary key to the first_name column.

 

	
Foreign Key
A foreign key can be applied to one column or many and is used to
link 2 tables together in a relational database.
As seen in the diagram below, the table containing the foreign key is called the child key, whilst the table which contains
the referenced key, or candidate key, is called the parent table.
This essentially means that the column data is shared between 2 tables, as a foreign key also prevents invalid data from being inserted which isn’t also present in the parent table.

Example 1 (MySQL)

Create a new table and turn any columns that reference IDs in other tables into foreign keys.



Example 2 (MySQL)

Alter an existing table and create a foreign key.

 
Indexes are attributes that can be assigned to columns that are frequently searched against to make data retrieval a quicker and more efficient process.

This doesn’t mean each column should be made into an index though, as it takes longer for a column with an index to be updated than a column without. This is because when indexed columns are updated, the index itself must also be updated.

 
In SQL, a JOIN clause is used to return a results set which combines data from multiple tables, based on a common column which is featured in both of them

There are a number of different joins available for you to use:
•	Inner Join (Default): Returns any records which have matching values in both tables.
•	Left Join: Returns all of the records from the first table, along with any matching records from the second table.
•	Right Join: Returns all of the records from the second table, along with any matching records from the first.
•	Full Join: Returns all records from both tables when there is a match. A common way of visualising how joins work is like this:
 

INNER JOIN
 

LEFT JOIN
 

RIGHT JOIN
 

OUTER JOIN
 

 	 	 	 


In the following example, an inner join will be used to create a new unifying view combining the orders table and then 3 different tables
We’ll replace the user_id and product_id with the first_name and surname columns of the user who placed the order, along with the name of the item which was purchased.
 



Would return a results set which looks like:

 

















Creating Views
To create a view, you can do so like this:


Then in future, if you need to access the stored result set, you can do so like this:



Replacing Views
With the CREATE OR REPLACE command, a view can be updated.


Deleting Views
To delete a view, simply use the DROP VIEW command.

