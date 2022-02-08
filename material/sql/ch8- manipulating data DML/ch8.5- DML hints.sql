--case 1 , doing some DML statements , then doing commit
SELECT * FROM EMPLOYEES
WHERE EMPLOYEE_ID IN (200,201);

SELECT * FROM DEPARTMENTS
WHERE DEPARTMENT_ID = 1; 

--1
UPDATE EMPLOYEES
SET SALARY=SALARY+100
WHERE EMPLOYEE_ID=200;

--2
UPDATE EMPLOYEES
SET SALARY=SALARY+50
WHERE EMPLOYEE_ID=201;

--3
INSERT INTO DEPARTMENTS (DEPARTMENT_ID,DEPARTMENT_NAME,MANAGER_ID,LOCATION_ID)
VALUES                   (1,	'ADMINISTRATION 2',	200,	1700);

--4 now when i do commit, then all the DML (1,2,3) will be commited
COMMIT;

SELECT * FROM EMPLOYEES
WHERE EMPLOYEE_ID IN (200,201);

SELECT * FROM DEPARTMENTS
WHERE DEPARTMENT_ID = 1;
------------------------------------------------------------------------------------------------------------------------

--case 2 , doing some DML statements , then doing rollback
--5 
DELETE FROM DEPARTMENTS
WHERE DEPARTMENT_ID=1;

--6
DELETE FROM EMPLOYEES
WHERE EMPLOYEE_ID =1;

--now when you query , you will not find theses records 
SELECT * FROM DEPARTMENTS
WHERE DEPARTMENT_ID = 1;

SELECT * FROM EMPLOYEES
WHERE EMPLOYEE_ID =1;

--7 when you do rollback, then the data will be restored  (5,6), 

ROLLBACK;

SELECT * FROM DEPARTMENTS
WHERE DEPARTMENT_ID = 1;

SELECT * FROM EMPLOYEES
WHERE EMPLOYEE_ID=1;
--------------------------------------------------------------------------------------------------------

--case 3  statement-level rollback
SELECT * FROM EMPLOYEES
WHERE EMPLOYEE_ID IN (106,107);

--8
DELETE FROM EMPLOYEES
WHERE EMPLOYEE_ID=106;
--9
DELETE FROM DEPARTMENTS;

--10
DELETE FROM EMPLOYEES
WHERE EMPLOYEE_ID=107;

--so the dml 9 will not be executed, oracle make rollback only for this statment ( statement-level rollback)
--other statemnets you can make  it explicit commit, or rollback 

ROLLBACK;

SELECT * FROM EMPLOYEES
WHERE EMPLOYEE_ID IN (106,107);
---------------------------------------------------------------------------------------------------------------------------

--case 4, doing some DML then doing one DDL/DCL statement, this make automatic commit

--11
INSERT INTO DEPARTMENTS (DEPARTMENT_ID,DEPARTMENT_NAME,MANAGER_ID,LOCATION_ID)
VALUES                   (1000,	'dept1',	200,	1700);

--12
INSERT INTO DEPARTMENTS (DEPARTMENT_ID,DEPARTMENT_NAME,MANAGER_ID,LOCATION_ID)
VALUES                   (1001,	'dept2',	200,	1700);

--13

CREATE TABLE TEST_TABLE
( EMP_ID NUMBER,
  NAME VARCHAR2(100)
);

--now even if you did rollback, the dml (11,12 ) commited by oracle implicitly 
--because you did DDL statement
ROLLBACK;

SELECT * FROM DEPARTMENTS
WHERE DEPARTMENT_ID IN (1000,1001);
------------------------------------------------------------------

--case 5, using the save point
SELECT * FROM EMPLOYEES
WHERE EMPLOYEE_ID =108;

UPDATE EMPLOYEES
SET SALARY=SALARY+10
WHERE EMPLOYEE_ID=108;

SAVEPOINT A;

SELECT * FROM EMPLOYEES
WHERE EMPLOYEE_ID =108;

UPDATE EMPLOYEES
SET SALARY=SALARY+20
WHERE EMPLOYEE_ID=108;

