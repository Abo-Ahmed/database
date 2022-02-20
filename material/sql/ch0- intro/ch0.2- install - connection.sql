
-- setup.exe from OracleXE112_Win64

-- tools to use
oracle command line
sql developer
click charts 
khalid khudiri course

-- create new database user using system account
sql> CONNECT SYS AS SYSDBA;
sql> PASSWORD: FENG;

-- create new account
sql> CREATE USER feng IDENTIFIED BY benha;
sql> GRANT CONNECT,RESOURCE TO feng;   /* grant user necessary priviledges  */

-- to use one of default user schemes like hr 
sql> ALTER USER hr ACCOUNT UNLOCK ;
sql> ALTER USER hr IDENTIFIED BY FENG;

sql> EXIT;
sql> CONNECT FENG/BENHA;
sql> CLEAR SCREEN;


-- to select all users 
SELECT * FROM ALL_USERS;


-- to select all tables 
SELECT * FROM ALL_TABLES;
SELECT * FROM USER_TABLES;

-- to select date and timestamp
SELECT CURRENT_TIMESTAMP FROM DUAL;
SELECT CURRENT_DATE FROM DUAL;

-- to describe table columns
DESC <TABLE NAME>
DESCRIBE <TABLE NAME>

-- to select current database name
SELECT ORA_DATABASE_NAME FROM DUAL;
SELECT * FROM GLOBAL_NAME;


-- in this path
-- C:\oraclexe\app\oracle\product\11.2.0\server\network\ADMIN
-- in file: tnsnames.ora port info for database 
XE =
  (DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST = DESKTOP-6BKCN40)(PORT = 1521))
    (CONNECT_DATA =
      (SERVER = DEDICATED)
      (SERVICE_NAME = XE)
    )
  )

-- DBA stands for: Database Adminstrator

-- to open all plugable databases
alter PLUGGABLE DATABASE open;


