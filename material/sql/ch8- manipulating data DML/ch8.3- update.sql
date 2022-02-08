--the update 
--1 it is logical to make update always based on the PK for the table
select * from EMPLOYEES
where EMPLOYEE_ID=100;

UPDATE EMPLOYEES
SET SALARY =24100
WHERE EMPLOYEE_ID=100;
COMMIT;

select * from EMPLOYEES
where EMPLOYEE_ID=100;

--2 making update on another condition (not using the PK) could be dangerous
UPDATE EMPLOYEES
SET SALARY =24000
WHERE FIRST_NAME='Steven'; -- it could be more than one employee with name='Steven'
COMMIT;

SELECT * from EMPLOYEES
WHERE FIRST_NAME='Steven';



--3 to do more practice on update, lets create table called copy_emp,
--this table is a copy from employees table, we dont want to make changes on the orginal table 

CREATE TABLE COPY_EMP
AS 
SELECT * FROM EMPLOYEES;

SELECT * FROM COPY_EMP;

--4 you can update more than one column in the same time
UPDATE COPY_EMP
SET SALARY =24100, DEPARTMENT_ID=10
WHERE EMPLOYEE_ID=100;
COMMIT;

SELECT * FROM COPY_EMP
WHERE EMPLOYEE_ID=100;


--5 if there is no where condition then the update will be for all the tables 

UPDATE COPY_EMP
SET PHONE_NUMBER='515.123.4567';

SELECT * FROM COPY_EMP;

--6 in update , you can set the column to null value

UPDATE COPY_EMP
SET DEPARTMENT_ID=NULL
WHERE EMPLOYEE_ID=100;

COMMIT;

SELECT * FROM COPY_EMP
WHERE EMPLOYEE_ID=100;

---7 using subquery in update
--make the salary for employee 100 like the salary for employee  200
SELECT * FROM COPY_EMP
where EMPLOYEE_ID in (100,200);

UPDATE COPY_EMP
SET salary=(select salary from COPY_EMP where EMPLOYEE_ID=200)
WHERE EMPLOYEE_ID=100;
COMMIT;

SELECT * FROM COPY_EMP
where EMPLOYEE_ID in (100,200)

---another example
--make the salary and department id for employee 105 like the salary and department id for employee 108

SELECT * FROM COPY_EMP
WHERE EMPLOYEE_ID IN (105,108);


--method 1 
UPDATE COPY_EMP
SET (salary,department_id) =(select salary, department_id  from COPY_EMP where EMPLOYEE_ID=108)
WHERE EMPLOYEE_ID=105;

--method 2 
UPDATE COPY_EMP
SET SALARY    =(SELECT SALARY  FROM COPY_EMP WHERE EMPLOYEE_ID=108),
department_id =(select department_id  from COPY_EMP where EMPLOYEE_ID=108)
WHERE EMPLOYEE_ID=105;




















