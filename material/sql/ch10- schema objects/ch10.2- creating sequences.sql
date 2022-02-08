--creating basic sequence

CREATE SEQUENCE DEPT_S;

SELECT * FROM USER_SEQUENCES
WHERE SEQUENCE_NAME='DEPT_S';

-- select length('9999999999999999999999999999') from dual;

DROP TABLE DEPT_TEST_S;

CREATE TABLE DEPT_TEST_S
( DEPNO NUMBER PRIMARY KEY,
  DNAME VARCHAR2(100)
 );
  
INSERT INTO DEPT_TEST_S (DEPNO, DNAME) 
VALUES (DEPT_S.NEXTVAL,'Sales');

INSERT INTO DEPT_TEST_S (DEPNO, DNAME) 
VALUES (DEPT_S.NEXTVAL,'Operation');

SELECT * FROM DEPT_TEST_S;

SELECT DEPT_S.CURRVAL FROM DUAL;

SELECT DEPT_S.nextval FROM DUAL;

INSERT INTO DEPT_TEST_S (DEPNO, DNAME) 
VALUES (DEPT_S.NEXTVAL,'IT');

SELECT * FROM DEPT_TEST_S;
--------------------------------------------------------------------------
DROP SEQUENCE DEPT_S1;

CREATE SEQUENCE DEPT_S1
START WITH 10
INCREMENT BY 20;

SELECT * FROM USER_SEQUENCES
WHERE SEQUENCE_NAME='DEPT_S1';

DELETE FROM DEPT_TEST_S;

INSERT INTO DEPT_TEST_S (DEPNO, DNAME) 
VALUES (DEPT_S1.NEXTVAL,'Marketing');

INSERT INTO DEPT_TEST_S (DEPNO, DNAME) 
VALUES (DEPT_S1.NEXTVAL,'Help Desk');

SELECT * FROM DEPT_TEST_S;
---------------------------------------------------------------------------

DELETE FROM DEPT_TEST_S;

DROP SEQUENCE DEPT_S2;

CREATE SEQUENCE DEPT_S2
INCREMENT BY -5;

SELECT * FROM USER_SEQUENCES
WHERE SEQUENCE_NAME='DEPT_S2';

INSERT INTO DEPT_TEST_S (DEPNO, DNAME) 
VALUES (DEPT_S2.NEXTVAL,'Marketing');

INSERT INTO DEPT_TEST_S (DEPNO, DNAME) 
VALUES (DEPT_S2.NEXTVAL,'Help Desk');

SELECT * FROM DEPT_TEST_S;
----------------------------------------

UPDATE DEPT_TEST_S
SET DEPNO=DEPT_S2.NEXTVAL;

SELECT * FROM DEPT_TEST_S
ORDER BY 1;
----------------------------------------------

--you can create default value as sequence in create table

DROP SEQUENCE EMP_S;

CREATE SEQUENCE EMP_S;

DROP TABLE EM;

CREATE TABLE EM
( EMPID NUMBER DEFAULT EMP_S.NEXTVAL PRIMARY KEY ,
  NAME VARCHAR2(100),
  DEPTNO NUMBER
);

  
INSERT INTO EM (NAME )  VALUES ('JAMES');

INSERT INTO EM (NAME )  VALUES ('Mark');

SELECT * FROM EM;
------------------------------------------------------------

delete from DEPT_TEST_S;
delete FROM EM;
drop sequence DEPT_S;
CREATE SEQUENCE DEPT_S;
--using currval and nextval  in inserting scripts 
--insert department called (support ) in table DEPT_TEST_S using the squence  DEPT_S
--then insert 3 employees to EM table that work in support department

INSERT INTO DEPT_TEST_S (DEPNO, DNAME) 
VALUES (DEPT_S.NEXTVAL,'support');
INSERT INTO EM (NAME,DEPTNO )  VALUES ('ali',DEPT_S.CURRVAL);
INSERT INTO EM (NAME,DEPTNO )  VALUES ('ahmed',DEPT_S.currval);
INSERT INTO EM (NAME,DEPTNO )  VALUES ('samer',DEPT_S.currval);

SELECT * FROM DEPT_TEST_S;

SELECT * FROM EM;
---------------------------------------------------------------

--you can alter the sequence

SELECT * FROM USER_SEQUENCES
WHERE SEQUENCE_NAME='DEPT_S';

ALTER SEQUENCE DEPT_S
INCREMENT BY 100;

SELECT * FROM USER_SEQUENCES
WHERE SEQUENCE_NAME='DEPT_S';

ALTER SEQUENCE DEPT_S
CACHE 30;

SELECT * FROM USER_SEQUENCES
WHERE SEQUENCE_NAME='DEPT_S';

ALTER SEQUENCE DEPT_S
maxvalue 9999;

SELECT * FROM USER_SEQUENCES
WHERE SEQUENCE_NAME='DEPT_S';

--you can not change the start with
ALTER SEQUENCE DEPT_S 
START WITH 170;
----------------------------------------

DROP SEQUENCE S_CYCLE;


CREATE SEQUENCE S_CYCLE
START WITH 1
INCREMENT BY 1
MAXVALUE 5
nocache 
CYCLE;

SELECT S_CYCLE.NEXTVAL FROM DUAL;
SELECT S_CYCLE.NEXTVAL FROM DUAL;
SELECT S_CYCLE.NEXTVAL FROM DUAL;
SELECT S_CYCLE.NEXTVAL FROM DUAL;
SELECT S_CYCLE.NEXTVAL FROM DUAL;

