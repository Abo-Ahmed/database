--for more info  https://docs.oracle.com/database/121/SQLRF/functions002.htm#SQLRF20032
-- character functions
--there are 2 types for character functions
--case conversion functions  and  character manipulation

--1 case conversion functions ( upper, lower, initcap )

SELECT EMPLOYEE_ID, FIRST_NAME,upper(FIRST_NAME), lower(FIRST_NAME),initcap(first_name) 
FROM EMPLOYEES;
--please look to first_name: Jose Manuel and see the initcap who it work
--single row function can be used in select, where, order by 

SELECT EMPLOYEE_ID, FIRST_NAME,UPPER(FIRST_NAME), LOWER(FIRST_NAME),INITCAP(FIRST_NAME) 
FROM EMPLOYEES
WHERE UPPER(FIRST_NAME)='PATRICK';

SELECT EMPLOYEE_ID, FIRST_NAME,UPPER(FIRST_NAME), LOWER(FIRST_NAME),INITCAP(FIRST_NAME) 
FROM EMPLOYEES
WHERE UPPER(FIRST_NAME)=UPPER('patrick')
ORDER BY UPPER(FIRST_NAME); --this example perferct when creating search screens

--2 character manipulation functions

--concat function
SELECT EMPLOYEE_ID,FIRST_NAME, LAST_NAME, CONCAT(FIRST_NAME,LAST_NAME)
FROM EMPLOYEES;
--the concat function only took 2 args, but || more flixable
SELECT EMPLOYEE_ID,FIRST_NAME, LAST_NAME, FIRST_NAME||' '||LAST_NAME||salary name
FROM EMPLOYEES;

--substr function
--substr(column|expersion ,m,n)
--m is the starting posistion, n the characters long 
SELECT EMPLOYEE_ID, 
FIRST_NAME, 
SUBSTR(FIRST_NAME,1,3), 
SUBSTR(FIRST_NAME,2,4),
SUBSTR(FIRST_NAME,2), --if you didnt specify the n value, then it will be to the end of string
SUBSTR(FIRST_NAME,-3)--if m is negative , then the count start from the end
FROM EMPLOYEES;

--length function
SELECT FIRST_NAME, LENGTH(FIRST_NAME)
FROM EMPLOYEES;--it take char and return number

--instr function
--instr function
--instr(column|expersion ,m,n)
--m is the start searching position , n the occourence
--1 is the default for m and n
SELECT FIRST_NAME, 
INSTR(FIRST_NAME,'e') ,
INSTR(FIRST_NAME,'e',2),
INSTR(FIRST_NAME,'e',5),
INSTR(FIRST_NAME,'e',1,2)
FROM EMPLOYEES
where FIRST_NAME='Nanette';


--lpad and rpad
SELECT EMPLOYEE_ID, FIRST_NAME, SALARY, LPAD(SALARY,10,'#'), rPAD(SALARY,10,'*')
FROM EMPLOYEES;

--replace function

SELECT EMPLOYEE_ID, FIRST_NAME,replace(FIRST_NAME,'a','*'),replace(FIRST_NAME,'en','#')
FROM EMPLOYEES;


--trim function
--to understnd trim in very good way, we will try to do examples using dual table
--dual is a public table that you can use to view result from functions and calculation

SELECT * FROM DUAL;
-- so it is a table contain one column and ony dummy value x

SELECT 1+1+3 FROM DUAL;

SELECT 1+5 FROM EMPLOYEES;--it will show the results but the number of results equal number of records


--TRIM( [ [ LEADING | TRAILING | BOTH ] trim_character FROM ] string1 )

SELECT TRIM (' ' FROM '  khaled khudari  ') V  FROM DUAL;

SELECT TRIM (LEADING ' ' FROM '  khaled khudari  ') V  FROM DUAL; 


SELECT TRIM (TRAILING ' ' FROM '  khaled khudari  ') V  FROM DUAL; 


SELECT TRIM (BOTH ' ' FROM '  khaled khudari  ') V  FROM DUAL;


SELECT TRIM ('k' FROM 'khaled khudari') V  FROM DUAL; 


SELECT TRIM (LEADING 'k' FROM 'khaled khudari') V  FROM DUAL; 

SELECT TRIM (TRAILING 'k' FROM 'khaled khudari') V  FROM DUAL; 

SELECT TRIM ('  khaled       khudai  ') v  FROM DUAL;




