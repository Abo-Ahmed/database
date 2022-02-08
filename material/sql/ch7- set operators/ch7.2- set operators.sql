-- lets see the table job_history

SELECT * FROM EMPLOYEES
WHERE EMPLOYEE_ID=176; --HIS job now is SA_REP

SELECT * FROM JOB_HISTORY
where EMPLOYEE_ID=176;

--the union between EMPLOYEES and JOB_HISTORY
/* 1- the number of columns should be match
   2- the data type should be match
   3- duplicates has been elimnated
   4- the query order is ASC FOR ALL columns
*/

SELECT EMPLOYEE_ID, JOB_ID FROM EMPLOYEES
WHERE EMPLOYEE_ID=176
union
SELECT EMPLOYEE_ID, JOB_ID FROM JOB_HISTORY
where EMPLOYEE_ID=176

SELECT EMPLOYEE_ID, JOB_ID
FROM
EMPLOYEES
UNION
SELECT EMPLOYEE_ID, JOB_ID
FROM
JOB_HISTORY;
-----------------------------------------------------------------------

--the union all between EMPLOYEES and JOB_HISTORY
/* 1- the number of columns should be match
   2- the data type should be match
   3- duplicates has not been elimnated
   4- the query not orders
*/
SELECT EMPLOYEE_ID, JOB_ID
FROM
EMPLOYEES
UNION all
SELECT EMPLOYEE_ID, JOB_ID
FROM
JOB_HISTORY;

---the column name in first query appear in the results
--so here emp_id, job will be appaer in the results
SELECT EMPLOYEE_ID emp_id , JOB_ID job
FROM
EMPLOYEES
UNION
SELECT EMPLOYEE_ID emno, JOB_ID jobid
FROM
JOB_HISTORY;

-- the intersect operator
SELECT EMPLOYEE_ID emp_id , JOB_ID job
FROM
EMPLOYEES
intersect
SELECT EMPLOYEE_ID emno, JOB_ID jobid
FROM
JOB_HISTORY;

SELECT * FROM EMPLOYEES
WHERE EMPLOYEE_ID=200; 

SELECT * FROM JOB_HISTORY
where EMPLOYEE_ID=200;

--here the EMPLOYEE_ID 200 will not appear because we add another column in query DEPARTMENT_ID, so it will compare 3 columns
SELECT EMPLOYEE_ID emp_id , JOB_ID job ,DEPARTMENT_ID
FROM
EMPLOYEES
INTERSECT
SELECT EMPLOYEE_ID emno, JOB_ID jobid,DEPARTMENT_ID
FROM
JOB_HISTORY;


--the minus operator 
--display the emplopyee that who have not changed thir job 
SELECT EMPLOYEE_ID 
FROM
EMPLOYEES
minus
SELECT EMPLOYEE_ID 
FROM
JOB_HISTORY;
-----------------------------------------------

--matching dummy column

SELECT EMPLOYEE_ID, JOB_ID, email
FROM
EMPLOYEES
UNION
SELECT EMPLOYEE_ID, JOB_ID, to_char(null) email
FROM
JOB_HISTORY;


SELECT EMPLOYEE_ID, JOB_ID, salary
FROM
EMPLOYEES
UNION
SELECT EMPLOYEE_ID, JOB_ID, 0 salary
FROM
JOB_HISTORY;
-------------------------------------

--the order by come last and only once 
SELECT EMPLOYEE_ID, JOB_ID, salary
FROM
EMPLOYEES
UNION
SELECT EMPLOYEE_ID, JOB_ID, 0 salary
FROM
JOB_HISTORY
ORDER BY EMPLOYEE_ID;

--the order by can see only column name in the first querey
SELECT EMPLOYEE_ID emp_id, JOB_ID, salary
FROM
EMPLOYEES
UNION
SELECT EMPLOYEE_ID empno , JOB_ID, 0 salary
FROM
JOB_HISTORY
ORDER BY emp_id; -- try to use empno, it will give error 

--you can use the column number to solve the issue of def. column name
SELECT EMPLOYEE_ID emp_id, JOB_ID, salary
FROM
EMPLOYEES
UNION
SELECT EMPLOYEE_ID empno , JOB_ID, 0 salary
FROM
JOB_HISTORY
ORDER BY 1;



