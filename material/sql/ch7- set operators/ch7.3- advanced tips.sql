--tips

---distinct used only once and in the begining
select distinct department_id, salary
from
employees;

select  department_id, distinct salary
from
employees;
-----------------------------------------------------------
--you can create char datatype without size, it will take default size 1
DROP TABLE EMP_1;

CREATE TABLE EMP_1
( EMPID NUMBER,
FIRST_NAME VARCHAR2(100),
LAST_NAME CHAR
);


INSERT INTO EMP_1 VALUES (1,'khaled','ali');

INSERT INTO EMP_1 VALUES (1,'khaled','a');
-------------------------------------------------------------------------------

--null come last in order asc

1--
SELECT * FROM EMPLOYEES
ORDER BY COMMISSION_PCT;

2--
SELECT * FROM EMPLOYEES
ORDER BY COMMISSION_PCT NULLS LAST;
--so 1 and 2 are the same

SELECT * FROM EMPLOYEES
ORDER BY COMMISSION_PCT NULLS FIRST;
--------------------------------------------------------------------------------

--order by 
SELECT EMPLOYEE_ID, LAST_NAME
FROM 
EMPLOYEES
ORDER BY SALARY+100;

SELECT EMPLOYEE_ID||LAST_NAME test
FROM 
EMPLOYEES
ORDER BY TEST

SELECT EMPLOYEE_ID||LAST_NAME "Test  "
FROM 
EMPLOYEES
ORDER BY "Test  "
----------------------------------------------------------

--replace

select replace ('khaled','al','xx') from dual;

select replace ('khaled','al') from dual; --al will be replace by '' 

--trim
select trim(' khal ed                 ') t from dual;

select trim('k' from 'kkkhakkek') t from dual; -- from begin an end only

select trim('kh' from 'khakkek') t from dual; -- only one char you can use 


--many methods you can do to pick same results
SELECT AVG(SALARY)
FROM EMPLOYEES
WHERE DEPARTMENT_ID = 90;

SELECT AVG(decode(DEPARTMENT_ID,90,SALARY, null) ) 
FROM EMPLOYEES;

/*SELECT decode(DEPARTMENT_ID,90,SALARY, null)  FROM EMPLOYEES;*/
SELECT AVG(
           CASE WHEN DEPARTMENT_ID=90 THEN SALARY 
           ELSE  NULL END 
           ) 
FROM EMPLOYEES;
-----------------------------------------------------------------

--you can not make constraint for long column, or used in  order by  or used in group by 
drop table EMP_2;

CREATE TABLE EMP_2
( EMPID NUMBER PRIMARY KEY,
  NOTES LONG UNIQUE
);

CREATE TABLE EMP_2
( EMPID NUMBER PRIMARY KEY,
  NOTES LONG not null --ok no issue
);

--
select * from EMP_2
order by NOTES;

select EMPID, count(NOTES)
from EMP_2
group by NOTES;


----------------------------------------------------------------
--group by 
SELECT TO_CHAR(HIRE_DATE,'yyyy'), COUNT(EMPLOYEE_ID)
FROM EMPLOYEES
group BY TO_CHAR(HIRE_DATE,'yyyy');

SELECT TO_CHAR(HIRE_DATE,'yyyy'), COUNT(EMPLOYEE_ID)
FROM EMPLOYEES
group BY TO_CHAR(HIRE_DATE,'rr');

SELECT COUNT(EMPLOYEE_ID)
FROM EMPLOYEES
GROUP BY DEPARTMENT_ID;

SELECT COUNT(EMPLOYEE_ID)
FROM EMPLOYEES
GROUP BY (salary-COMMISSION_PCT);

SELECT salary-COMMISSION_PCT,COUNT(EMPLOYEE_ID)
FROM EMPLOYEES
GROUP BY (salary-COMMISSION_PCT);
-------------------------------------------------------------------

--to_char
--the next 5 select give same results
SELECT TO_CHAR(1005.50,'9,999.99') FROM DUAL;
SELECT TO_CHAR(1005.50,'0,000.00') FROM DUAL;
SELECT TO_CHAR(1005.50,'0G000D00') FROM DUAL;
SELECT TO_CHAR(1005.50,'9G999D99') FROM DUAL;
SELECT TO_CHAR(1005.50,'0G909D99') FROM DUAL;

