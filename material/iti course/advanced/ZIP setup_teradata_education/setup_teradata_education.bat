rem this is setting up all necessary databases and tables

del *.txt

del *.bak

bteq 0<educ_create.bteq 1>educ_create_log.txt 2>educ_create_error.txt

bteq 0<student_create.bteq 1>student_create_log.txt 2>student_create_error.txt

bteq 0<sql2_tables_create.bteq 1>sql2_tables_create_log.txt 2>sql2_tables_create_error.txt

bteq 0<au_create.bteq 1>au_create_log.txt 2>au_create_error.txt

fastload <accounts.fastload >accounts_fld_log.txt

fastload <customer.fastload >customer_fld_log.txt

fastload <trans.fastload >trans_fld_log.txt

rem done