SELECT * FROM EMPLOYEES
WHERE EMPLOYEE_ID =108;

ROLLBACK TO SAVEPOINT A;

SELECT * FROM EMPLOYEES
WHERE EMPLOYEE_ID =108;

--now you can do commit, or rollack
COMMIT;

SELECT * FROM EMPLOYEES
WHERE EMPLOYEE_ID =108;
---------------------------------------------------------------------------------------------------

--case 6, try to see the look on the row

SELECT * FROM EMPLOYEES
WHERE EMPLOYEE_ID =109;

UPDATE EMPLOYEES
SET SALARY=SALARY+20
WHERE EMPLOYEE_ID=109;

SELECT * FROM EMPLOYEES
WHERE EMPLOYEE_ID =109;

--now go to another session and try to query, then try yo update same record 
/*
UPDATE EMPLOYEES
SET department_id=10
WHERE EMPLOYEE_ID=109;
*/

COMMIT;

--------------------------------------------------------------------------------------------------------------------

--case 7 for update

--when you do this, then no other users or other sessions can make update for theses records,
--they can but after you do commit or rollback
SELECT * FROM EMPLOYEES
WHERE DEPARTMENT_ID=10
FOR UPDATE;
--try to open another session and do this, it will be locked for the rows that match 
--one or more condition
/*
UPDATE EMPLOYEES
SET salary=4400
WHERE DEPARTMENT_ID=10;
*/
COMMIT;
------------------------------
--open another session and do this update ( dont do anyu comit  or rollback in that session )
/*
UPDATE EMPLOYEES
SET salary=4400
WHERE DEPARTMENT_ID=10;
*/
--if someone else trying to update theses records, then you will not wait, 
--you will see error tell you that.
--so coninue your work, then try again later
SELECT * FROM EMPLOYEES
WHERE DEPARTMENT_ID=10
FOR UPDATE nowait;

commit;
---------------------------------

--open another session and do this update ( dont do anyupdate or rollback in that session )
/*
UPDATE EMPLOYEES
SET salary=4400
WHERE DEPARTMENT_ID=10;
*/
--here if someone esle  locked theses records, then the server will wait 10 seconds
--if the other user make commit or rollback with the 10 second, 
--then my select will wotk and lock the records
--if the user didnt make commit or rollback within the 10 seconds, then i will receive the error 
SELECT * FROM EMPLOYEES
WHERE DEPARTMENT_ID=10
FOR UPDATE WAIT 10;

commit;
------------------------------------------------------------


SELECT EMPLOYEE_ID, FIRST_NAME,EMP.DEPARTMENT_ID, DEPARTMENT_name
FROM 
EMPLOYEES EMP ,
DEPARTMENTS DEPT
WHERE  EMP.DEPARTMENT_ID=DEPT.DEPARTMENT_ID
AND EMP.DEPARTMENT_ID=10
FOR UPDATE;

--now try to open another session and do this 
--it will lock all the rows in table EMPLOYEES for DEPARTMENT_ID=10
--also look the row DEPARTMENT_ID=10 in table DEPARTMENTS;
/*
UPDATE DEPARTMENTs
SET DEPARTMENT_name='x'
WHERE DEPARTMENT_ID = 10;
*/

COMMIT;

--to make lock only for the rows in  EMPLOYEES use ( FOR UPDATE of column_name )
--this will lock all the rows that have this column which match the where condition
SELECT EMPLOYEE_ID, FIRST_NAME,EMP.DEPARTMENT_ID, DEPARTMENT_name
FROM 
EMPLOYEES EMP ,
DEPARTMENTS DEPT
WHERE  EMP.DEPARTMENT_ID=DEPT.DEPARTMENT_ID
AND EMP.DEPARTMENT_ID=10
FOR UPDATE of salary;

--open another session and do this, it will wotk for DEPARTMENTs
--but the rows in table EMPLOYEES still have the lock in for EMPLOYEES.DEPARTMENT_ID=10
/*
UPDATE DEPARTMENTs
SET DEPARTMENT_name='x'
WHERE DEPARTMENT_ID = 10;
*/
COMMIT;























