
-- 1. Login to MySQL
mysql5 -u mysqladmin -p

-- with specific database
mysql -u [username] -p [database];

-- Export data using mysqldump tool
mysqldump -u [username] -p [database] > data_backup.sql;
  
-- 2. Quit MySQL
quit;

-- Exit mysql command-line client:
exit;

-- To clear MySQL screen console window on Linux, you use the following command:
system clear;
     
-- 3. Display all databases
show databases;

-- 4. Create a database
CREATE DATABASE test2;

-- Create a database with a specified name if it does not exist in the database server
CREATE DATABASE [IF NOT EXISTS] database_name;

-- 5. Make test2 the active database
USE test2;

-- 6. Show the currently selected database
SELECT DATABASE();

-- 7. Delete the named database
DROP DATABASE IF EXISTS test2;

-- 8. Creating Table

CREATE TABLE student(
  first_name VARCHAR(30) NOT NULL,
  last_name VARCHAR(30) NOT NULL,
  email VARCHAR(60) NULL,
  street VARCHAR(50) NOT NULL,
  city VARCHAR(40) NOT NULL,
  state CHAR(2) NOT NULL DEFAULT "PA",
  zip MEDIUMINT UNSIGNED NOT NULL,
  phone VARCHAR(20) NOT NULL,
  birth_date DATE NOT NULL,
  sex ENUM('M', 'F') NOT NULL,
  date_entered TIMESTAMP,
  lunch_cost FLOAT NULL,
  student_id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY );
 
-- primary key as composite attribute

CREATE TABLE absence(
    student_id INT UNSIGNED NOT NULL,
    date DATE NOT NULL,
    PRIMARY KEY(student_id, date));
    
-- a. VARCHAR(30) : Characters with an expected max length of 30
 
-- b. NOT NULL : Must contain a value
 
-- c. NULL : Doesn't require a value
 
-- d. CHAR(2) : Contains exactly 2 characters
 
-- e. DEFAULT "PA" : Receives a default value of PA
 
-- f. MEDIUMINT : Value no greater then 8,388,608
 
-- g. UNSIGNED : Can't contain a negative value
 
-- h. DATE : Stores a date in the format YYYY-MM-DD
 
-- i. ENUM('M', 'F') : Can contain either a M or F
 
-- j. TIMESTAMP : Stores date and time in this format YYYY-MM-DD-HH-MM-SS
 
-- k. FLOAT: A number with decimal spaces, with a value no bigger than 1.1E38 or smaller than -1.1E38
 
-- l. INT : Contains a number without decimals
 
-- m. AUTO_INCREMENT : Generates a number automatically that is one greater then the previous row
 
-- n. PRIMARY KEY: Unique ID that is assigned to this row of data
--     I. Uniquely identifies a row or record
--     II. Must be given a value when the row is created and that value can’t be NULL
--     III. The original value can’t be changed It should be short     
--     IV. It’s probably best to auto increment the value of the key
 
-- o. Atomic Data & Table Templating
-- As your database increases in size, you are going to want everything to be organized, so that it can perform your queries quickly. If your tables are set up properly, your database will be able to crank through hundreds of thousands of bits of data in seconds.
 
-- How do you know how to best set up your tables though? Just follow some simple rules:
 
-- What does normalized mean?
-- Normalized just means that the database is organized in a way that is considered standardized by professional SQL programmers. So if someone new needs to work with the tables they’ll be able to understand how to easily.
 
-- What are the rules for creating normalized tables:
-- The tables and variables defined in them must be atomic Each row must have a Primary Key defined.
 
-- You also want to eliminate using the same values repeatedly in your columns. Ex. You wouldn’t want a column named instructors, in which you hand typed in their names each time. You instead, should create an instructor table and link to it’s key.
  
-- No two columns should have a relationship in which when one changes another must also change in the same table. This is called a Dependency. Note: This is another rule that is sometimes ignored.
 
------------ Numeric Types ------------
 
