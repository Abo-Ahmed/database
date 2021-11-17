
-- Connect to MySQL server using mysql  
-- command-line client with a username and password 
mysql -u [username] -p;

-- with specific database
mysql -u [username] -p [database];

-- Exit mysql command-line client:
exit;

-- Export data using mysqldump tool
mysqldump -u [username] -p [database] > data_backup.sql;

-- To clear MySQL screen console window on Linux, you use the following command:
mysql> system clear;

-- Create a database with a specified name if it does not exist in the database server
CREATE DATABASE [IF NOT EXISTS] database_name;

Use a database or change the current database
-- USE database_name;

-- Drop a database with a specified name permanently
DROP DATABASE [IF EXISTS] database_name;

-- Show all available databases in the current MySQL database server
SHOW DATABASE;

-- Show all tables in a current database.
SHOW TABLES;

-- Show the columns of a table:
DESCRIBE table_name;

-- using limit in queries
SELECT * FROM Customers
WHERE Country='Germany'
LIMIT 3;

-- Show the information of a column in a table:
DESCRIBE table_name column_name;

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

-- MySQL uses the AUTO_INCREMENT keyword to perform an auto-increment feature.
-- By default, the starting value for AUTO_INCREMENT is 1, and it will 
-- increment by 1 for each new record.
CREATE TABLE Persons (
    Personid int NOT NULL AUTO_INCREMENT,
    LastName varchar(255) NOT NULL,
    FirstName varchar(255),
    Age int,
    PRIMARY KEY (Personid)
);

-- we can define start of the sequence
ALTER TABLE Persons AUTO_INCREMENT=100;

-- Update with join
UPDATE 
    table1, 
    table2
INNER JOIN table1 ON table1.column1 = table2.column2
SET column1 = value1,
WHERE condition;

