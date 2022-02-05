/*
Use substitution variables to:
Temporarily store values with single-ampersand (&) and double-ampersand (&&) substitution
Use substitution variables to supplement the following:
WHERE conditions
ORDER BY clauses
Column expressions
Table names
Entire SELECT statements
*/
--1
SELECT employee_id, last_name, salary, department_id
FROM   EMPLOYEES
WHERE  EMPLOYEE_ID = &EMPLOYEE_NUM ;--when using single & the variable will be discareded after is used 

--use '' when using varchar
--2
SELECT employee_id, first_name,last_name, salary, department_id
FROM   EMPLOYEES
where FIRST_NAME='&ename'
ORDER BY 2;

--another way to handel varchar to wirte the '' included in variable example 'Adam'
--3
SELECT employee_id, first_name,last_name, salary, department_id
FROM   EMPLOYEES
WHERE FIRST_NAME=&ename
ORDER BY 2;

--Specifying Column Names, Expressions, and Text
--&column_name=salary  &condition=salary>10000   &ORDER_COLUMN=employee_id
--4
SELECT employee_id, last_name, job_id,&column_name
FROM   employees
WHERE  &condition
ORDER BY &ORDER_COLUMN ;

--5
/*
Use the DEFINE command to create and assign a value to a variable.
Use the UNDEFINE command to remove a variable
*/


DEFINE EMPLOYEE_NUM = 200; -- this variable is valid for the session only

SELECT employee_id, last_name, salary, department_id
FROM   employees
WHERE  EMPLOYEE_ID = &EMPLOYEE_NUM ;

UNDEFINE EMPLOYEE_NUM

--6  you can change the prompt message as follow
--but it should exected as script
ACCEPT DEPT_ID PROMPT 'please enter dept id' ;
SELECT * FROM EMPLOYEES
WHERE DEPARTMENT_ID=&DEPT_ID;

UNDEFINE DEPT_ID

ACCEPT emp_from PROMPT 'please enter EMPLOYEE from ' ;
ACCEPT emp_to PROMPT 'please enter EMPLOYEE to ' ;
SELECT * FROM EMPLOYEES
WHERE EMPLOYEE_id between &emp_from and &emp_to;

UNDEFINE emp_from
UNDEFINE emp_to

--7  Using the Double-Ampersand Substitution Variable
---the && define the variable and assign the value in the same time , then you can re-use it agian
select * from DEPARTMENTS where DEPARTMENT_ID=&&p;

undefine p

SELECT   employee_id, last_name, job_id, &&column_name --this =define column_name
FROM     EMPLOYEES
ORDER BY &COLUMN_NAME ;

undefine column_name;


/*
8  Use the VERIFY command to toggle the display of the substitution variable, 
both before and after SQL Developer replaces substitution variables with values:
*/

--also should be executed as script 
SET VERIFY ON
SELECT employee_id, last_name, salary
FROM   employees
WHERE  EMPLOYEE_ID = &E_NUM;

--8 using set define off
--we use it to prevent oracle server to display the prompt window for specifc resons

SELECT * FROM DEPARTMENTS
WHERE DEPARTMENT_NAME LIKE '%&t%';--here the oracle server suppose that & is variable

--so we use set define off

SET DEFINE OFF;

SELECT * FROM DEPARTMENTS
WHERE DEPARTMENT_NAME LIKE '%&t%';

--you can use set define on  to show again the prompt window when using &

SET DEFINE ON;