SELECT TO_CHAR(1005.50,'000G909D99') FROM DUAL; --force 2 zero to be displayed
SELECT TO_CHAR(1005.50,'fm000G909D99') FROM DUAL; --format space


SELECT TO_CHAR(1005.50,'9G999.99') FROM DUAL; --IF YOU used G or D, then you can not use . or , 

SELECT TO_CHAR(1005.50,'9,999D99') FROM DUAL; --IF YOU used G or D, then you can not use . or , 

--------------------------------

--all the following give same results

SELECT FIRST_NAME||' work in \'||DEPARTMENT_ID
FROM EMPLOYEES;

SELECT FIRST_NAME||q'[ work in \]'||DEPARTMENT_ID
FROM EMPLOYEES;

SELECT FIRST_NAME||q'( work in \)'||DEPARTMENT_ID
FROM EMPLOYEES;

SELECT FIRST_NAME||q'/ work in \/'||DEPARTMENT_ID
FROM EMPLOYEES;

SELECT FIRST_NAME||q'{ work in \}'||DEPARTMENT_ID
FROM EMPLOYEES;

SELECT FIRST_NAME||q'' work in \''||DEPARTMENT_ID
FROM EMPLOYEES;
---------------------------------------------------------------------------------------------------------------------

--match the data type
SELECT EMPLOYEE_ID,NVL(COMMISSION_PCT,0) 
FROM 
EMPLOYEES;

SELECT EMPLOYEE_ID,NVL(COMMISSION_PCT,'0') --no issue oracle will do implicit conversion
FROM 
EMPLOYEES;

SELECT EMPLOYEE_ID,NVL(COMMISSION_PCT,'no comm') 
FROM 
EMPLOYEES;---data type not match 


SELECT EMPLOYEE_ID,NVL(to_char(COMMISSION_PCT),'no comm') 
FROM 
EMPLOYEES;

SELECT EMPLOYEE_ID,DEPARTMENT_ID, 
decode(DEPARTMENT_ID, 10, 'dept 10',20,'dept 20', DEPARTMENT_ID ) --no issue oracle will do implicit conversion
FROM 
EMPLOYEES; 

SELECT EMPLOYEE_ID,DEPARTMENT_ID,SALARY, 
decode(DEPARTMENT_ID, 10, salary+10 ,20,salary+20, 'n/a' ) raise_sal
FROM 
EMPLOYEES; 


SELECT EMPLOYEE_ID,DEPARTMENT_ID,SALARY, 
decode(DEPARTMENT_ID, 10, to_char(salary+10) ,20,to_char(salary+20), 'n/a' ) raise_sal
FROM 
EMPLOYEES
ORDER BY DEPARTMENT_ID;

-------------------------------------------


--implicit conv for date

select * from EMPLOYEES
where hire_date='17-JUN-03'; --this is the default date format dd-MON-rr

select * from EMPLOYEES
where hire_date='17-jun-03';

select * from EMPLOYEES
where hire_date='17-jun-2003';

select * from EMPLOYEES
where hire_date='17-june-2003';

select * from EMPLOYEES
where hire_date='17-06-2003'; -- it can only convert when the format day(number)- month(any valid char)-year(number)
----------------

--create empty table as a copy

drop table xx_emp_zz;

create table xx_emp_zz
as select * from employees
where 1=2; -- this condition will never be true

select * from xx_emp_zz;

------------------------------------------------------------

--fetch
select * from employees
where salary is not null
order by salary desc
fetch first 5 rows only; --also you can make ( fetch next 5 rows only )

select * from employees
order by salary desc
fetch first 5 rows only;

select * from employees
order by salary desc
fetch first 5 rows with ties; ---this is not allowed fetch first 5 rows only with ties

select * from employees
order by salary desc
fetch first 4 percent row only;

select * from employees
order by salary desc
fetch first 4 percent row with ties; ---this is not allowed  fetch first 4 percent row only with ties
----------------------------------------------------------------------------------------



---------------------------------------------------------------
























  
  