--naming rules

--1 the object( table) should start by letter
CREATE TABLE 2EMP
( empno NUMBER );

--2 the table name should be 30 char or less 
CREATE TABLE employees_and_hr_infomation_table
( empno NUMBER );

--3 table name contain only A-Z |  a-z  | _  |  $ |  #
CREATE TABLE EMP-t
( empno NUMBER );

--4 table name should be not dublicates with another object owned by same user
CREATE TABLE EMPLOYEES
( empno NUMBER );

--5 should be not oracle reserved word ( select, from , where, table, ..... ) 
CREATE TABLE select
( empno NUMBER );
----------------------------------------------------------------------------------------------------------------------------------------------
--about number data type

create table test
( n1 number ,
  n2 number (5,3)
);


insert into test values (1655.66,1.34);

select * from test;

insert into test values (20.25,23.347);
select * from test;

insert into test values (444.25,23.3493666);

select * from test;

insert into test values (444.25,500);

------------------------------------------------------------------

--creating tables examples ( no constraints)

--1 create table without any constraints
CREATE TABLE XX_EMP_test
( EMP_ID NUMBER,
  eNAME VARCHAR2(100),
  SALARY NUMBER (8,2 ),
  START_DATE DATE,
  COMMISSION NUMBER (2,2),
  EMP_PIC BLOB,
  EMP_NOTES long --so it is better to use clob , refer to the page 5 in the presntation
)

SELECT * FROM XX_EMP_TEST; --not case sensitive

SELECT * FROM xx_eMP_tEST; --not case sensitive
-------------

-- 2 creating table/ columns using double quotation " ", this is not recommended from orracle 

CREATE TABLE  "XX_eMP_dOUBLE"
( EMP_ID NUMBER,
"Ename" VARCHAR2(100)
);

SELECT * FROM "XX_eMP_dOUBLE"; --so you use the double quotation when you want to query the table, it is case sensetive

SELECT EMP_ID, "Ename" 
FROM "XX_eMP_dOUBLE"; --also because you used double quotation when you defined the Ename, so it shoukd be "Ename" 

---------------------
--3 using the default

CREATE TABLE XX_EMP_test1
( EMP_ID NUMBER,
  eNAME VARCHAR2(100),
  SALARY NUMBER (8,2 ),
  START_DATE DATE default sysdate,
  COMMISSION NUMBER (2,2)
);

INSERT INTO XX_EMP_TEST1( EMP_ID, ENAME )
VALUES                  (1, 'khaled' );

COMMIT;

SELECT * FROM XX_EMP_TEST1;
----------------------

--4  you can query the table you created by using the dictionary tables user_tables

SELECT table_name FROM USER_TABLES;

SELECT OWNER, TABLE_NAME FROM ALL_TABLES 
WHERE OWNER='HR';  --ALL_TABLES YOU CAN SEE ALL THE TABLES IN DATABASE FOR ANY OWNER

-----------------------

--5 creating table with constraints, column level syntax
--this is not the best practice, use table level syntax better
CREATE TABLE XX_EMP_COL_CONST
 (EMP_ID NUMBER CONSTRAINT XX_EMP_COL_CONST_PK PRIMARY KEY,
  ENAME VARCHAR2(100) CONSTRAINT XX_EMP_COL_CONST_UK1 UNIQUE,
  SALARY NUMBER NOT NULL,
  GENDER CHAR(1) CONSTRAINT XX_EMP_COL_CONST_CHQ CHECK ( GENDER IN  ('M','F') ),
  DEPT_ID NUMBER CONSTRAINT XX_EMP_COL_CONST_FK1 REFERENCES DEPARTMENTS (DEPARTMENT_ID)
  );
  
SELECT * FROM USER_CONSTRAINTS
WHERE TABLE_NAME='XX_EMP_COL_CONST';

--TRY TO SEE THE CHECK CONSTRAINT
INSERT INTO XX_EMP_COL_CONST (EMP_ID,ENAME,SALARY,GENDER,DEPT_ID)
VALUES                       (1, 'khaled',500,'D',NULL );

INSERT INTO XX_EMP_COL_CONST (EMP_ID,ENAME,SALARY,GENDER,DEPT_ID)
VALUES                       (1, 'khaled',500,NULL,NULL );

SELECT * FROM XX_EMP_COL_CONST;

--TRY TO SEE THE UNIQUE CONSTRAINT

INSERT INTO XX_EMP_COL_CONST (EMP_ID,ENAME,SALARY,GENDER,DEPT_ID)
VALUES                       (2, 'khaled',500,NULL,NULL );

