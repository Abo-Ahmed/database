--1 using to_char  with dates
select sysdate from dual;

SELECT TO_CHAR(SYSDATE,'dd.mm.yyyy') FROM DUAL;

SELECT TO_CHAR(SYSDATE,'dd-mm-yyyy hh:mi:ss AM') FROM DUAL;--AM AND PM are the same

SELECT TO_CHAR(SYSDATE,'dd-mm-yyyy hh24:mi:ss PM') FROM DUAL;

SELECT FIRST_NAME,HIRE_DATE,TO_CHAR(HIRE_DATE, 'DD Month YYYY') HIREDATE,
TO_CHAR(HIRE_DATE, 'fmDD Month YYYY') AS HIREDATE--SO USING FM IS BETTER TO REMOVE SPAES
FROM   EMPLOYEES;

SELECT TO_CHAR(SYSDATE,'FMDD "OF" MoNTH YYYY') FROM DUAL;

SELECT TO_CHAR(SYSDATE,'FMDDsp "OF" MONTH YYYY') FROM DUAL;

SELECT TO_CHAR(SYSDATE,'fmddth "OF" MONTH YYYY') FROM DUAL;

SELECT TO_CHAR(SYSDATE,'fmddspth "OF" MONTH YYYY') FROM DUAL;

--list all the employees who employeed in 2003
SELECT * FROM EMPLOYEES
WHERE TO_CHAR(HIRE_DATE,'yyyy')='2003';

--list all the employees who employeed in feb
SELECT * FROM EMPLOYEES
WHERE TO_CHAR(HIRE_DATE,'mm')='02'; --if you put only '2'  this not coorect

SELECT * FROM EMPLOYEES
WHERE TO_CHAR(HIRE_DATE,'fmmm')='2'; --you should use fm if you want to put only '2' cz fm remove 0 and space



--2 using to_char  with number
SELECT TO_CHAR(1598) FROM DUAL;

SELECT TO_CHAR(1598,'9999') FROM DUAL;

SELECT TO_CHAR(1598,'9,999') FROM DUAL;

SELECT TO_CHAR(1598,'$9,999') FROM DUAL;

SELECT TO_CHAR(1598,'$9G999') FROM DUAL;
-------------------------------------------------
SELECT TO_CHAR(1598.87) FROM DUAL;

SELECT TO_CHAR(1598.87,'9999.99') FROM DUAL;

SELECT TO_CHAR(1598.87,'9,999.99') FROM DUAL;

SELECT TO_CHAR(1598.87,'$9,999.99') FROM DUAL;

SELECT TO_CHAR(1598.87,'$9G999.99') FROM DUAL;--ERROR IF USING G THEN USE D FOR DECIMAL

SELECT TO_CHAR(1598.87,'$9G999D99') FROM DUAL;

SELECT TO_CHAR(1598.87,'9999.9') FROM DUAL; --HERE IT WILL BE ROUND
------------------------------------------------
SELECT TO_CHAR(1598,'99') FROM DUAL;--IT WILL FAIL

SELECT TO_CHAR(1598,'0000') FROM DUAL;--IT WILL DEAL WITH ZERO LIKE 9

SELECT TO_CHAR(1598,'00000') FROM DUAL;

SELECT TO_CHAR(1598,'00000000') FROM DUAL;

SELECT TO_CHAR(1598,'0999') FROM DUAL;

SELECT TO_CHAR(1598,'00999') FROM DUAL;

SELECT TO_CHAR(1598989,'9G999G999') FROM DUAL;

SELECT TO_CHAR(-1598,'9999') FROM DUAL;

SELECT TO_CHAR(1598,'9999mi') FROM DUAL;
SELECT TO_CHAR(-1598,'9999mi') FROM DUAL;

SELECT TO_CHAR(1598,'9999PR') FROM DUAL;

SELECT TO_CHAR(-1598,'9999PR') FROM DUAL;

---THE BEST
SELECT TO_CHAR(1598,'999,999,999') FROM DUAL;

SELECT TO_CHAR(1598,'FM999,999,999') FROM DUAL;
--WHITE SPACE
SELECT TO_CHAR(7,'9') FROM DUAL;

SELECT TO_CHAR(-7,'9') FROM DUAL;

SELECT LENGTH('-7') FROM DUAL;


--3 using to numner

SELECT TO_NUMBER('1,000','9,999') FROM DUAL;

SELECT TO_NUMBER('$1,000','$9,999') FROM DUAL;

SELECT TO_NUMBER('88') FROM DUAL;

SELECT TO_NUMBER('1,980','9G999') FROM DUAL;
 


--4 using to_date

SELECT TO_DATE('10-11-2015','dd-mm-yyyy') FROM DUAL;

SELECT TO_DATE('10.11.2015','dd.mm.yyyy') FROM DUAL;

SELECT TO_DATE('10.november.2015','dd.month.yyyy') FROM DUAL;



SELECT * FROM EMPLOYEES
WHERE HIRE_DATE> TO_DATE('10-11-2003','dd-mm-yyyy');

SELECT * FROM EMPLOYEES
WHERE HIRE_DATE> TO_DATE('10-11-     2003','dd-mm-yyyy'); --oracle remove spaces 

SELECT * FROM EMPLOYEES
WHERE HIRE_DATE> TO_DATE('10-11- 2003','fxdd-mm- yyyy'); --when you put fx then exact should be mach

--RR AND YY
--rr fomrat
--in general if the value between  50-99 THIS return a 19xx year
-- A value between 0-49 will return a 20xx year 
SELECT TO_DATE('1-1-85','DD-MM-RR')  from dual;

