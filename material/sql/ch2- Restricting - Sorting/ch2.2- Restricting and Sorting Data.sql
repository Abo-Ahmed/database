--1 to select all the rows and columns in table

SELECT * FROM EMPLOYEES;

--2 to Limiting the Rows That Are Selected, we use WHERE and it come always after the FROM clause
--first look to the manual
SELECT * 
FROM EMPLOYEES
WHERE DEPARTMENT_ID=90;

SELECT * 
FROM EMPLOYEES
WHERE salary=24000;

/* these you should know when using the where 
Character strings and date values are enclosed with single quotation marks.
Character values are case-sensitive and date values are format-sensitive.
The default date display format is DD-MON-RR
*/

--3 using where in char column 
SELECT EMPLOYEE_ID, FIRST_NAME, last_name, JOB_ID
FROM
EMPLOYEES
WHERE FIRST_NAME='Steven';

SELECT EMPLOYEE_ID, FIRST_NAME, last_name, JOB_ID
FROM
EMPLOYEES
WHERE FIRST_NAME='steven'; -- the data is Case sensitive

--4 using where in date column
SELECT * 
FROM   employees
WHERE  HIRE_DATE = '17-OCT-03' ;

--5 using the comparison operators

SELECT * FROM EMPLOYEES
WHERE SALARY>=10000;

SELECT * 
FROM   employees
WHERE  HIRE_DATE > '17-OCT-03' ;

SELECT * FROM EMPLOYEES
WHERE FIRST_NAME>'Alberto';

SELECT * FROM EMPLOYEES
WHERE FIRST_NAME>'Alberto'
order by FIRST_NAME;

SELECT * FROM EMPLOYEES
WHERE FIRST_NAME<'Alberto'
order by FIRST_NAME;

--for more info refer to https://docs.oracle.com/cd/B12037_01/server.101/b10759/sql_elements002.htm

--6 using between and 

SELECT * FROM EMPLOYEES
WHERE SALARY BETWEEN 10000 AND 20000; --always the  lower limit first, then higher limit


--try to do the query by making the high limit first, no result
SELECT * FROM EMPLOYEES
WHERE SALARY BETWEEN 20000 AND 10000;

--YOU CAN USE OPERATORS ALSO IN varchar COLUMNS
SELECT * FROM EMPLOYEES
WHERE FIRST_NAME BETWEEN 'A' AND 'C'
order by FIRST_NAME;  

SELECT * FROM EMPLOYEES
order by FIRST_NAME

-------------------------------------------------------------------------------------------------------------

--7  using the in operator
SELECT * FROM EMPLOYEES
WHERE SALARY IN (10000, 25000,17000);--the order is not important

/*8 using the like operator and it come usualy with _ and %
% mean zero or more characters
_ mean one character
*/

SELECT * FROM EMPLOYEES
WHERE FIRST_NAME LIKE 'S%'; --ALL THE FIRST NAME which sart with S

SELECT * FROM EMPLOYEES
WHERE FIRST_NAME LIKE '%s'; --ALL THE FIRST NAME which end  with s

SELECT * FROM EMPLOYEES
WHERE FIRST_NAME LIKE '%am%'; --ALL THE FIRST NAME which include am 

SELECT * FROM EMPLOYEES
WHERE FIRST_NAME LIKE '_d%';-- the first_name which has d in second letter

SELECT * FROM EMPLOYEES
WHERE FIRST_NAME LIKE '__s%';-- the first_name which has s in third letter

--now supose there is value in any column contain _  or %  ( example job_id)
--then how you will search for theses Letters
--example i need all the job_id which contain the string SA_
--let us add new job called SAP cons
--if you try this select what will happen
--this will pick all the job_id contain SA followed by any character 
SELECT JOB_ID 
FROM
JOBS
WHERE JOB_ID LIKE 'SA_%'; 

--this is the correct select 
SELECT JOB_ID 
FROM
JOBS
WHERE JOB_ID LIKE 'SA/_%' escape '/';



--9 using is null operator

select first_name, COMMISSION_PCT
from EMPLOYEES;

--let us try to pick all the employes who doesnt have commesion
SELECT * 
FROM EMPLOYEES
where COMMISSION_PCT is null; --dont use COMMISSION_PCT=' ' because this not correct 

SELECT * 
FROM EMPLOYEES
where COMMISSION_PCT=null;-- this not correct 

--10 using not
--you can use also not like, not in , is not null , not between  and 

SELECT * 
FROM EMPLOYEES
WHERE EMPLOYEE_ID NOT IN (100, 101);

SELECT * 
FROM EMPLOYEES
where COMMISSION_PCT is not null;

SELECT * FROM EMPLOYEES
WHERE FIRST_NAME not LIKE 'S%'; --ALL THE FIRST NAME which not sart with S

-----the next 2 queries the same
select * 
from employees
where DEPARTMENT_ID<>50;

select * 
from employees
where DEPARTMENT_ID !=50;

-------------------------------------------------------------------------------------------

--11  Defining Conditions Using the Logical Operators ( and/ or /  not )
--AND requires both the component conditions to be true
SELECT employee_id, last_name, job_id, salary, DEPARTMENT_ID
FROM   employees
WHERE  SALARY >= 10000
AND    DEPARTMENT_ID=90;

