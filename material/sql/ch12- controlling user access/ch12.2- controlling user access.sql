--1 you have to connect sys as sysdba
--2 when the DBA connect, it will be on container db
--so he should move to the pluggable database first 
show con_name

alter session set container=orclpdb

show con_name

--the dba can know the users avilable from this dictionary table all_users
select * from all_users;

--to see the priv map
select * from SYSTEM_PRIVILEGE_MAP

--now lets create new user called demo

--this will create user demo with password demo1234
create user demo identified by demo1234; -- he can not login yet

--now these some sys priv
grant create session to demo;

grant create table to demo;
-- you can do this also : grant create session,create table to demo

GRANT UNLIMITED TABLESPACE TO DEMO;

grant create sequence to DEMO;

grant create view to demo;

grant create synonym to demo;
---------------------------------------------------------------------------
--now these some object priv
grant select on hr.employees to demo;

grant delete on hr.employees to demo;

grant update (salary)  on hr.employees to demo;

grant all on hr.locations to demo;

grant select, insert 
on hr.jobs to demo;

grant select 
on hr.countries
to public;



---------------------------------------------------------------
--the user demo can know his privileges by using this query
select * from session_privs;

--now if he have create table privileges then he can insert,update,delete, 
--select, alter, index on any table he create

create table emp
( empid number constraint emp_pk primary key,
  ename varchar2(100)
);

insert into emp values (1,'khaled');

select * from emp;

alter table emp
add (salary number);

select * from emp;


create sequence emp_s;

--he can create index for the table he create 
create index ename_ind on emp (ename);


create or replace view emp_v
as
select empid, ename
from emp;

--now the user demo he want to change his password , because the dba create for 
--his default password demo1234

alter user demo identified by demo_green;


select * from hr.employees;

--the demo user can make select * from employees without hr. only if there is public syonym for hr.employees

select * from all_synonyms
where table_name='EMPLOYEES'


update hr.employees
set department_id =null
where employee_id=1;

update hr.employees
set salary =500
where employee_id=1;



select * from session_privs;

select * from user_sys_privs;


select * from user_tab_privs_recd
order by 2;

select * from user_col_privs_recd;

grant select on emp to hr;

select * from user_tab_privs_made;

grant update (ename) on emp to hr;

select * from user_col_privs_made;

------------------------------------------------------


--con as sysdba
show con_name

alter session set container=orclpdb;

show con_name

create role manager;

grant create table, create view, create sequence
to manager;

SELECT * FROM ROLE_SYS_PRIVS
WHERE ROLE='MANAGER';

---------------------------
CREATE USER ahmed identified by ahmed123;

grant create session to ahmed;

grant unlimited tablespace to ahmed;


grant manager to ahmed;
------------------------------

CREATE ROLE QONLY;

GRANT SELECT ANY TABLE TO QONLY;

GRANT QONLY TO AHMED;

CREATE ROLE IUD_EMP;

GRANT INSERT,UPDATE, DELETE
ON
HR.EMPLOYEES
TO IUD_EMP;


GRANT IUD_EMP TO AHMED;


SELECT * FROM ROLE_TAB_PRIVS
WHERE ROLE='IUD_EMP'


------------------------------------------------------------


--ahmed connection
--1 create this table
create table course
( course_id number,
  course_name varchar2(100)
);

--2

grant select
on course
to hr
with grant option;


--3 go and open new session or connection to hr
--do this : select * from ahmed.course
--then this:
/*
grant select
on ahmed.course
to demo
with grant option;
*/

--4 open new session or connection to demo
--do this : select * from ahmed.course

--5 now ahmed he will do this
revoke select
on course
from hr;

--6 then hr and also demo can not do this: select * from ahmed.course 


-----------------------------------------------------------------------------



--USER AHMED CONNECTION

select * from session_privs;     

select * from user_sys_privs;

select * from user_role_privs;

select * from role_sys_privs;

SELECT * FROM ROLE_TAB_PRIVS
WHERE ROLE='IUD_EMP'

create table studnet
( student_id number,
  studnet_name varchar2(100)
);

grant select on
studnet to public; 

select * from hr.locations

select * from demo.emp

update hr.employees
set salary=salary+10
where employee_id=100;
 