SELECT S_CYCLE.NEXTVAL FROM DUAL;




--Creating Private SYNONYM E  for EMPLOYEES table

drop SYNONYM E;

CREATE SYNONYM E
FOR EMPLOYEES;


--so you can use the SYNONYM now to call the table 
SELECT * FROM e;

-- the SYNONYM info in dictionary view called user_SYNONYMS/ ALL_SYNONYMS
select * from user_SYNONYMS

--you can drop the SYNONYM
DROP SYNONYM E;


--you should have create public SYNONYM privilages in order to create PUBLIC SYNONYM 
CREATE PUBLIC SYNONYM EMPLOYEES FOR HR.EMPLOYEES;

--now other users that access to EMPLOYEES that can do (select * form EMPLOYEES )
-- no need to make ( select * form hr.EMPLOYEES )


--let us create table with 2 constraints ( one primary and another unique)

DROP TABLE EMP_IND;

CREATE TABLE EMP_IND
( EMPNO NUMBER CONSTRAINT EMP_IND_PK PRIMARY KEY,
  ENAME VARCHAR2(100) UNIQUE,
  NICKNAME VARCHAR2(100),
  email varchar2(100)
 );

INSERT INTO EMP_IND (EMPNO,ENAME,NICKNAME,EMAIL) 
VALUES ('1','Ahmed Samer','Ahmed.Samer','Ahmed.Samer@gmail.com');
INSERT INTO EMP_IND (EMPNO,ENAME,NICKNAME,EMAIL) 
VALUES ('2','Rami Nader','Rami.Nader','Rami.Nader@hotmail.com');
INSERT INTO EMP_IND (EMPNO,ENAME,NICKNAME,EMAIL) 
VALUES ('3','Khaled Ali','Khaled.Ali','Khaled.Ali@hotmail.com');
INSERT INTO EMP_IND (EMPNO,ENAME,NICKNAME,EMAIL) 
VALUES ('4','Hassan Nabil','Hassan.Nabil','Hassan.Nabil@yahoo.com');
COMMIT;


--the oracle create implicit UNIQUE indexes for the PK, UK and the name for 
--the index will be same the name of constraint name


SELECT * FROM USER_INDEXES
WHERE TABLE_NAME='EMP_IND';

SELECT * FROM USER_IND_COLUMNS
WHERE TABLE_NAME='EMP_IND';

--now the oracle will use the index in the where clause to speed the query

SELECT * FROM
EMP_IND
WHERE EMPNO=1; --you will see that oracle use the index in the explain plan

SELECT * FROM
EMP_IND
WHERE ename='Ahmed Samer';--you will see that oracle use the index in the explain plan

SELECT * FROM
EMP_IND
WHERE NICKNAME='Ahmed.Samer'; --no index on LNAME so the the oracle will make full scan on the table

CREATE INDEX EMP_IND_NICKNAME ON EMP_IND (NICKNAME);

SELECT * FROM USER_INDEXES
WHERE TABLE_NAME='EMP_IND';

--now the server will use the index for NICKNAME in the where clause
SELECT * FROM
EMP_IND
WHERE NICKNAME='Ahmed.Samer';

---now you can create unique index for email, but it is better to add unique constraint

CREATE UNIQUE INDEX EMP_IND_EMAIL ON EMP_IND (EMAIL);

--now if you try to insert existing email then you will see error like constraint 
INSERT INTO EMP_IND (EMPNO,ENAME,NICKNAME,EMAIL) 
VALUES ('10','karem Samer','Ahmed.Samer','Ahmed.Samer@gmail.com');

--also you can create another index for ENAME column, but using function-based index upper(ENAME)

SELECT * FROM
EMP_IND
WHERE upper(ename)='AHMED SAMER';

CREATE INDEX EMP_IND_UP_ENAME ON EMP_IND (UPPER(ENAME));

SELECT * FROM USER_INDEXES
WHERE TABLE_NAME='EMP_IND';

SELECT * FROM USER_IND_COLUMNS
WHERE TABLE_NAME='EMP_IND';

SELECT * FROM USER_IND_EXPRESSIONS
WHERE TABLE_NAME='EMP_IND';

SELECT * FROM
EMP_IND
WHERE UPPER(ENAME)='AHMED SAMER';
------------------------------------------------------------------

--naming the index while creating the table 
DROP TABLE EMP_IND1;

CREATE TABLE EMP_IND1
( EMPNO NUMBER CONSTRAINT EMP_IND1_PK PRIMARY KEY USING INDEX 
                    (create index EMP_IND1_ind on EMP_IND1 (EMPNO)  ),
  FNAME VARCHAR2(100),
  lname VARCHAR2(100),
  EMAIL VARCHAR2(100),
  gender char(1)
 );

--you can create index of composit columns
CREATE INDEX EMP_IND1_COMP ON EMP_IND1 (FNAME,LNAME);

SELECT * FROM USER_INDEXES
WHERE TABLE_NAME='EMP_IND1';

SELECT * FROM USER_IND_COLUMNS
WHERE TABLE_NAME='EMP_IND1';

--you can create index with type bitmap

CREATE  BITMAP INDEX EMP_IND_b ON EMP_IND1 (GENDER); --but this feature in the Enterprise Edition

---finaly you can drop the index

DROP INDEX EMP_IND1_COMP;





