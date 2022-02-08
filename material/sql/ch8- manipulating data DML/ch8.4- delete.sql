--the delete
--1 lets create table dept_copy to be a copy from departments table

CREATE TABLE dept_copy
AS SELECT * FROM DEPARTMENTS;

SELECT * FROM DEPT_COPY;

DESC DEPT_COPY;

--2
SELECT * FROM DEPT_COPY
where DEPARTMENT_ID=10;

DELETE from DEPT_COPY
WHERE DEPARTMENT_ID=10;
COMMIT;

SELECT * FROM DEPT_COPY
WHERE DEPARTMENT_ID=10;

--3 the keyword from is optional in delete 
DELETE DEPT_COPY
WHERE DEPARTMENT_ID=10;
COMMIT;

--4 if there is no where condition then all rows in the table will be deleted 

DELETE  from DEPT_COPY;

--5 you can rollback the delete 
ROLLBACK;

SELECT * FROM DEPT_COPY;

--6 delete based on subquery

DELETE FROM DEPT_COPY
WHERE DEPARTMENT_ID IN (SELECT DEPARTMENT_ID FROM  DEPT_COPY WHERE DEPARTMENT_name LIKE '%Public%');



--so here you can not delete , child record found
--how you will remove this DEPARTMENT which have employees?????
delete from DEPARTMENTs
WHERE DEPARTMENT_ID=90;

--9 truncate

TRUNCATE TABLE DEPT_COPY; --you can not rollback

SELECT * FROM DEPT_COPY; --the table is empty









