-- the insert Statement

--1 always desc the table before making any insert to know the columns and the constraints
DESC DEPARTMENTS;

--2 try to have a look on table constraints
--go to tables from the tree on the left, select the table, and then see the constraints
--note: the constraint will be discussed in details later

--3 
--list the columns in same table order, then put Related values ( this is the Recommendation ) 
INSERT INTO DEPARTMENTS (DEPARTMENT_ID,DEPARTMENT_NAME,MANAGER_ID,LOCATION_ID)
VALUES                  (71,'Development 1',100,1700);
commit; -- use the commit command to save the changes

--you can make insert without puting the columns names, but the order in values should be same order of table
--this way of insert you need to put values for all the tables
INSERT INTO DEPARTMENTS 
VALUES   (72,'Development 2',100,1700);
COMMIT;

--you can change the order as you like when put the columns names, but you should mapp the values same
INSERT INTO DEPARTMENTS (DEPARTMENT_NAME,MANAGER_ID,LOCATION_ID,DEPARTMENT_ID)
VALUES                  ('Development 3',100,1700,73);
COMMIT;

--4 inserting rows with null values
--the Implicit method: dont put the column in the list, make sure the column can have null value
--the oracle server automatically make the value null
--so the MANAGER_ID,LOCATION_ID will be null in below insert
INSERT INTO DEPARTMENTS (DEPARTMENT_ID,DEPARTMENT_NAME)
VALUES                  (74,'Development 4');

--the explicit method, done by the user by soecify the NULL keyword
INSERT INTO DEPARTMENTS (DEPARTMENT_ID,DEPARTMENT_NAME,MANAGER_ID,LOCATION_ID )
VALUES                  (75,'Development 5',null,null);

--5 inserting special values like sysdate, or some other functions

INSERT INTO EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,HIRE_DATE ,JOB_ID)
VALUES               (1,'khaled','khudari','khaled@hotmail.com',SYSDATE,'IT_PROG' );

INSERT INTO EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,HIRE_DATE ,JOB_ID)
VALUES               (2,'Samer','ali','samer@hotmail.com',to_date('20-07-2015','dd-mm-yyyy'),'IT_PROG' );

--6 using the & with insert 
INSERT INTO DEPARTMENTS (DEPARTMENT_ID,DEPARTMENT_NAME)
VALUES                  (&dpet_id,'&dname');

--7 you can make insert with subquery
--lets create table xx_emp
CREATE TABLE XX_EMP
(EMPNO NUMBER,
 FNAME VARCHAR2(100),
 SALARY NUMBER
 );
 
 SELECT * FROM XX_EMP;
 
 
 --so you insert into XX_EMP using select
 
 INSERT INTO XX_EMP(EMPNO,FNAME,SALARY)
 SELECT EMPLOYEE_ID,FIRST_NAME,SALARY
 FROM
 EMPLOYEES;
 
 SELECT * from XX_EMP;
 
 --------------------------------------------------------------------------------------------------------------
 --now lets see some errors in inserting

--1 inserting existing value, and this value is PK  
--DEPARTMENT_ID=10
INSERT INTO DEPARTMENTS (DEPARTMENT_ID,DEPARTMENT_NAME,MANAGER_ID,LOCATION_ID)
VALUES                  (10,'Development 1',100,1700);

--2 inserting FK value not exists in the reference table
--LOCATION_ID=1
INSERT INTO DEPARTMENTS (DEPARTMENT_ID,DEPARTMENT_NAME,MANAGER_ID,LOCATION_ID)
VALUES                  (5,'Development 1',100,1);

--3 inserting missmatch data type
--LOCATION_ID='D1'
INSERT INTO DEPARTMENTS (DEPARTMENT_ID,DEPARTMENT_NAME,MANAGER_ID,LOCATION_ID)
VALUES                  (5,'Development 1',100,'D1');

--4 inserting value too long
--DEPARTMENT_NAME=' The development and research department'
INSERT INTO DEPARTMENTS (DEPARTMENT_ID,DEPARTMENT_NAME,MANAGER_ID,LOCATION_ID)
VALUES                  (5,'The development and research department',100,1700);



 
 




