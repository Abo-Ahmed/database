

-- -------------
-- Data manipulation language
-- -------------

-- Select

-- ARITHEMATIC OPEARTION
SELECT LAST_NAME, SALARY, SALARY + 300
FROM EMPLOYEES;

-- ALIAS
SELECT LAST_NAME "NAME" , SALARY*12 "ANNUAL SALARY"
FROM EMPLOYEES;

-- CONCATENATION OPERATOR
SELECT  LAST_NAME || JOB_ID AS "EMPLOYEES"
FROM   EMPLOYEES;

-- 	ALTERNATVE QUOTE
SELECT DEPARTMENT_NAME || 
Q'[, IT'S ASSIGNED MANAGER ID: ]' || MANAGER_ID AS "DEPARTMENT AND MANAGER" FROM DEPARTMENTS;

'
-- To get table columns and constrains 
DESC TABLE_NAME

-- to get all tables owned by user connect it then
SELECT TABLESPACE_NAME, TABLE_NAME FROM USER_TABLES;
SELECT * FROM TAB ;

-- WHERE WITH ADVANCED WORK
SELECT LAST_NAME, SALARY
FROM EMPLOYEES
WHERE SALARY <> 3000 
AND SALARY BETWEEN 2500 AND 3500
AND MANAGER_ID IN (100, 101, 201)
AND FIRST_NAME LIKE 'S%'
OR MANAGER_ID IS NULL
OR JOB_ID 
NOT IN ('IT_PROG', 'ST_CLERK', 'SA_REP') ;

-- USING SCAPE OPERATOR TO SEARCH FOR % 
SELECT MYCOL FROM MYTABLE WHERE MYCOL LIKE '%\%%';
// HERE WE SCAPED THE MIDDLE %

-- ORDER BY
SELECT LAST_NAME, DEPARTMENT_ID, SALARY
FROM EMPLOYEES
ORDER BY DEPARTMENT_ID, SALARY DESC;

-- SUBUSTITUTION VARIABLE
SELECT EMPLOYEE_ID, LAST_NAME, SALARY, DEPARTMENT_ID &COLUMN_NAME
FROM EMPLOYEES
WHERE &CONDITION
OR EMPLOYEE_ID = &EMPLOYEE_NUM 
OR JOB_ID = '&JOB_TITLE'
ORDER BY &ORDER_COLUMN;

-- REUSE THE SUBSTITIUTION VARIABLE
SELECT EMPLOYEE_ID, LAST_NAME, JOB_ID, &&COLUMN_NAME
FROM EMPLOYEES
ORDER BY &COLUMN_NAME ;

-- SELECT WITH COLUMN NUMBER AND ORDER WITH ONE UP AND ONE DOWN
SELECT LNAME, JOB, SALARY FROM TRAINER
WHERE  STATE = ‘GIZA’
ORDER BY  3  DESC,  2;

-- SELECT ‘FIXED_STRING’ FROM TABEL_NAME;
-- CORRELATED SUB-QUERY WITH EXISTS - RETURNS FALSE FOR EMPTY SET
SELECT DISTINCT ORDER_ID FROM ORDER_LINE_T
WHERE EXISTS (SELECT * FROM PRODUCT_T 
WHERE PRODUCT_ID = ORDER_LINE_T.PRODUCT_ID 
AND PRODUCT_FINISH = ‘NATURAL ASH’);

-- SELECT PRODUCT_DESCRIPTION, STANDARD_PRICE, AVGPRICE
FROM (SELECT AVG(STANDARD_PRICE) AVGPRICE FROM PRODUCT_T),
PRODUCT_T
WHERE STANDARD_PRICE > AVGPRICE;

-- DEFINE VARIABEL
DEFINE EMPLOYEE_NUM = 200

-- WORING WITH DATE
SELECT LAST_NAME, HIRE_DATE FROM EMPLOYEES
WHERE HIRE_DATE < '01-FEB-88';

-- SUBTRACT TWO DATES TO FIND THE NUMBER OF DAYS BETWEEN THEM
-- DISTINCT WITH SELECT STATEMENTS SO YOU CAN SELECT UNIQUE COLOUM VALUES OR UNIQUE TOTAL ROW VALUES
-- DUAL is an empty table that we can use to do operation on select;

-- SQL FUNCTIONS:

