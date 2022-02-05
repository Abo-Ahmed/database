create table department ( 
dep_no number(11) primary key,
dep_name varchar2(30) not null unique,
head_id number(11) );


create table location (
location_id number(11) primary key , 
city varchar2(30) ,
street varchar2(30) ,
build_no number(11) ,
postal_code number (11) ,
countery varchar2(30) );


create table employee  (
emp_id number(11) primary key , 
dep_no number(11) not null,
fname varchar2(30) not null,
Lname varchar2(30) not null ,
email varchar2(30) ,
phone varchar2(30) ,
hiredate date ,
salary number (11) ,
commotion varchar2(30) 

, CONSTRAINT emp_dept_fk FOREIGN KEY (dep_no) REFERENCES department(dep_no)

);

ALTER TABLE department DROP COLUMN head_id ;
ALTER TABLE department ADD head_id number(11) REFERENCES employee(emp_id); 

create table job (
job_id number(11) primary key , 
job_name varchar2(30) not null ,
time date default systime );



create table emp_history (
emp_id number(11)  not null,
location_id number(11) not null, 
job_id number(11) not null,
stray varchar2(30) , 
startDate date not null,
endDate date not null ,
min_salary number (11 , 2 ) , 
max_salary number (11 , 2 ) ,

CONSTRAINT emp_fk FOREIGN KEY (emp_id) REFERENCES employee(emp_id) , 
CONSTRAINT loc_fk FOREIGN KEY (location_id) REFERENCES location(location_id) , 
CONSTRAINT job_fk FOREIGN KEY (job_id) REFERENCES job(job_id) , 

CONSTRAINT job_his_pk PRIMARY KEY (emp_id , location_id , job_id)


); 