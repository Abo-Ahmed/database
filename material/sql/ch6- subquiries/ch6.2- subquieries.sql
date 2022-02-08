--using subquery

--1 who has salary > Abel's  Salary, note assume Abel is the last name

--so you need to now Abel's  Salary
SELECT SALARY FROM EMPLOYEES WHERE LAST_NAME='Abel';

--then make the query like this 
select EMPLOYEE_ID,first_name, last_name, salary
FROM
EMPLOYEES
WHERE SALARY> ( SELECT SALARY FROM EMPLOYEES WHERE LAST_NAME='Abel' );

--you can make the subquery on left side, but this is not recomnded
select EMPLOYEE_ID,first_name, last_name, salary
FROM
EMPLOYEES
WHERE  ( SELECT SALARY FROM EMPLOYEES WHERE LAST_NAME='Abel' )<SALARY

--2 when using single-row operator, then the subquery should return also single row
--single-row operator ( =, >,<, >=,<=, <>, != )
SELECT * FROM 
employees
WHERE JOB_ID=( SELECT JOB_ID FROM EMPLOYEES WHERE LAST_NAME='Abel' );

--THIS select will give error 'single-row subquery returns more than one row'
SELECT * FROM 
EMPLOYEES
WHERE SALARY>( SELECT SALARY FROM EMPLOYEES WHERE DEPARTMENT_ID =30 );

SELECT SALARY FROM EMPLOYEES WHERE DEPARTMENT_ID =30;

--3  using group function is subquery
--i want the employee who has the highest salary

SELECT * FROM
EMPLOYEES
WHERE SALARY=(SELECT MAX(SALARY) FROM EMPLOYEES );

--4 subquery in having
SELECT DEPARTMENT_ID , COUNT(EMPLOYEE_ID)
FROM
EMPLOYEES
GROUP BY DEPARTMENT_ID
HAVING  COUNT(EMPLOYEE_ID)> (SELECT COUNT(1) 
                             FROM EMPLOYEES
                             WHERE DEPARTMENT_ID=90 );
                             
--5 if the subquery return no row, then all select return no rows
select EMPLOYEE_ID,first_name, last_name, salary
FROM
EMPLOYEES
WHERE SALARY> ( SELECT SALARY FROM EMPLOYEES WHERE LAST_NAME='dddd' );
----------------------------------------------------------------------------------------------------------------------------------------------------
--6 multiple rows subqery
--should be used with ( in, any, all)
--first lets do this query
SELECT SALARY FROM EMPLOYEES WHERE DEPARTMENT_ID=90 ;

--in ----------
select EMPLOYEE_ID,first_name, last_name, salary
FROM
EMPLOYEES
WHERE SALARY IN  ( SELECT SALARY FROM EMPLOYEES WHERE DEPARTMENT_ID=90 );
-- this also can be like this in (24000,17000)

--any ----------

select EMPLOYEE_ID,first_name, last_name, salary
FROM
EMPLOYEES
WHERE SALARY >=any  ( SELECT SALARY FROM EMPLOYEES WHERE DEPARTMENT_ID=90 );
                             
---all------

select EMPLOYEE_ID,first_name, last_name, salary
FROM
EMPLOYEES
WHERE SALARY >=ALL  ( SELECT SALARY FROM EMPLOYEES WHERE DEPARTMENT_ID=90 );

--in and not in  when there are null values

--when you want to retrive the employees who have no manager , we use is null
SELECT * FROM EMPLOYEES
WHERE MANAGER_ID IS NULL;

--you can not use =null

SELECT * FROM EMPLOYEES
WHERE MANAGER_ID = NULL; --this is not valid  in select, use is null / is not null

--if the subquery return null with operator IN, this is ok
SELECT * FROM EMPLOYEES
WHERE MANAGER_ID in ( 100, 101, NULL);

--if the subquery return null with operator NOT IN , then no revords will be retrive
SELECT * FROM EMPLOYEES
WHERE MANAGER_ID not in ( 100, 101,null);

----   IN is Equivalent to  =any
--so if the subquery set contains one null value, then no issue 
SELECT EMPLOYEE_ID, first_name,last_name, salary
FROM EMPLOYEES
WHERE EMPLOYEE_ID in (SELECT MANAGER_ID FROM  EMPLOYEES );

----NOT in  IS  Equivalent  TO   <>all
--so if  the subquery set contains one null value, then the query will retrieve no records
SELECT EMPLOYEE_ID, first_name,last_name, salary
FROM EMPLOYEES
WHERE EMPLOYEE_ID not in (SELECT MANAGER_ID FROM  EMPLOYEES );


---7 EXISTS / NOT EXISTS

--retrieve all the departments info that have employees 

SELECT * FROM
DEPARTMENTS DEPT
WHERE DEPARTMENT_ID in  (SELECT DEPARTMENT_ID FROM EMPLOYEES EMP );

SELECT * FROM
DEPARTMENTS DEPT
WHERE EXISTS (SELECT DEPARTMENT_ID FROM EMPLOYEES EMP WHERE EMP.DEPARTMENT_ID=DEPT.DEPARTMENT_ID);

--retrieve all the departments info that have no employees
SELECT * FROM
DEPARTMENTS DEPT
WHERE not EXISTS (SELECT DEPARTMENT_ID FROM EMPLOYEES EMP WHERE EMP.DEPARTMENT_ID=DEPT.DEPARTMENT_ID);

---------------------------------