----------------------------
--6 creating table with constraints, table level syntax
--this is  the best practice
--you can make the PK more than one columm,
--it force you to name the constraint 
CREATE TABLE XX_EMP_COL_CONST1
 (EMP_ID1 NUMBER,
  emp_id2 number,
  ENAME VARCHAR2(100),
  SALARY NUMBER NOT NULL,
  GENDER CHAR(1) ,
  DEPT_ID NUMBER ,
  CONSTRAINT XX_EMP_COL_CONST1_PK PRIMARY KEY (EMP_ID1,EMP_ID2),
  CONSTRAINT XX_EMP_COL_CONST1_UK1 UNIQUE(ENAME),
  CONSTRAINT XX_EMP_COL_CONST1_CHQ CHECK ( GENDER IN  ('M','F') ),
  CONSTRAINT XX_EMP_COL_CONST1_FK1 foreign key (DEPT_ID)REFERENCES DEPARTMENTS (DEPARTMENT_ID)
  );
  
desc  XX_EMP_COL_CONST1
---------------

--7  on delete cascade
delete from departments; --it is master table, you can not delete it

CREATE TABLE DPET1
(DEPTNO NUMBER,
 DNAME VARCHAR2(100),
 CONSTRAINT DPET1_PK PRIMARY KEY (DEPTNO ) 
 );
 
INSERT INTO DPET1 (DEPTNO,DNAME)
VALUES (1,'HR DEPT');
INSERT INTO DPET1 (DEPTNO,DNAME)
VALUES (2,'PO DEPT');
COMMIT;

SELECT  * FROM DPET1;

CREATE TABLE EMP1
( EMPID NUMBER PRIMARY KEY,
  ENAME VARCHAR2(100),
  DEPTNO NUMBER,
  CONSTRAINT EMP1_FK FOREIGN KEY (DEPTNO) REFERENCES DPET1(DEPTNO) ON DELETE CASCADE
);

INSERT INTO EMP1 VALUES (1, 'khaled','1');
INSERT INTO EMP1 VALUES (2, 'ali','1');
INSERT INTO EMP1 VALUES (3, 'ahmed','1');
INSERT INTO EMP1 VALUES (4, 'rania','2');
INSERT INTO EMP1 VALUES (5, 'lara','2');
COMMIT;

SELECT * FROM EMP1;

DELETE FROM DPET1
WHERE DEPTNO=1;

SELECT * FROM EMP1;
------------------------------------------------------------------------


--8  on delete set null


CREATE TABLE DPET2
(DEPTNO NUMBER,
 DNAME VARCHAR2(100),
 CONSTRAINT DPET2_PK PRIMARY KEY (DEPTNO ) 
 );
 
INSERT INTO DPET2 (DEPTNO,DNAME)
VALUES (1,'HR DEPT');
INSERT INTO DPET2 (DEPTNO,DNAME)
VALUES (2,'PO DEPT');
COMMIT;

SELECT  * FROM DPET2;

CREATE TABLE EMP2
( EMPID NUMBER PRIMARY KEY,
  ENAME VARCHAR2(100),
  DEPTNO NUMBER,
  CONSTRAINT EMP2_FK FOREIGN KEY (DEPTNO) REFERENCES DPET2(DEPTNO) ON DELETE set null
);

INSERT INTO EMP2 VALUES (1, 'khaled','1');
INSERT INTO EMP2 VALUES (2, 'ali','1');
INSERT INTO EMP2 VALUES (3, 'ahmed','1');
INSERT INTO EMP2 VALUES (4, 'rania','2');
INSERT INTO EMP2 VALUES (5, 'lara','2');
COMMIT;

SELECT * FROM EMP2;

DELETE FROM DPET2
WHERE DEPTNO=1;

SELECT * FROM EMP2;
---------------------------------------------------------------------



--create table as subquery

--1
CREATE TABLE E_EMP
AS SELECT EMPLOYEE_ID, FIRST_NAME, LAST_NAME, SALARY, DEPARTMENT_ID 
FROM EMPLOYEES
WHERE DEPARTMENT_ID=90;

DESC E_EMP;

SELECT * FROM E_EMP;

--2

CREATE TABLE E_EMP2(emp_id,   fname       ,lname   ,sal default 0, dept_id)
AS 
SELECT          EMPLOYEE_ID, FIRST_NAME, LAST_NAME, SALARY      , DEPARTMENT_ID 
FROM EMPLOYEES
WHERE DEPARTMENT_ID=90;

DESC E_EMP2;

SELECT * FROM E_EMP2;
---------------------------------------------------------------------------------------------

--using alter to add column

SELECT * FROM E_EMP;

ALTER TABLE E_EMP
ADD (GENDER CHAR(1) );

SELECT * FROM E_EMP;

ALTER TABLE E_EMP
ADD (COMMESSION NUMBER default 0  not null );

