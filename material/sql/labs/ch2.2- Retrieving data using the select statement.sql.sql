--this is a single line comment

/* this is
multi lines
comments
*/

/*
Capabilities of SQL SELECT Statements
Arithmetic expressions and NULL values in the SELECT statement
Column Aliases
Use of concatenation operator, literal character strings, alternative quote operator, and the DISTINCT keyword
DESCRIBE command
*/


--1 to select all the columns/rows in a table use:
SELECT * 
FROM employees;

SELECT * 
FROM departments;

--2 to select specific columns

SELECT DEPARTMENT_ID, DEPARTMENT_NAME
FROM   DEPARTMENTs;




--3 using Arithmetic Expressions ( +,-,*,/)

SELECT EMPLOYEE_ID, FIRST_NAME, SALARY
FROM
employees;

SELECT EMPLOYEE_ID, FIRST_NAME, SALARY, sALARY+100, salary+(SALARY*0.10)
FROM
employees;

--4 to know null values 
--NULL IS A VALUE THAT IS UNAVAILABLE, UNASSIGNED, UNKNOWN, OR INAPPLICABLE.
---Null is not the same as zero or a blank space
SELECT last_name, job_id, salary, commission_pct
FROM   EMPLOYEES;

--5 Arithmetic expressions containing a null value evaluate to null

SELECT LAST_NAME, JOB_ID, SALARY, COMMISSION_PCT,COMMISSION_PCT+10
FROM   EMPLOYEES;

--6  Defining a Column Alias ( Renames a column heading)
SELECT LAST_NAME, LAST_NAME AS name, LAST_NAME  lname, LAST_NAME " LAST nAME"
FROM   EMPLOYEES;

--7 Concatenation Operator ||Links columns or character strings 
--Literal (A literal is a character, a number, or a date that is included in the SELECT statement)

SELECT FIRST_NAME, LAST_NAME, FIRST_NAME||LAST_NAME "full name", 
FIRST_NAME||' '||LAST_NAME "full name with space" --Using Literal Character Strings
from
EMPLOYEES;

SELECT FIRST_NAME||' work in department '|| DEPARTMENT_ID
FROM
EMPLOYEES;


SELECT FIRST_NAME||q'[ work in department]'|| DEPARTMENT_ID
FROM
EMPLOYEES;

SELECT FIRST_NAME||q'( work in department)'|| DEPARTMENT_ID
FROM
EMPLOYEES;

--8 using distinct 

SELECT DEPARTMENT_ID
FROM   EMPLOYEES; -- this will pick all the DEPARTMENT_ID from table EMPLOYEES

SELECT DISTINCT DEPARTMENT_ID
FROM   EMPLOYEES; -- only distinct values  ????? ????????

--you can use many columns in distinct

SELECT DISTINCT DEPARTMENT_ID, JOB_ID
FROM EMPLOYEES

--9 DESCRIBE or DESC command
--USE THE DESCRIBE COMMAND TO DISPLAY THE STRUCTURE OF A TABLE.

DESCRIBE EMPLOYEES; 

DESC EMPLOYEES;






