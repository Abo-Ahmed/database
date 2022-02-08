--creating simple view  EMP_V1
--one table,no functions,no group, allow DML operations

DROP VIEW  EMP_V1;

--let us create view EMP_V1 constains EMPLOYEE_ID,first_name,LAST_NAME,EMAIL,HIRE_DATE,JOB_ID
CREATE VIEW EMP_V1
AS
SELECT EMPLOYEE_ID,first_name,LAST_NAME,EMAIL,HIRE_DATE,JOB_ID
FROM EMPLOYEES;

--so now i can select from the view as i select from table
SELECT * FROM EMP_V1;

SELECT * FROM USER_VIEWS
WHERE VIEW_NAME='EMP_V1';

DESC EMP_V1;

--so i can do DML operation same as the table

INSERT INTO EMP_V1 (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,HIRE_DATE,JOB_ID)
VALUES              (333,'David','King','DKing',SYSDATE,'IT_PROG');

--SEE THE NEW RECORD IN THE VIEW
SELECT * FROM EMP_V1
WHERE EMPLOYEE_ID=333;

--SEE THE NEW RECORD IN THE ORGINAL TABLE
SELECT * FROM EMPLOYEES
WHERE EMPLOYEE_ID=333;
------------------------------------------------------------------------------------------------------

--creating simple view  EMP_V2
--but here will give the columns another names as alias
DROP VIEW EMP_V2;

CREATE VIEW EMP_V2
AS
SELECT EMPLOYEE_ID EMP_ID ,FIRST_NAME FNAME ,LAST_NAME LNAME,
EMAIL,HIRE_DATE,JOB_ID
FROM EMPLOYEES;

SELECT * FROM EMP_V2;

--so now you can do DML but as the new columns names from the view
INSERT INTO EMP_V2 (EMP_ID,FNAME,LNAME,EMAIL,HIRE_DATE,JOB_ID)
VALUES              (334,'Lara','Craft','Lara',SYSDATE,'IT_PROG');

SELECT * FROM EMP_V2
WHERE EMP_ID=334;

SELECT * FROM EMPLOYEES
WHERE EMPLOYEE_ID=334;
---------------------------------------------------------------------------
--creating simple view  EMP_V3
--but here will give the columns another names inside view def.
DROP VIEW EMP_V3;

CREATE VIEW EMP_V3 (empid,fname,lname,mail,hiredate,jobs)
AS
SELECT EMPLOYEE_ID ,FIRST_NAME  ,LAST_NAME ,EMAIL,HIRE_DATE,JOB_ID
FROM EMPLOYEES;

SELECT * FROM EMP_V3;
-------------------------------------------------------------------------------

--creating complex view , in this example you can not do DML on the view 

DROP VIEW EMP_DEPT_ANALYSIS;

CREATE VIEW EMP_DEPT_Analysis
AS
SELECT DEPARTMENT_ID, COUNT(EMPLOYEE_ID) EMP_COUNT ,
MAX(SALARY) MAX_SAL,
MIN(SALARY) LOW_SAL
FROM
EMPLOYEES
GROUP BY DEPARTMENT_ID;

SELECT * FROM EMP_DEPT_ANALYSIS;

-- we want to add the Average saalry also to view EMP_DEPT_Analysis
--so we recreate the the view again by using ( or replace )

CREATE or replace VIEW EMP_DEPT_Analysis
AS
SELECT DEPARTMENT_ID, COUNT(EMPLOYEE_ID) EMP_COUNT ,
MAX(SALARY) MAX_SAL,
MIN(SALARY) LOW_SAL,
avg(SALARY) avg_SAL
FROM
EMPLOYEES
GROUP BY DEPARTMENT_ID;

SELECT * FROM EMP_DEPT_ANALYSIS;
-----------------------------------------------------------

--creating complex view that have data form more than one table

CREATE OR REPLACE VIEW EMP_DEPT_V
AS
SELECT EMPLOYEE_ID, FIRST_NAME||' '|| LAST_NAME NAME,
SALARY , nvl(DEPARTMENT_NAME,'no dept') DEPARTMENT_NAME
FROM EMPLOYEES E LEFT OUTER JOIN DEPARTMENTS D
ON (E.DEPARTMENT_ID=D.DEPARTMENT_ID );

SELECT * FROM EMP_DEPT_V;
------------------------------------------------------------------

--creating view with with read only 
CREATE or replace VIEW EMP_V_read
AS
SELECT EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,HIRE_DATE,JOB_ID
FROM EMPLOYEES
WHERE DEPARTMENT_ID=90
with READ ONLY;

SELECT * FROM EMP_V_READ;

--but you can do any DML 
DELETE FROM EMP_V_READ;--cannot perform a DML operation on a read-only view

SELECT * FROM USER_CONSTRAINTS
WHERE TABLE_NAME='EMP_V_READ';
-----------------------------------------------------------------------------------------

--creating view with with check option 
CREATE or replace VIEW EMP_V_chq_const
AS
SELECT EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,HIRE_DATE,JOB_ID,DEPARTMENT_ID
FROM EMPLOYEES
WHERE DEPARTMENT_ID=90 
with check option;

SELECT * FROM EMP_V_chq_const;

SELECT * FROM USER_CONSTRAINTS
WHERE TABLE_NAME='EMP_V_CHQ_CONST';

--YOU CAN ONLY MAKE dml as your view range wich is dept 90 
INSERT INTO EMP_V_CHQ_CONST (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,HIRE_DATE,JOB_ID,DEPARTMENT_ID)
VALUES                       (444,'FADI','ALI','FALI',SYSDATE,'IT_PROG',90);

SELECT * FROM EMP_V_CHQ_CONST;

--any dml out of your range will give error ::::view WITH CHECK OPTION where-clause violation
INSERT INTO EMP_V_CHQ_CONST (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,HIRE_DATE,JOB_ID,DEPARTMENT_ID)
VALUES                       (446,'SAED','ALI','SALI',SYSDATE,'IT_PROG',10);

------------------------

DROP VIEW FORCE_V;

create or replace force view FORCE_V
AS
SELECT ENO, ENAME
FROM JRX;

SELECT * from USER_VIEWS
WHERE VIEW_NAME ='FORCE_V';