--OR requires either component condition to be true
SELECT employee_id, last_name, job_id, salary, DEPARTMENT_ID
FROM   employees
WHERE  SALARY >= 10000
or    DEPARTMENT_ID=90;

---let's SEE THIS 3 AND
SELECT employee_id, last_name, job_id, salary, DEPARTMENT_ID,COMMISSION_PCT
FROM   employees
WHERE  SALARY > 2000
AND    DEPARTMENT_ID in (60,90)
and COMMISSION_PCT is null


--here you should know  the priorities
--look to manual hint 
--in this select there are 2 conditions
--first condition  JOB_ID = 'AD_PRES' and SALARY > 15000
--second condition JOB_ID = 'SA_REP'
--10+5*5 =
SELECT last_name, job_id, salary
FROM   employees
WHERE  JOB_ID = 'SA_REP'
OR     JOB_ID = 'AD_PRES' AND    SALARY > 15000;

-- the query above and this query is the same  
SELECT last_name, job_id, salary
FROM   employees
WHERE  JOB_ID = 'SA_REP'
OR     (JOB_ID = 'AD_PRES' AND    SALARY > 15000);

--when you use the parantheses () , then you can override and/or priorities
SELECT last_name, job_id, salary
FROM   EMPLOYEES
WHERE  (job_id = 'SA_REP' OR     job_id = 'AD_PRES')
AND    SALARY > 15000;


-----
--12  order by 
SELECT * FROM EMPLOYEES
ORDER BY HIRE_DATE; --the default order always ASC: Ascending 

--13   ( 12 and 13 are the same becasue ASC is default)
SELECT * FROM EMPLOYEES
ORDER BY HIRE_DATE ASC; --the default order always ASC: Ascending , so no need to put ASC

--14 order by desc: Descending 
SELECT * FROM EMPLOYEES
ORDER BY HIRE_DATE desc; --the default order always ASC: Ascending , so no need to put ASC

--15 where and order by
SELECT * FROM EMPLOYEES
WHERE DEPARTMENT_ID=90
ORDER BY EMPLOYEE_ID;

--16 null values in order by
SELECT * FROM EMPLOYEES
ORDER BY COMMISSION_PCT ; --by default null come last in Ascending order

SELECT * FROM EMPLOYEES
ORDER BY COMMISSION_PCT desc ----by default null come first in Descending order

--you can use NULLS FIRST to make null values appear first
SELECT * FROM EMPLOYEES
ORDER BY COMMISSION_PCT NULLS FIRST;

--17 you can sort also using column alias
SELECT FIRST_NAME n
FROM EMPLOYEES
ORDER BY N;

--18 you can sort by Expression
SELECT EMPLOYEE_ID , SALARY, SALARY+100
FROM EMPLOYEES
order by SALARY+100;

--19 you can sort by column not in the select even

SELECT EMPLOYEE_ID , SALARY
FROM EMPLOYEES
order by DEPARTMENT_ID;-- but this is not logical 

--20 you can sort by more than one column

SELECT DEPARTMENT_ID,first_name,salary
FROM EMPLOYEES
ORDER BY DEPARTMENT_ID,FIRST_NAME;

SELECT DEPARTMENT_ID,first_name,salary
FROM EMPLOYEES
ORDER BY DEPARTMENT_ID ASC ,FIRST_NAME DESC ;


--21 you can sory by column number in the select

SELECT DEPARTMENT_ID,first_name,salary
FROM EMPLOYEES
ORDER BY 1; --1 mean the first column in select which is the DEPARTMENT_ID

SELECT DEPARTMENT_ID,first_name,salary
FROM EMPLOYEES
ORDER BY 1,3; 

--Using SQL Row Limiting Clause in a Query
--first let do this select and extract it to excel 
SELECT employee_id, first_name
FROM EMPLOYEES
ORDER BY EMPLOYEE_ID;
 
SELECT employee_id, first_name
FROM EMPLOYEES
ORDER BY EMPLOYEE_ID
FETCH first 5 ROWS ONLY;
 
SELECT employee_id, first_name
FROM EMPLOYEES
ORDER BY EMPLOYEE_ID
FETCH first 50 PERCENT ROWS ONLY;
 
SELECT employee_id, first_name
FROM employees
ORDER BY EMPLOYEE_ID
offset 5 ROWS FETCH NEXT 5 ROWS ONLY;

SELECT employee_id, first_name
FROM EMPLOYEES
ORDER BY EMPLOYEE_ID
offset 4 ROWS FETCH NEXT 50 PERCENT ROWS ONLY;

--let know with TIES what mean 
SELECT EMPLOYEE_ID,first_name, SALARY
FROM EMPLOYEES
ORDER BY SALARY DESC;

SELECT EMPLOYEE_ID, first_name,SALARY
FROM EMPLOYEES
ORDER BY SALARY DESC
FETCH FIRST 2 ROWS  only;

SELECT EMPLOYEE_ID,first_name, SALARY
FROM EMPLOYEES
ORDER BY SALARY DESC
FETCH FIRST 2 ROWS  with TIES;