SELECT TO_CHAR( TO_DATE('1-1-85','DD-MM-RR'),'YYYY')  from dual;

SELECT TO_DATE('1-1-85','DD-MM-YY')  from dual;

SELECT TO_CHAR(TO_DATE('1-1-85','DD-MM-YY'),'YYYY')  from dual;



--5 nvl function

SELECT EMPLOYEE_ID, FIRST_NAME, COMMISSION_PCT, nvl(COMMISSION_PCT,0)
FROM EMPLOYEES;

SELECT EMPLOYEE_ID, FIRST_NAME, job_id, NVL(job_id,'No JOB Yet')
FROM EMPLOYEES

SELECT EMPLOYEE_ID, FIRST_NAME, hire_date, NVL(hire_date,'1-jan-03')
FROM EMPLOYEES;



--because COMMISSION_PCT is number, so if you want to display 'no comm', then you should use to_char
SELECT EMPLOYEE_ID, FIRST_NAME, COMMISSION_PCT, NVL(to_char(COMMISSION_PCT),'no comm')
FROM EMPLOYEES;

--6 using nvl2 function
--if exp1 is not null, then it return exp2
--if exp1 is  null, then it return exp3
SELECT EMPLOYEE_ID, FIRST_NAME, COMMISSION_PCT, NVL2(COMMISSION_PCT,COMMISSION_PCT,0)
FROM EMPLOYEES;

SELECT EMPLOYEE_ID, FIRST_NAME, COMMISSION_PCT, 
NVL2(COMMISSION_PCT,'sal and comm','only salary') income
FROM EMPLOYEES;



--7 using nullif
--if exp1=exp2 then it return null, else it return exp1

SELECT FIRST_NAME, LENGTH(FIRST_NAME), LAST_NAME, LENGTH(LAST_NAME),
nullif(LENGTH(FIRST_NAME), LENGTH(LAST_NAME) ) results
FROM EMPLOYEES;

--8 coalesce function
--it return the first non-null value

SELECT EMPLOYEE_ID,FIRST_NAME, COMMISSION_PCT, MANAGER_ID, SALARY,
COALESCE(COMMISSION_PCT,MANAGER_ID,SALARY),
nvl(  nvl(COMMISSION_PCT,MANAGER_ID), SALARY ) --nested nvl equal to COALESCE
FROM EMPLOYEES;
------------------------------------------------------------------------------------------------------------
--9 case statment
-- CASE is better than DECODE and used in ANSI SQL

SELECT first_name, job_id, salary,
       CASE job_id WHEN 'IT_PROG'  THEN  1.10*salary
                   WHEN 'ST_CLERK' THEN  1.15*salary
                   WHEN 'SA_REP'   THEN  1.20*salary
       ELSE      SALARY 
       END     "REVISED_SALARY"
FROM   EMPLOYEES;

--you can make the condition after when 
SELECT FIRST_NAME, JOB_ID, SALARY,
       CASE  WHEN JOB_ID='IT_PROG'  THEN  1.10*SALARY
             WHEN JOB_ID='ST_CLERK' THEN  1.15*SALARY
              WHEN job_id='SA_REP'   THEN  1.20*salary
       ELSE      SALARY 
       END     "REVISED_SALARY"
FROM   EMPLOYEES;

---if you didnt put else then null will appear for not match conditions
SELECT first_name, job_id, salary,
       CASE job_id WHEN 'IT_PROG'  THEN  1.10*salary
                   WHEN 'ST_CLERK' THEN  1.15*salary
                   WHEN 'SA_REP'   THEN  1.20*salary
       END     "REVISED_SALARY"
FROM   EMPLOYEES;

--this below statment is not logicaly coorect
--if the first condition is met then it show the result regardless another conditions
SELECT SALARY, 
CASE WHEN SALARY >3000 THEN 'salary > 3000'
     WHEN SALARY >4000 THEN 'salary > 4000'
     WHEN SALARY >10000 THEN 'salary > 10000'
END FFF
FROM EMPLOYEES;

--so it should be like this 
SELECT SALARY, 
CASE WHEN SALARY >10000 THEN 'salary > 10000'
     WHEN SALARY >4000 THEN 'salary > 4000'
     WHEN SALARY >3000 THEN 'salary > 3000'
END FFF
FROM EMPLOYEES;

--6 decode 

SELECT last_name, job_id, salary,
       DECODE(job_id, 'IT_PROG',  1.10*salary,
                      'ST_CLERK', 1.15*salary,
                      'SA_REP',   1.20*salary,
              salary)
       REVISED_SALARY
FROM   EMPLOYEES;

--if you didnt put default value for non-match condition then null will be return for theses values
SELECT last_name, job_id, salary,
       DECODE(job_id, 'IT_PROG',  1.10*salary,
                      'ST_CLERK', 1.15*salary,
                      'SA_REP',   1.20*SALARY
              )
       REVISED_SALARY
FROM   EMPLOYEES;

--example display tax for employees as follow:
--if his salary <3000 then tax=0
--if his salary 3000-7000 then tax=10%
--if his salary >7000 then tax=20%
--so here you should use case , not decode , case is more filxable

SELECT EMPLOYEE_ID,FIRST_NAME, SALARY,
  CASE WHEN SALARY<3000 THEN '0%'
  WHEN SALARY BETWEEN 3000 AND 7000 THEN '10%'
  WHEN SALARY> 7000 THEN '20%'
end tax
FROM EMPLOYEES;