-- TINYINT: A number with a value no bigger than 127 or smaller than -128
-- SMALLINT: A number with a value no bigger than 32,768 or smaller than -32,767
-- MEDIUM INT: A number with a value no bigger than 8,388,608 or smaller than -8,388,608
-- INT: A number with a value no bigger than 2^31 or smaller than 2^31 – 1
-- BIGINT: A number with a value no bigger than 2^63 or smaller than 2^63 – 1
-- FLOAT: A number with decimal spaces, with a value no bigger than 1.1E38 or smaller than -1.1E38
-- DOUBLE: A number with decimal spaces, with a value no bigger than 1.7E308 or smaller than -1.7E308
 
------------ String Types ------------
 
-- CHAR: A character string with a fixed length
-- VARCHAR: A character string with a length that’s variable
-- BLOB: Can contain 2^16 bytes of data
-- ENUM: A character string that has a limited number of total values, which you must define.
-- SET: A list of legal possible character strings. Unlike ENUM, a SET can contain multiple values in comparison to the one legal value with ENUM.
 
------------ Date & Time Types ------------
 
-- DATE: A date value with the format of (YYYY-MM-DD)
-- TIME: A time value with the format of (HH:MM:SS)
-- DATETIME: A time value with the format of (YYYY-MM-DD HH:MM:SS)
-- TIMESTAMP: A time value with the format of (YYYYMMDDHHMMSS)
-- YEAR: A year value with the format of (YYYY)
 
-- 9. Show the table set up
DESCRIBE student;

-- Show the information of a column in a table:
DESCRIBE table_name column_name;

-- 10. Inserting Data into a Table
INSERT INTO student VALUES
  ('Dale', 'Cooper', 'dcooper@aol.com',
  '123 Main St', 'Yakima', 'WA', 98901, '792-223-8901', "1959-2-22",
  'M', NOW(), 3.50, NULL);

-- anter method
INSERT INTO class VALUES
  ('English', NULL), ('Speech', NULL), ('Literature', NULL),
  ('Algebra', NULL), ('Geometry', NULL), ('Trigonometry', NULL),
  ('Art', NULL), ('Gym', NULL);

-- 11. Shows all the student data
SELECT * FROM student;

-- 12. Show all the tables
show tables;
    
-- 13. Altering table - Add a max score column to test
ALTER TABLE test ADD maxscore INT NOT NULL AFTER type;

-- 14. change column name     
ALTER TABLE score CHANGE event_id test_id INT UNSIGNED NOT NULL;

-- 15. ALTER and DROP COLUMN can delete a column
ALTER TABLE absences DROP COLUMN test_taken;
     
-- 16. Show just selected data from the table (Not Case Sensitive)
SELECT FIRST_NAME, last_name
  FROM student;
     
-- 17. Change all the table names
RENAME TABLE
  absence to absences,
  class to classes,
  score to scores,
  student to students,
  test to tests;
     
-- 18. Show every student born in the state of Washington
SELECT first_name, last_name, state
  FROM students
  WHERE state="WA";

-- 19. You can compare values with =, >, <, >=, <=, !=
--     To get the month, day or year of a date use MONTH(), DAY(), or YEAR()
SELECT first_name, last_name, birth_date
    FROM students
    WHERE YEAR(birth_date) >= 1965;

-- 20. a. AND, && : Returns a true value if both conditions are true
--     b. OR, || : Returns a true value if either condition is true
--     c. NOT, ! : Returns a true value if the operand is false
SELECT first_name, last_name, birth_date
    FROM students
    WHERE MONTH(birth_date) = 2 OR state="CA";

-- 21. If you want to check for NULL you must use IS NULL or IS NOT NULL
SELECT last_name
    FROM students
    WHERE last_name IS NULL;
     
SELECT last_name
    FROM students
    WHERE last_name IS NOT NULL;

-- 22. ORDER BY allows you to order results. To change the order use
SELECT first_name, last_name
    FROM students
    ORDER BY last_name;

SELECT first_name, last_name, state
    FROM students
    ORDER BY state DESC, last_name ASC;
     
-- 23. Use LIMIT to limit the number of results
SELECT first_name, last_name
    FROM students
    LIMIT 5;

