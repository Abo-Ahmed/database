--we will learn how to add constraints to the tables
--we will create 2 tables EMP2, dept2 same employees and departments
DROP TABLE EMP2;

CREATE TABLE EMP2 
AS SELECT * FROM EMPLOYEES;

DESC EMP2;

SELECT * FROM EMP2;


DROP TABLE dept2;

CREATE TABLE DEPT2 
AS SELECT * FROM DEPARTMENTS ;

DESC DEPT2;

SELECT * FROM DEPT2;

--now there are many methods to add constraints to the table 

--1 adding primary key 

--mathod 1, here the constraint name will be sys_cn%

ALTER TABLE EMP2
MODIFY EMPLOYEE_ID PRIMARY KEY;

SELECT * FROM USER_CONSTRAINTs
WHERE TABLE_NAME='EMP2';

ALTER TABLE EMP2
DROP CONSTRAINT &cons;

SELECT * FROM USER_CONSTRAINTS
WHERE TABLE_NAME='EMP2';

--mathod 2, here you will give the name of the constraint, this is better

ALTER TABLE EMP2
add constraint EMP2_pk  PRIMARY KEY(EMPLOYEE_ID );

SELECT * FROM USER_CONSTRAINTs
WHERE TABLE_NAME='EMP2';

ALTER TABLE dept2
add constraint dept2_pk  PRIMARY KEY(department_id );
----------------------------------------------------------------------------------------------------------------

--2 adding foreign key 
--method 1
ALTER TABLE EMP2
MODIFY DEPARTMENT_ID  REFERENCES DEPT2 (department_id);

SELECT * FROM USER_CONSTRAINTS
WHERE TABLE_NAME='EMP2';

ALTER TABLE EMP2
DROP CONSTRAINT &con_name;

--method 2

ALTER TABLE EMP2
add constraint EMP2_fk_dept foreign key(department_id) REFERENCES dept2 (department_id);

SELECT * FROM USER_CONSTRAINTS
WHERE TABLE_NAME='EMP2';
--------------------------------------------------------------------------------------------------------------------
--3 adding not null constraint
-- this will work only if the table is empty,  or the column has value for all rows
ALTER TABLE EMP2
MODIFY FIRST_NAME  NOT NULL;
-----------------

DELETE FROM DEPT2;

SELECT * FROM USER_CONSTRAINTS
WHERE TABLE_NAME IN ('EMP2','DEPT2')
AND CONSTRAINT_TYPE IN ('P','R')
ORDER BY TABLE_NAME;

ALTER TABLE DEPT2
DROP PRIMARY KEY ; ---or you can do like this alter table DEPT2 drop constraint dept2_pk

--when you do this, it will drop all the related constraints
ALTER TABLE DEPT2
DROP PRIMARY KEY CASCADE;

SELECT * FROM USER_CONSTRAINTS
WHERE TABLE_NAME IN ('EMP2','DEPT2')
AND CONSTRAINT_TYPE IN ('P','R')
ORDER BY TABLE_NAME;

--------------------------------------------------------------------------------------
ALTER TABLE dept2
ADD CONSTRAINT DEPT2_PK  PRIMARY KEY(DEPARTMENT_ID );

ALTER TABLE EMP2
add constraint EMP2_fk_dept foreign key(department_id) REFERENCES dept2 (department_id);

SELECT * FROM USER_CONSTRAINTS
WHERE TABLE_NAME IN ('EMP2','DEPT2')
AND CONSTRAINT_TYPE IN ('P','R')
ORDER BY TABLE_NAME;

ALTER TABLE DEPT2
DROP COLUMN DEPARTMENT_ID;

ALTER TABLE DEPT2
DROP COLUMN DEPARTMENT_ID CASCADE CONSTRAINTS;

SELECT * FROM USER_CONSTRAINTS
WHERE TABLE_NAME IN ('EMP2','DEPT2')
AND CONSTRAINT_TYPE IN ('P','R')

SELECT * FROM DEPT2;

SELECT * from EMP2;

----------------------------------------------------------

--rename the column name  

SELECT * FROM  EMP2;

SELECT * FROM USER_CONS_COLUMNS
WHERE TABLE_NAME='EMP2';

ALTER TABLE EMP2
RENAME COLUMN FIRST_NAME TO FNAME;

SELECT * FROM  EMP2;

SELECT * FROM USER_CONS_COLUMNS
WHERE TABLE_NAME='EMP2';


SELECT * FROM USER_CONSTRAINTS
WHERE TABLE_NAME IN ('EMP2','DEPT2')
AND CONSTRAINT_TYPE IN ('P','R')
ORDER BY TABLE_NAME;

--CHANGE THE CONSTRAINT NAME

ALTER TABLE EMP2
RENAME CONSTRAINT EMP2_PK TO NEW_EMP2_PK;

