CREATE OR REPLACE PROCEDURE RAJHI_BPM_OPS.GET_SAMA_REQUEST_LIST (
                                                          IN	 P_FUN_ID         	          VARCHAR(50)
                                                          IN   P_CUST_LANG_PREF             VARCHAR(10),
                                                          IN   P_USER_ID                    VARCHAR(50),
                                                          IN   P_USER_NAME                  VARCHAR(200),
                                                          OUT  P_STATUS_CODE                VARCHAR(10),
                                                          IN   P_PROCESS_INSTANCE_ID        VARCHAR(50),
                                                          IN   P_SAMA_REQUET_TYPE           VARCHAR(10),
                                                          IN   P_LETTER_NUMBER              VARCHAR(50),
                                                          IN   P_LETTER_SUBJECT             VARCHAR(200),
                                                          IN   P_REQUEST_CREATION_DATE_FROM VARCHAR(10),
                                                          IN   P_REQUEST_CREATION_DATE_TO   VARCHAR(10),
                                                          IN   P_EXECUTION_DEPARTMENT       CLOB(1M),
                                                          IN   P_STATE_CD                   VARCHAR(10),
                                                          IN   P_COMMENT                    VARCHAR(500),
                                                          IN   P_BUSINESS_KEY               VARCHAR(60),
                                                          OUT  P_SAMA_REQUEST_LIST          CLOB(1M)
)