-- 24. limit with offset - You can also get results 5 through 10
SELECT first_name, last_name
    FROM students
    LIMIT 5, 10;

-- 25. a. CONCAT is used to combine results    
--     b. AS provides for a way to define the column name
SELECT CONCAT(first_name, " ", last_name) AS 'Name',
    CONCAT(city, ", ", state) AS 'Hometown'
    FROM students;

-- 26. a. Matchs any first name that starts with a D, or ends with a n 
--     b. % matchs any sequence of characters
SELECT last_name, first_name
    FROM students
    WHERE first_name LIKE 'D%' OR last_name LIKE '%n';

-- 27. _ matchs any single character
SELECT last_name, first_name
    FROM students
    WHERE first_name LIKE '___y';

-- 28. Returns the states from which students are born because DISTINCT eliminates duplicates in results
SELECT DISTINCT state
    FROM students
    ORDER BY state;

-- 29. COUNT returns the number of matchs, so we can get the number of DISTINCT states from which students were born
SELECT COUNT(DISTINCT state)
    FROM students;

-- 30. COUNT returns the total number of records as well as the total umber of boys
SELECT COUNT(*)
    FROM students;
     
SELECT COUNT(*)
    FROM students
    WHERE sex='M';
     
-- 31. GROUP BY defines how the results will be grouped
SELECT sex, COUNT(*)
    FROM students
    GROUP BY sex;

-- 32. We can get each month in which we have a birthday and the total number for each month
SELECT MONTH(birth_date) AS 'Month', COUNT(*)
    FROM students
    GROUP BY Month
    ORDER BY Month;

-- 33. HAVING allows you to narrow the results after the query is executed
SELECT state, COUNT(state) AS 'Amount'
    FROM students
    GROUP BY state
    HAVING Amount > 1;

-- 34. The Built in Numeric Functions (SLIDE)
-- ABS(x) : Absolute Number: Returns the absolute value of the variable x.
-- ACOS(x), ASIN(x), ATAN(x), ATAN2(x,y), COS(x), COT(x), SIN(x), TAN(x) :Trigonometric Functions .

-- AVG(column_name) : Returns the average of all values in a column. 
SELECT AVG(column_name) FROM table_name;
 
-- CEILING(x) : Returns the smallest number not less than x.
 
-- COUNT(column_name) : Count : Returns the number of non null values in the column. 
SELECT COUNT(column_name) FROM table_name;
 
-- DEGREES(x) : Returns the value of x, converted from radians to degrees.
-- EXP(x) : Returns e^x
-- FLOOR(x) : Returns the largest number not grater than x
-- LOG(x) : Returns the natural logarithm of x
-- LOG10(x) : Returns the logarithm of x to the base 10
-- MAX(column_name) : Maximum Value : Returns the maximum value in the column. 
-- MIN(column_name) : Minimum : Returns the minimum value in the column.
-- MOD(x, y) : Modulus : Returns the remainder of a division between x and y
-- PI() : Returns the value of PI
-- POWER(x, y) : Returns x ^ Y
-- RADIANS(x) : Returns the value of x, converted from degrees to radians
-- RAND() : Random Number : Returns a random number between the values of 0.0 and 1.0
-- ROUND(x, d) : Returns the value of x, rounded to d decimal places
-- SQRT(x) : Square Root : Returns the square root of x
-- STD(column_name) : Standard Deviation 
-- SUM(column_name) : Summation 
-- TRUNCATE(x) : Returns the value of x, truncated to d decimal places

-- 35.  Delete the record in absences
DELETE FROM absences
  WHERE student_id = 6;
           
-- 36. Use UPDATE to change a value in a row
UPDATE scores SET score=25
  WHERE student_id=4 AND test_id=3;

-- 37. Use BETWEEN to find matches between a minimum and maximum
SELECT first_name, last_name, birth_date
    FROM students
    WHERE birth_date
    BETWEEN '1960-1-1' AND '1970-1-1';