SELECT * FROM USER_CONSTRAINTS
WHERE TABLE_NAME IN ('EMP2','DEPT2')
AND CONSTRAINT_TYPE IN ('P','R')
ORDER BY TABLE_NAME;
-----------------------------------------------------

DROP TABLE EMP2;

CREATE TABLE EMP2 
AS SELECT * FROM EMPLOYEES;

DROP TABLE dept2;

CREATE TABLE DEPT2 
AS SELECT * FROM DEPARTMENTS ;

ALTER TABLE DEPT2
ADD CONSTRAINT DEPT2_PK  PRIMARY KEY(DEPARTMENT_ID );

ALTER TABLE EMP2
add constraint EMP2_pk  PRIMARY KEY(EMPLOYEE_ID );

ALTER TABLE EMP2
add constraint EMP2_fk_dept foreign key(department_id) REFERENCES dept2 (department_id);

SELECT * FROM USER_CONSTRAINTS
WHERE TABLE_NAME IN ('EMP2','DEPT2')
AND CONSTRAINT_TYPE IN ('P','R')
ORDER BY TABLE_NAME;

SELECT * FROM USER_indexes
where table_name='EMP2';

ALTER TABLE EMP2
DISABLE CONSTRAINT EMP2_PK;

SELECT * FROM USER_CONSTRAINTS
WHERE TABLE_NAME IN ('EMP2','DEPT2')
AND CONSTRAINT_TYPE IN ('P','R')
ORDER BY TABLE_NAME;

SELECT * FROM USER_INDEXES
where table_name='EMP2';

ALTER TABLE EMP2
enable CONSTRAINT EMP2_PK;

SELECT * FROM USER_INDEXES
WHERE TABLE_NAME='EMP2';
---
ALTER TABLE DEPT2
disable CONSTRAINT DEPT2_PK;

ALTER TABLE DEPT2
DISABLE CONSTRAINT DEPT2_PK CASCADE ;

SELECT * FROM USER_CONSTRAINTS
WHERE TABLE_NAME IN ('EMP2','DEPT2')
AND CONSTRAINT_TYPE IN ('P','R')
ORDER BY TABLE_NAME;
-----------------------------------------------------





--we will learn more about constaints
--DEFERRABLE INITIALLY DEFERRED
-- DEFERRABLE INITIALLY immediate

DROP TABLE EMP_SAL;

CREATE TABLE EMP_SAL
( EMP_ID NUMBER,
  SAL NUMBER,
  BONUS NUMBER,
  CONSTRAINT SAL_CK CHECK (SAL>100),
  constraint bouns_ck check(BONUS>0)
);

--look at the columns DEFERRABLE and DEFErred
SELECT * FROM USER_CONSTRAINTS
WHERE TABLE_NAME='EMP_SAL';

--any dml that not meet the condition, the error will be immediate
INSERT INTO EMP_SAL(EMP_ID,SAL,BONUS)
VALUES (1,90,5);

INSERT INTO EMP_SAL(EMP_ID,SAL,BONUS)
VALUES (1,100,-2);

--lets drop the constraints and re create it with new options
ALTER TABLE EMP_SAL
DROP CONSTRAINT SAL_CK;

ALTER TABLE EMP_SAL
DROP CONSTRAINT bouns_ck;

ALTER TABLE EMP_SAL
ADD CONSTRAINT SAL_CK CHECK (SAL>100) DEFERRABLE INITIALLY DEFERRED;

ALTER TABLE EMP_SAL
ADD CONSTRAINT bouns_ck CHECK (BONUS>0) DEFERRABLE INITIALLY immediate;

SELECT * FROM USER_CONSTRAINTS
WHERE TABLE_NAME='EMP_SAL';

--the first one DEFERRABLE INITIALLY DEFERRED, it wil be viloated when you try to commit
INSERT INTO EMP_SAL(EMP_ID,SAL,BONUS)
VALUES (1,90,5);

--the second one DEFERRABLE INITIALLY immediate, it wil be viloated immediate
INSERT INTO EMP_SAL(EMP_ID,SAL,BONUS)
VALUES (1,200,-1);


SET CONSTRAINT SAL_CK immediate;

SELECT * FROM USER_CONSTRAINTS
WHERE TABLE_NAME='EMP_SAL';

INSERT INTO EMP_SAL(EMP_ID,SAL,BONUS)
VALUES (1,90,5);
---------------------------------------------------------------------------------

DROP TABLE EMP_SAL;

CREATE TABLE EMP_SAL
( EMP_ID NUMBER,
  SAL NUMBER,
  BONUS NUMBER,
  CONSTRAINT SAL_CK CHECK (SAL>100) ,
  constraint bouns_ck check(BONUS>0)
);

--now you can not change the constraint to IMMEDIATE/ DEFERRED because it was created in normal way 
SET CONSTRAINT SAL_CK IMMEDIATE;
SET CONSTRAINT SAL_CK DEFERRED;