SELECT * FROM E_EMP;

ALTER TABLE E_EMP
ADD (COMMESSION1 NUMBER DEFAULT 0  );

SELECT * FROM E_EMP;

ALTER TABLE E_EMP
ADD (COMMESSION2 NUMBER not null); -- it will not work , only worked if the table is empty, or using default value

SELECT * FROM E_EMP;

ALTER TABLE E_EMP
ADD ( CREATED_DATE DATE default sysdate, CREATED_BY varchar2(100) DEFAULT USER );

select * from E_EMP;

--------------------------------------------------------

--using alter to modify a table
SELECT * FROM E_EMP;

ALTER TABLE E_EMP
MODIFY (CREATED_BY VARCHAR2(200) );

ALTER TABLE E_EMP
MODIFY (CREATED_BY VARCHAR2(50) );

ALTER TABLE E_EMP
MODIFY (CREATED_BY VARCHAR2(1) );

select * from E_EMP;

ALTER TABLE E_EMP
MODIFY (CREATED_BY  not null );

UPDATE E_EMP
SET GENDER='M';

select * from E_EMP;

ALTER TABLE E_EMP
MODIFY (GENDER  NUMBER );

ALTER TABLE E_EMP
MODIFY (GENDER  VARCHAR2(11) );

ALTER TABLE E_EMP
MODIFY (GENDER  CHAR(10) );

ALTER TABLE E_EMP
MODIFY (GENDER  VARCHAR2(9) );

ALTER TABLE E_EMP
MODIFY (GENDER  VARCHAR2(10) );

UPDATE E_EMP
SET GENDER=NULL;
COMMIT;

ALTER TABLE E_EMP
MODIFY (GENDER  VARCHAR2(9) );

ALTER TABLE E_EMP
MODIFY (GENDER  VARCHAR2(5) );

ALTER TABLE E_EMP
MODIFY (GENDER  VARCHAR2(1) );

ALTER TABLE E_EMP
MODIFY (GENDER  char(2) );

ALTER TABLE E_EMP
MODIFY (GENDER  VARCHAR2(1) );
----------------------------------------------------------------------------------

--drop a column
--try to drop column department_id from departments table, it will give you error
select * from E_EMP;

ALTER TABLE E_EMP
drop column CREATED_BY;   ---alter table  E_EMP  drop column (created_by, created_date );  this not allowed

SELECT * FROM E_EMP;

ALTER TABLE  E_EMP  DROP  ( GENDER, CREATED_DATE );

select * from E_EMP;

---------------------------++++++--------------------------

--set unesed

SELECT * FROM E_EMP2;

ALTER TABLE E_EMP2
SET UNUSED (SAL);

SELECT * FROM E_EMP2;

SELECT * FROM USER_UNUSED_COL_TABS;

UPDATE E_EMP2
SET SAL=100;
-----------------
SELECT * FROM E_EMP2;

ALTER TABLE E_EMP2
SET UNUSED (fname) ONLINE; -- it allow DML operation  while making the column unsed , it could take time

SELECT * FROM E_EMP2;

UPDATE E_EMP2
SET fname='xx';

SELECT * FROM USER_UNUSED_COL_TABS;

ALTER TABLE E_EMP2
drop unused columns; -- it remove the column phyiscaly

--------------------------------------------------------

---alter table read write

SELECT * FROM E_EMP2;

ALTER TABLE E_EMP2 READ ONLY;

DELETE FROM E_EMP2; --not allowed

alter table E_EMP2
add ( created_by varchar2(100)); -- DDL allowed because this statement not change data 

alter table E_EMP2
drop (created_by); --this DDL not allowed because this statement change data 

ALTER TABLE E_EMP2 READ write;   ---DML allowed now 

DELETE FROM E_EMP2;

------------------------------------
--drop table
SELECT * FROM E_EMP2;

DROP TABLE E_EMP2;

select * from E_EMP2;

SELECT * FROM USER_RECYCLEBIN
WHERE original_name='E_EMP2';

------------
create table x_test
as select * from jobs;

select * from x_test

drop table x_test purge;

SELECT * FROM USER_RECYCLEBIN
WHERE original_name='X_TEST';


-- rename a column
CREATE TABLE XX_DEPT_TABLE
( DEPTNO NUMBER,
  DANAME VARCHAR2(100)
);

SELECT * FROM XX_DEPT_TABLE;

ALTER TABLE XX_DEPT_TABLE
RENAME column DANAME TO DEPT_NAME;

SELECT * FROM XX_DEPT_TABLE;

--rename the object ( table)

RENAME XX_DEPT_TABLE TO XX_DEPT_T;

SELECT * FROM XX_DEPT_T;

select * from XX_DEPT_TABLE;