-- SINGLE FUNCTIONS
-- CHARACTER
LOWER
UPPER
INITCAP
CONCAT('HELLO', 'WORLD') 
SUBSTR('HELLOWORLD',1,5) 
LENGTH('HELLOWORLD') 
INSTR('HELLOWORLD', 'W') 
LPAD(SALARY,10,'*') 
RPAD(SALARY, 10, '*') 
REPLACE ('JACK AND JUE','J','BL') 
TRIM('H' FROM 'HELLOWORLD'

-- NUMBERS
ROUND(45.926, 2) 
TRUNC(45.926, 2) 
MOD(1600, 300)

-- DATE
MONTHS_BETWEEN ('01-SEP-95','11-JAN-94')
ADD_MONTHS ('11-JAN-94',6) 
NEXT_DAY ('01-SEP-95','FRIDAY') 
LAST_DAY ('01-FEB-95')
ROUND(SYSDATE,'MONTH') 
ROUND(SYSDATE ,'YEAR') 
TRUNC(SYSDATE ,'MONTH') 
TRUNC(SYSDATE ,'YEAR')
TO_CHAR(NUMBER, 'FORMAT_MODEL')
TO_CHAR(DATE, 'FORMAT_MODEL')
TO_NUMBER(CHAR[, 'FORMAT_MODEL'])
TO_DATE(CHAR[, 'FORMAT_MODEL'])

-- GENERAL 
NVL (EXPR1, EXPR2)
NVL2 (EXPR1, EXPR2, EXPR3)
NULLIF (EXPR1, EXPR2)
COALESCE (EXPR1, EXPR2, ..., EXPRN)

CASE JOB_ID WHEN 'IT_PROG' THEN 1.10*SALARY
WHEN 'ST_CLERK' THEN 1.15*SALARY
WHEN 'SA_REP' THEN 1.20*SALARY
ELSE SALARY END

DECODE(JOB_ID, 'IT_PROG', 1.10*SALARY,
'ST_CLERK', 1.15*SALARY,
'SA_REP', 1.20*SALARY,
SALARY)

-- GROUP FUNCTION

AVG 
COUNT -- COUNTS NUMBER OF NON NULL ROWS / CAN USE DISTINCT
MAX  -- CAN BE USED WITH CHARACGER , NUMBER AND DATE
MIN  -- CAN BE USED WITH CHARACGER , NUMBER AND DATE
SUM


-- CONSTRAINT ANY ATTRIBUTE WRITEN BESIDE THE GROUP FUNCTION SHOULD BE ADDED IN THE GROUP BY

SELECT DEPARTMENT_ID , AVG (SALARY ) FROM EMPLOYEES
GROUP BY DEPARTMENT_ID ;

-- GROUP WITH TWO PARAMATERS
SELECT DEPARTMENT_ID DEPT_ID, JOB_ID, SUM(SALARY)
FROM EMPLOYEES
GROUP BY DEPARTMENT_ID, JOB_ID
HAVING MAX(SALARY)>10000 ;

-- TABLE IN ANTHER USER
SELECT * FROM USERA.EMPLOYEES;

-- Update
-- UPDATE EMPLOYEES
SET DEPARTMENT_ID = 55
WHERE DEPARTMENT_ID = 110;

-- Delete - if we don’t use where clause it will delete all rows 

DELETE FROM DEPARTMENTS
WHERE DEPARTMENT_ID = 60;

-- DELETE WITH SUB-QUARY
DELETE FROM EMPLOYEES
WHERE DEPARTMENT_ID =
(SELECT DEPARTMENT_ID FROM DEPARTMENTS
WHERE DEPARTMENT_NAME LIKE '%PUBLIC%');

-- WE SHOULD COMMIT AFTER WE UPDATE , DELETE , INSERT IN THE DATA SO WE KEEP CHANGES WE MADE IN DATA

-- Insert
INSERT INTO DEPARTMENTS(DEPARTMENT_ID, 
DEPARTMENT_NAME, MANAGER_ID, LOCATION_ID)
VALUES (70, 'PUBLIC RELATIONS', 100, 1700);

--  OPTIONALLY, LIST THE COLUMNS IN THE INSERT CLAUSE
-- INSERT WITH SUB-QUARY - WE DON’T USE VALUES CLAUSE
INSERT INTO SALES_REPS(ID, NAME, SALARY, COMMISSION_PCT)
SELECT EMPLOYEE_ID, LAST_NAME, SALARY, COMMISSION_PCT
FROM EMPLOYEES
WHERE JOB_ID LIKE '%REP%';

-- -------------
-- Data Definition language
-- -------------
-- if two entities has dependent relations, we need to make them 
-- then we alter one of them with the new relation, we create tables in order of dependency
-- then we check the constrains of each data

CREATE TABLE JOB( 
JO_ID VARCHAR2(3) PRIMARY KEY ,
JOB_NO VARCHAR2(20) DEFAULT 1200 ,
MINSAL NUMBER(4) UNIQUE NOT NULL ) ;

-- CREATING A TABLE USING SUB-QUERY
CREATE TABLE DEPT80
AS 
SELECT EMPLOYEE_ID, LAST_NAME, 
SALARY*12 ANNSAL, 
HIRE_DATE
FROM EMPLOYEES
WHERE DEPARTMENT_ID = 80;

-- CONSTRAINS IN TABLE CREATION
PRIMARY KEY
FOREIGN KEY
NOT NULL
UNIQUE
CHECKS

-- CREATIG INDEX 
CREATE INDEX NAME_IDX ON CUSTOMER_T(CUSTOMER_NAME);

-- DELETING INDEX 
DROP INDEX NAME_IDX;

-- NAME CONSTRAINT IN THE SAME LINE
EMPLOYEE_ID NUMBER(6) CONSTRAINT EMP_EMP_ID_PK PRIMARY KEY

-- NAME CONSTRAINT IN THE END OF TABLE CREATION 
CONSTRAINT EMP_EMP_ID_PK PRIMARY KEY (EMPLOYEE_ID)
CONSTRAINT EMP_EMAIL_UK UNIQUE(EMAIL)
CONSTRAINT EMP_PRI PRIMARY KEY (EMP_ID , EMP_NAME)
CHECK ( EMP_NAME IN ( ‘MAHMOUD ’ , ‘ALI’) )

-- FOREIGN KEY NAMING IN THE LAST LINE
CONSTRAINT EMP_DEPT_FK FOREIGN KEY (DEPARTMENT_ID) REFERENCES DEPARTMENTS(DEPARTMENT_ID)

-- CHECK INPUT RANGE FOR AN ATTRIBUTE
CONSTRAINT EMP_SALARY_MIN CHECK (SALARY > 0)

-- to delete a table - You cannot roll back the DROP TABLE statement
DROP TABLE DEPT80;

-- ALTER
ALTER TABLE DEPARTMENT DROP COLUMN HEAD_ID ;
ALTER TABLE DEPARTMENT ADD HEAD_ID NUMBER(11) REFERENCES EMPLOYEE(EMP_ID);
ALTER TABLE TABLE_NAME RENAME TO NEW_TABLE_NAME;
ALTER TABLE SUPPLIER MODIFY SUPPLIER_NAME   VARCHAR2(100)  NOT NULL;
ALTER TABLE SUPPLIER RENAME COLUMN SUPPLIER_NAME TO SNAME;

-- Truncate - delete all rows in tables and leave it empyt
TRUNCATE TABLE COPY_EMP;

-- All join types
SELECT TABLE1.COLUMN, TABLE2.COLUMN
FROM TABLE1
[NATURAL JOIN TABLE2] |
[JOIN TABLE2 USING (COLUMN_NAME)] |
[JOIN TABLE2 ON (TABLE1.COLUMN_NAME = TABLE2.COLUMN_NAME)]|
[LEFT|RIGHT|FULL OUTER JOIN TABLE2 ON (TABLE1.COLUMN_NAME = TABLE2.COLUMN_NAME)]|
[CROSS JOIN TABLE2];

-- USING TABLE ALAISEES
SELECT E.EMPLOYEE_ID, E.LAST_NAME, D.LOCATION_ID, DEPARTMENT_ID
FROM EMPLOYEES E JOIN DEPARTMENTS D
USING (DEPARTMENT_ID);

-- JOIN WITH ADDITIONAL CONDITIONS
SELECT E.EMPLOYEE_ID, E.LAST_NAME, E.DEPARTMENT_ID, D.DEPARTMENT_ID, D.LOCATION_ID
FROM EMPLOYEES E JOIN DEPARTMENTS D
ON (E.DEPARTMENT_ID = D.DEPARTMENT_ID)
AND E.MANAGER_ID = 149;

-- MULTIPLE JOIN
SELECT EMPLOYEE_ID, CITY, DEPARTMENT_NAME
FROM EMPLOYEES E 
JOIN DEPARTMENTS D
ON D.DEPARTMENT_ID = E.DEPARTMENT_ID 
JOIN LOCATIONS J
ON E.SALARY BETWEEN J.LOWEST_SAL AND J.HIGHEST_SAL;

-- OUTER JOIN GET DATA OF MATCHED AND UNMATCHE DATA
SELECT E.LAST_NAME, D.DEPARTMENT_ID, D.DEPARTMENT_NAME
FROM EMPLOYEES E FULL/LEFT/RIGHT OUTER JOIN DEPARTMENTS 
ON (E.DEPARTMENT_ID = D.DEPARTMENT_ID);

-- Sub-queries
SELECT LAST_NAME FROM EMPLOYEES
WHERE SALARY >
(SELECT SALARY FROM EMPLOYEES WHERE LAST_NAME = 'ABEL');

-- SUB-QUERIE WITH HAVINGG
SELECT DEPARTMENT_ID, MIN(SALARY)
FROM EMPLOYEES GROUP BY DEPARTMENT_ID
HAVING MIN(SALARY) >
(SELECT MIN(SALARY)FROM EMPLOYEES WHERE DEPARTMENT_ID = 50);

-- MULTIPLE SUB-QUERY USING ANY / ALL / IN
SELECT EMPLOYEE_ID, LAST_NAME, JOB_ID, SALARY FROM EMPLOYEES
WHERE SALARY < ALL/ANY
(SELECT SALARY FROM EMPLOYEES WHERE JOB_ID = 'IT_PROG');


-- -------------
-- Data control language
-- -------------

CLEAR SCREEN

-- any command must end with semi-colon, user can add new database
-- but admin has rule to adjust database
CREATE USER SOFTWARE IDENTIFIED BY PASSWORD;

-- should give privilege to user to connect
ALTER USER HR ACCOUNT UNLOCK;

-- to connect as admin
CONNECGT SYSTEM
ALTER USER HR IDENTIFIED BY PASSWORD2 ; 
GRANT CONNECT TO SOFTWARE;

-- give user privilege to create
GRANT RESOURCE TO SOFTWARE;

-- in column level references means foreign key
-- in table level we must use foreign key keyword

-- at start
CONNECT SOFTWARE
PASSWORD

-- A DDL or DCL statement executes (automatic commit).

-- We can create save point inside our work
SAVEPOINT UPDATE_DONE
-- To return to this save point
ROLLBACK TO UPDATE_DONE

BEGIN TRANSACTION/END TRANSACTION TO MAKE TANSACTION BAUNDARY
EXEC PRODUCT_LINE_SALE TO EXECUTE FUNCION OR PRECEDURE

-- Set operators - the expressions in the SELECT lists must match in number and data type.

-- UNION - GET BOTH QUERIES WITHOUT DUPLICATION
SELECT EMPLOYEE_ID, JOB_ID FROM EMPLOYEES
UNION
SELECT EMPLOYEE_ID, JOB_ID FROM JOB_HISTORY;

-- UNION ALL - GET BOTH QUERIES WITH DUPLICATION 
SELECT EMPLOYEE_ID, JOB_ID, DEPARTMENT_ID
FROM EMPLOYEES
UNION ALL
SELECT EMPLOYEE_ID, JOB_ID, DEPARTMENT_ID
FROM JOB_HISTORY ORDER BY EMPLOYEE_ID;

-- INTERSECTION - RETURN DATA IN BOTH QUERIES
SELECT EMPLOYEE_ID, JOB_ID FROM EMPLOYEES
INTERSECT
SELECT EMPLOYEE_ID, JOB_ID FROM JOB_HISTORY;

-- MINUS - ROWS OF FIRST QUERY WITHOUT THE SECOND ONE
-	SELECT EMPLOYEE_ID,JOB_ID
FROM EMPLOYEES
MINUS
SELECT EMPLOYEE_ID,JOB_ID
FROM JOB_HISTORY;

-- CREATE TRIGGER T_NAME 
{BEFORE/AFTER/INSTEAD OF}{INSERT/DELETE/UPDATE} ON T_NAME
[FOR EACH {ROW/STATEMENT} ][WHEN CONDTION]
< TRIGGER SQL HERE>

-- CREATING VIEW
CREATE VIEW EXPENSIVE_STUFF_V AS
SELECT PRODUCT_ID, PRODUCT_NAME, UNIT_PRICE
FROM PRODUCT_T
WHERE UNIT_PRICE >300
WITH CHECK_OPTION;