--------------------------------------------------------------------------------

--here will learn the GLOBAL TEMPORARY TABLE
--it is a table that hold data that exist only for the duration of the transction (session)
--each session can see and modify only its data

DROP TABLE CART;

CREATE GLOBAL TEMPORARY TABLE CART
( ITEM_NO NUMBER, QTY NUMBER )
ON COMMIT DELETE ROWS;


INSERT INTO CART VALUES (1,10);
INSERT INTO CART VALUES (2,4);

SELECT * FROM CART;

COMMIT;
SELECT * FROM CART;

DROP TABLE CART2;

CREATE GLOBAL TEMPORARY TABLE CART2
( ITEM_NO NUMBER, QTY NUMBER )
ON COMMIT preserve ROWS;

INSERT INTO CART2 VALUES (1,10);
INSERT INTO CART2 VALUES (2,13);
INSERT INTO CART2 VALUES (3,1);
COMMIT;

SELECT * FROM CART2;





--we will learn the sql loader
--SQL*Loader is a bulk loader utility used for moving data from external files into the Oracle database

DROP TABLE EMP_LOAD;

CREATE TABLE EMP_LOAD
(EMPNO NUMBER ,
FNAME VARCHAR2(100),
LNAME VARCHAR2(100) 
);

SELECT * FROM EMP_LOAD;


--we have file  emp.csv   in  E:\load
--we want to move the data from this file to the table EMP_LOAD
--we use SQL*Loader
--we need to do a file called conrol file .ctl ( example emp.ctl )
/*
Load Data
INFILE 'E:\load\emp.csv'
APPEND
INTO Table emp_load
FIELDS TERMINATED BY ',' 
(empno,
fname,
lname
)
*/
-- then after this  we execute this commnad sqlldr control=E:\load\emp.ctl log=E:\load\emp.log  from cmd windows command
--sqlldr control=E:\load\emp.ctl log=E:\load\emp.log
SELECT * FROM EMP_LOAD;
--go to the E:\load and see the log file , it will give you details about the loaded data

truncate table  EMP_LOAD;

--now update the file emp.csv, make some ids to be characters
--we want to know the bad file, the records that not inserted 
--sqlldr control=E:\load\emp.ctl log=E:\load\emp.log
-------------------------------------------------------------------------------------------------------------

--now we will learn how to create external tables
--external table is read only table whose metadata is stored in the Db, 
--but whose data is stored outside the db.
--no DML allowed, no indexes can be created on external tables
--you can access the data with 2 methods (oracle_loader or oracle_datapump )
--to read external data, first you need to create directory in the database
/*to create DIRECTORY you need create any DIRECTORY priv, the dba should give you this
conn sqlplus sys as sysdba
alter session set container=orclpdb;
grant create any DIRECTORY to hr;
*/

CREATE OR REPLACE DIRECTORY EMP_DIR
AS 'E:\external';

SELECT * FROM ALL_DIRECTORIES
WHERE DIRECTORY_NAME='EMP_DIR';

drop table EMP_LOAD_ext;

CREATE TABLE EMP_LOAD_ext
     (EMPLOYEE_NUMBER      NUMBER,
      FNAME   VARCHAR2(100),
      LNAME   VARCHAR2(100)
      )
    ORGANIZATION EXTERNAL
      (TYPE ORACLE_LOADER
      DEFAULT DIRECTORY EMP_DIR
      ACCESS PARAMETERS
        (RECORDS DELIMITED BY NEWLINE
         FIELDS TERMINATED BY ','
        )
      LOCATION ('old_emp_data.csv')
     )
     reject limit unlimited;

SELECT * FROM EMP_LOAD_EXT;

DELETE EMP_LOAD_EXT; --operation not supported on external organized table

DROP TABLE EMP_PUMP;

  cREATE TABLE EMP_pump
     (EMPLOYEE_NUMBER  ,
      FNAME ,
      LNAME 
      )
    ORGANIZATION EXTERNAL
      (TYPE ORACLE_DATAPUMP
      DEFAULT DIRECTORY EMP_DIR
      LOCATION ('EMP.dmp')
     )
     AS 
     SELECT EMPLOYEE_ID, FIRST_NAME,LAST_NAME
     from EMPLOYEES;
     
SELECT * FROM EMP_PUMP;


--drop table EMP_PUMP_READ;

CREATE TABLE EMP_PUMP_READ
     (EMPLOYEE_NUMBER NUMBER ,
      FNAME   VARCHAR2(100),
      LNAME  VARCHAR2(100) 
      )
    ORGANIZATION EXTERNAL
      (TYPE ORACLE_DATAPUMP
      DEFAULT DIRECTORY EMP_DIR
      LOCATION ('EMP.dmp')
     );
     
select * from EMP_PUMP_READ;

