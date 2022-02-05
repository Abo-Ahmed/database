--number function
--take number and return number

--1 round function

SELECT ROUND(10.5) FROM DUAL; --if you didnt sepecify decimal places , then round without decimal 

SELECT ROUND(150.49) FROM DUAL;--if you didnt sepecify decimal places , then round without decimal 

SELECT ROUND(10.48, 1) FROM DUAL;

SELECT ROUND(10.499, 1) FROM DUAL;

SELECT ROUND(10.499, 2) FROM DUAL;

SELECT ROUND(10.493, 2) FROM DUAL;

SELECT ROUND(55.993, 1) FROM DUAL;

SELECT ROUND(55.993, -1) FROM DUAL;

SELECT ROUND(55.493, -2) FROM DUAL;

SELECT ROUND(555.493, -2) FROM DUAL;

SELECT ROUND(570.493, -3) FROM DUAL;

SELECT ROUND(470.493, -3) FROM DUAL;

SELECT ROUND(1470.493, -2) FROM DUAL;

--2  trunc function

SELECT TRUNC(10.6565) FROM DUAL;

SELECT TRUNC(10.6565, 2) FROM DUAL;

SELECT TRUNC(998.6565, -2) FROM DUAL;

SELECT TRUNC(9998.6565, -2) FROM DUAL;

SELECT TRUNC(998.6565, -3) FROM DUAL;

--3 MOD FUNCTION
--Return the remainder of devision

SELECT MOD(15,2) FROM DUAL;

SELECT MOD(15,3) FROM DUAL;

--the mod function is often use to know if the number id odd or even by divided by 2 

SELECT MOD(100,2) FROM DUAL; -- if return 0 then even

SELECT MOD(101,2) FROM DUAL; -- if return non zero value  then odd