-- 38. Use IN to narrow results based on a predefined list of options
SELECT first_name, last_name
    FROM students
    WHERE first_name IN ('Bobby', 'Lucy', 'Andy');

-- ANY means that the condition will be true 
-- if the operation is true for any of the values in the range.
SELECT column_name(s)
  FROM table_name
  WHERE column_name operator ANY
    (SELECT column_name
    FROM table_name
    WHERE condition);

-- ALL means that the condition will be true 
-- only if the operation is true for all values in the range.
SELECT column_name(s)
  FROM table_name
  WHERE column_name operator ALL
    (SELECT column_name
    FROM table_name
    WHERE condition);

-- 39. a. To combine data from multiple tables you can perform a JOIN
--     by matching up common data like we did here with the test ids
--     b. You have to define the 2 tables to join after FROM
--     c. You have to define the common data between the tables after WHERE
SELECT student_id, date, score, maxscore
  FROM tests, scores
  WHERE date = '2014-08-25'
  AND tests.test_id = scores.test_id;
     
-- 40. It is good to qualify the specific data needed by proceeding
--     it with the tables name and a period
SELECT scores.student_id, tests.date, scores.score, tests.maxscore
  FROM tests, scores
  WHERE date = '2014-08-25'
  AND tests.test_id = scores.test_id;
     
     
-- 41. You can JOIN more then 2 tables as long as you define the like
--     data between those tables
SELECT CONCAT(students.first_name, " ", students.last_name) AS Name,
    tests.date, scores.score, tests.maxscore
    FROM tests, scores, students
    WHERE date = '2014-08-25'
    AND tests.test_id = scores.test_id
    AND scores.student_id = students.student_id;
     
-- 42. If we need to include all information from the table listed
--     first "FROM students", even if it does not exist in the table on
--     the right "LEFT JOIN absences", we can use a LEFT JOIN.
SELECT students.student_id,
  CONCAT(students.first_name, " ", students.last_name) AS Name,
  COUNT(absences.date) AS Absences
  FROM students LEFT JOIN absences
  ON students.student_id = absences.student_id
  GROUP BY students.student_id;
     
     
-- 43. An INNER JOIN gets all rows of data from both tables if there
--     is a match between columns in both tables
SELECT students.first_name,
  students.last_name,
  scores.test_id,
  scores.score
  FROM students
  INNER JOIN scores
  ON students.student_id=scores.student_id
  WHERE scores.score <= 15
  ORDER BY scores.test_id;

-- 44. Advanced Mysql topics
-- Create a new view:
CREATE VIEW [IF NOT EXISTS] view_name 
AS 
  select_statement;

-- Create a new view with the WITH CHECK OPTION:
-- The WITH CHECK OPTION prevents 
-- a view from updating or inserting rows that are not visible through it.
CREATE VIEW [IF NOT EXISTS] view_name 
AS select_statement
WITH CHECK OPTION;

-- Rename a view:
RENAME TABLE view_name TO new_view_name;

-- Show views from a database:
SHOW FULL TABLES
[{FROM | IN } database_name]
WHERE table_type = 'VIEW';

-- Create a new trigger:
CREATE TRIGGER trigger_name
{BEFORE | AFTER} {INSERT | UPDATE| DELETE }
ON table_name FOR EACH ROW
trigger_body;

-- Show triggers in a database:
SHOW TRIGGERS
[{FROM | IN} database_name]
[LIKE 'pattern' | WHERE search_condition];

-- Create a stored procedure:
DELIMITER $$
CREATE PROCEDURE procedure_name(parameter_list)
BEGIN
   body;
END $$
DELIMITER ;

-- Show stored procedures:
SHOW PROCEDURE STATUS [LIKE 'pattern' | WHERE search_condition];

-- Create a new stored function:
DELIMITER $$
 CREATE FUNCTION function_name(parameter_list)
RETURNS datatype
[NOT] DETERMINISTIC
BEGIN
 -- statements
END $$
DELIMITER ;

-- Show stored functions:
SHOW FUNCTION STATUS 
[LIKE 'pattern' | WHERE search_condition];