P1: BEGIN
    DECLARE TYPE T_EXECUTION_DEPARTMENT AS VARCHAR(50) ARRAY[];
    DECLARE V_EXECUTION_DEPARTMENT_TABLE      T_EXECUTION_DEPARTMENT ;

	DECLARE V_SUCCESSFUL_OPERATION  		                 VARCHAR(10) DEFAULT 'I000000';
    DECLARE V_DATABASE_ERROR  	                             VARCHAR(10) DEFAULT 'E999998';
    DECLARE V_FUNCTION_ID_IS_REQUIRED  	                     VARCHAR(10) DEFAULT 'E000001';
    DECLARE V_INVALID_FUNCTION_ID                            VARCHAR(10) DEFAULT 'E000002';
    DECLARE V_USER_ID_IS_REQUIRED                            VARCHAR(10) DEFAULT 'E000003';
    DECLARE V_REQUEST_TYPE_IS_REQUIRED                       VARCHAR(10) DEFAULT 'E000068';
    DECLARE V_REQUEST_TYPE_IS_INVALID                        VARCHAR(10) DEFAULT 'E000069';
	DECLARE V_START_TIME 			 TIMESTAMP;
    DECLARE SQLCODE                  INTEGER;
    DECLARE SQLSTATE                 CHAR(5);
    DECLARE V_LAST_SQLSTATE          CHAR(5);
    DECLARE V_LAST_SQLCODE           INTEGER;
    DECLARE V_GET_LIST               VARCHAR(100) DEFAULT 'GetSamaRequestList';
    DECLARE V_EXECUTION_DEPARTMENT_LIST  CLOB(1M);
    DECLARE V_EXECUTION_DEPARTMENT   VARCHAR(50);
    DECLARE V_LIST_COUNTER         INTEGER;
    
 
    	--------------   handlers   -------------------
  DECLARE BUSINESS_CONDITION CONDITION ;
  
  DECLARE  EXIT HANDLER FOR SQLEXCEPTION 
  BEGIN   
    
    SET V_LAST_SQLSTATE       	=  SQLSTATE; 
    SET V_LAST_SQLCODE          =  SQLCODE; 
    
    IF P_STATUS_CODE <> V_SUCCESSFUL_OPERATION THEN ROLLBACK; END IF;
    
    SET P_STATUS_CODE=  CASE WHEN COALESCE(P_STATUS_CODE, '') = '' THEN V_DATABASE_ERROR ELSE P_STATUS_CODE END  ;
    
     CALL RAJHI_BPM_OPS.DEBUG_STORED_PROCEDURES(
		RAJHI_BPM_OPS.STORED_PROCEDURE_DEBUGGING_SEQ.NEXTVAL,
		'GET_SAMA_REQUET_LIST' , 
		V_START_TIME , 
		CURRENT TIMESTAMP , 
		V_LAST_SQLSTATE , 
		NULL , 
		P_STATUS_CODE ,
	    P_FUN_ID ,  
		'P_CUST_LANG_PREF' , 
		P_CUST_LANG_PREF , 
		'P_USER_ID' , 
		P_USER_ID , 
		'P_USER_NAME' , 
		P_USER_NAME ,
		'P_PROCESS_INSTANCE_ID' , 
		P_PROCESS_INSTANCE_ID , 
		'P_SAMA_REQUET_TYPE',
		P_SAMA_REQUET_TYPE,
		'P_LETTER_NUMBER',
		P_LETTER_NUMBER,
		'P_LETTER_SUBJECT',
		P_LETTER_SUBJECT,
		'P_REQUEST_CREATION_DATE_FROM',
		P_REQUEST_CREATION_DATE_FROM,
		'P_REQUEST_CREATION_DATE_TO',
		P_REQUEST_CREATION_DATE_TO,
		--'P_EXECUTION_DEPARTMENT',
		--P_EXECUTION_DEPARTMENT,
		'P_STATE_CD',
		P_STATE_CD,
		P_PARAMETER51_NAME => 'P_SAMA_REQUEST_LIST',  
		P_PARAMETER51_VALUE => P_SAMA_REQUEST_LIST);
    
  END;  
  
  SET V_START_TIME = CURRENT TIMESTAMP;
    
	IF P_FUN_ID IS NULL OR P_FUN_ID = '' THEN
      SET P_STATUS_CODE = V_FUNCTION_ID_IS_REQUIRED;
      SIGNAL BUSINESS_CONDITION;
    END IF;
    
    IF P_FUN_ID NOT IN (V_GET_LIST) THEN 
      SET P_STATUS_CODE = V_INVALID_FUNCTION_ID;
      SIGNAL BUSINESS_CONDITION;
    END IF;
     IF P_USER_ID IS NULL OR P_USER_ID = '' THEN
      SET P_STATUS_CODE = V_USER_ID_IS_REQUIRED;
      SIGNAL BUSINESS_CONDITION;
    END IF;
    
       IF P_SAMA_REQUET_TYPE IS NULL OR P_SAMA_REQUET_TYPE ='' THEN 
      SET P_STATUS_CODE = V_REQUEST_TYPE_IS_REQUIRED;
      SIGNAL BUSINESS_CONDITION;
   END IF ; 
   
   IF  	P_SAMA_REQUET_TYPE NOT IN  ('Letter', 'Circular') THEN 
   
        SET P_STATUS_CODE = V_REQUEST_TYPE_IS_INVALID;
        SIGNAL BUSINESS_CONDITION;
   END IF ;
   
   IF P_CUST_LANG_PREF  = '' THEN 
      SET P_CUST_LANG_PREF = NULL ; 
   END IF ; 
   
   IF P_USER_NAME   = '' THEN 
      SET P_USER_NAME  = NULL ; 
   END IF ; 
    
    IF P_PROCESS_INSTANCE_ID   = '' THEN 
      SET P_PROCESS_INSTANCE_ID  = NULL ; 
   END IF ; 
   
   IF P_LETTER_NUMBER   = '' THEN 
      SET P_LETTER_NUMBER  = NULL ; 
   END IF ; 
   
    IF P_LETTER_SUBJECT   = '' THEN 
      SET P_LETTER_SUBJECT  = NULL ; 
   END IF ; 
   
    IF P_REQUEST_CREATION_DATE_FROM   = '' THEN 
      SET P_REQUEST_CREATION_DATE_FROM  = NULL ; 
   END IF ; 
    
    
    IF P_REQUEST_CREATION_DATE_TO   = '' THEN 
      SET P_REQUEST_CREATION_DATE_TO  = NULL ; 
   END IF ; 
   
     IF P_EXECUTION_DEPARTMENT   = '' THEN 
      SET P_EXECUTION_DEPARTMENT  = NULL ; 
   END IF ;
   
    IF P_STATE_CD   = '' THEN 
      SET P_STATE_CD  = NULL ; 
   END IF ;	
   
   IF P_COMMENT   = '' THEN 
      SET P_COMMENT  = NULL ; 
   END IF ;	 
    
    
   IF P_BUSINESS_KEY   = '' THEN 
      SET P_BUSINESS_KEY  = NULL ; 
   END IF ; 
   
    IF P_SAMA_REQUET_TYPE = 'Letter' THEN
    
       IF P_EXECUTION_DEPARTMENT IS NOT NULL THEN
       
          SET V_EXECUTION_DEPARTMENT_LIST = P_EXECUTION_DEPARTMENT;
          SET V_LIST_COUNTER = 1;
          
          WHILE LENGTH(V_EXECUTION_DEPARTMENT_LIST) > 0 DO
             		
                CALL  RAJHI_BPM_OPS.TOKENIZER(V_EXECUTION_DEPARTMENT_LIST, 
                                      V_EXECUTION_DEPARTMENT,
                                      V_EXECUTION_DEPARTMENT_LIST,
                                      ',');

			    SET V_EXECUTION_DEPARTMENT_TABLE[V_LIST_COUNTER] = V_EXECUTION_DEPARTMENT; 
	            SET V_LIST_COUNTER = V_LIST_COUNTER + 1;
          END WHILE; 
       END IF;    
             
       SELECT  XMLSERIALIZE(XMLELEMENT( NAME "SAMARequestList", 
     XMLAGG( XMLELEMENT( NAME  "SAMARequest",
                      XMLELEMENT( NAME  "RequestNumber",BOR_BUSINESS_KEY),
                      XMLELEMENT( NAME  "CreationDate",BOR_CREATION_DATE),
                      XMLELEMENT( NAME  "LetterSubject",L_SUBJECT),
                      XMLELEMENT( NAME  "LetterNumber",L_LETTER_NUMBER),
                      XMLELEMENT( NAME  "Status",STATUS),
                      XMLELEMENT( NAME  "Department",DEPARTMENT) ,
                      XMLELEMENT( NAME  "ProcessInstanceID",BOR_PROCESS_INSTANCE_ID)
                      )
                      ))AS CLOB) 
                      INTO P_SAMA_REQUEST_LIST
              FROM  ( SELECT DISTINCT BOR_PROCESS_INSTANCE_ID ,BOR_BUSINESS_KEY , BOR_CREATION_DATE,L_SUBJECT ,L_LETTER_NUMBER , 
                             --DECODE (P_CUST_LANG_PREF,'En',S.STATE_ENGLISH_NAME,'Ar',S.STATE_ARABIC_NAME,S.STATE_ENGLISH_NAME) STATUS ,
                              --DECODE (P_CUST_LANG_PREF ,'En',D.DEPARTMENT_LATIN_NAME,'Ar',D.DEPARTMENT_ARABIC_NAME,D.DEPARTMENT_LATIN_NAME) DEPARTMENT
                                      BOR_STATE_CD STATUS ,SM_EXECUTION_DEPARTMENT DEPARTMENT
                              		FROM RAJHI_BPM_OPS.BANKING_OPERATION_REQUEST 
                          			JOIN  RAJHI_BPM_OPS.LETTER ON BOR_PROCESS_INSTANCE_ID = L_PROCESS_INSTACE_ID
                          			JOIN RAJHI_BPM_OPS.SAMA_LETTER ON BOR_PROCESS_INSTANCE_ID =SM_PROCESS_INSTACE_ID
                          			--LEFT OUTER JOIN RAJHI_BPM_OPS.STATES S ON BOR_STATE_CD =S.STATE_CD
                          			--LEFT OUTER JOIN  RAJHI_BPM_OPS.DEPARTMENT D ON SM_EXECUTION_DEPARTMENT = DEPARTMENT_ID
                          			JOIN RAJHI_BPM_OPS.BANKING_OPERATION_REQUEST_AUDIT BORA ON BORA_PROCESS_INSTANCE_ID =BOR_PROCESS_INSTANCE_ID
                          			
                                WHERE (P_PROCESS_INSTANCE_ID IS NULL OR BOR_PROCESS_INSTANCE_ID =P_PROCESS_INSTANCE_ID)
                                AND   (P_LETTER_NUMBER IS NULL OR L_LETTER_NUMBER=P_LETTER_NUMBER)
                                AND   (P_LETTER_SUBJECT IS NULL OR L_SUBJECT=P_LETTER_SUBJECT )
                                AND   (P_EXECUTION_DEPARTMENT IS NULL OR SM_EXECUTION_DEPARTMENT IN (SELECT T.EXECUTION_DEPARTMENT FROM UNNEST(V_EXECUTION_DEPARTMENT_TABLE) AS T(EXECUTION_DEPARTMENT)))
                                AND   (P_STATE_CD IS NULL OR BOR_STATE_CD =P_STATE_CD)
                                AND   (P_COMMENT IS NULL OR BORA_COMMENT = P_COMMENT)
                                /*AND   (P_REQUEST_CREATION_DATE_FROM IS NULL OR P_REQUEST_CREATION_DATE_FROM <= BOR_CREATION_DATE )
                                AND   (P_REQUEST_CREATION_DATE_TO IS NULL OR P_REQUEST_CREATION_DATE_TO > BOR_CREATION_DATE )*/
                                AND ((P_REQUEST_CREATION_DATE_FROM IS NULL OR P_REQUEST_CREATION_DATE_TO IS NULL )OR
                          				BOR_CREATION_DATE BETWEEN TO_DATE(P_REQUEST_CREATION_DATE_FROM,'DD-MM-YYYY') AND TO_DATE(P_REQUEST_CREATION_DATE_TO,'DD-MM-YYYY'))
                             
                                AND   (P_BUSINESS_KEY IS NULL OR BOR_BUSINESS_KEY = P_BUSINESS_KEY) )
                            ;  
       ELSEIF P_SAMA_REQUET_TYPE = 'Circular' THEN 
       --to be completed 
       SELECT  XMLSERIALIZE(XMLELEMENT( NAME "SAMARequestList", 
     XMLAGG( XMLELEMENT( NAME  "SAMARequest",
                      XMLELEMENT( NAME  "RequestNumber",BOR_BUSINESS_KEY),
                      XMLELEMENT( NAME  "CreationDate",BOR_CREATION_DATE),
                      XMLELEMENT( NAME  "LetterSubject",L_SUBJECT),
                      XMLELEMENT( NAME  "LetterNumber",L_LETTER_NUMBER),
                      XMLELEMENT( NAME  "Status",STATUS),
                      XMLELEMENT( NAME  "Department",'') ,
                      XMLELEMENT( NAME  "ProcessInstanceID",BOR_PROCESS_INSTANCE_ID)
                      )
                      ))AS CLOB) 
                      INTO P_SAMA_REQUEST_LIST
              FROM  ( SELECT DISTINCT BOR_PROCESS_INSTANCE_ID,BOR_BUSINESS_KEY , BOR_CREATION_DATE,L_SUBJECT ,L_LETTER_NUMBER , 
                              --DECODE (P_CUST_LANG_PREF,'En',S.STATE_ENGLISH_NAME,'Ar',S.STATE_ARABIC_NAME,S.STATE_ENGLISH_NAME) STATUS
                                      BOR_STATE_CD STATUS
                          			FROM RAJHI_BPM_OPS.BANKING_OPERATION_REQUEST 
                          			JOIN  RAJHI_BPM_OPS.LETTER ON BOR_PROCESS_INSTANCE_ID = L_PROCESS_INSTACE_ID
                          			--LEFT OUTER JOIN RAJHI_BPM_OPS.STATES S ON BOR_STATE_CD =S.STATE_CD
                          			JOIN RAJHI_BPM_OPS.BANKING_OPERATION_REQUEST_AUDIT BORA ON BORA_PROCESS_INSTANCE_ID =BOR_PROCESS_INSTANCE_ID
                          			
                                WHERE (P_PROCESS_INSTANCE_ID IS NULL OR BOR_PROCESS_INSTANCE_ID =P_PROCESS_INSTANCE_ID)
                                AND   (P_LETTER_NUMBER IS NULL OR L_LETTER_NUMBER=P_LETTER_NUMBER)
                                AND   (P_LETTER_SUBJECT IS NULL OR L_SUBJECT=P_LETTER_SUBJECT )
                                AND   (P_STATE_CD IS NULL OR BOR_STATE_CD =P_STATE_CD)
                                AND   (P_COMMENT IS NULL OR BORA_COMMENT = P_COMMENT)
                                /*AND   (P_REQUEST_CREATION_DATE_FROM IS NULL OR P_REQUEST_CREATION_DATE_FROM <= BOR_CREATION_DATE )
                                AND   (P_REQUEST_CREATION_DATE_TO IS NULL OR P_REQUEST_CREATION_DATE_TO > BOR_CREATION_DATE )*/
                                AND ((P_REQUEST_CREATION_DATE_FROM IS NULL OR P_REQUEST_CREATION_DATE_TO IS NULL )OR
                          				BOR_CREATION_DATE BETWEEN TO_DATE(P_REQUEST_CREATION_DATE_FROM,'DD-MM-YYYY') AND TO_DATE(P_REQUEST_CREATION_DATE_TO,'DD-MM-YYYY'))
                             
                                AND   (P_BUSINESS_KEY IS NULL OR BOR_BUSINESS_KEY = P_BUSINESS_KEY) )
                            ;  
       
       
       
    END IF; 
    SET P_STATUS_CODE =V_SUCCESSFUL_OPERATION;
   SET V_START_TIME = CURRENT TIMESTAMP;
	SIGNAL BUSINESS_CONDITION;
END P1 