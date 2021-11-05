CREATE PROCEDURE PSR.UPDATE_SADAD_BILLS_CONFIRM ()
	BEGIN
  DECLARE V_START_TIME TIMESTAMP(9);--
   DECLARE V_VERSION DECIMAL(4,2);--
   DECLARE SQLCODE               INTEGER;--
   DECLARE SQLSTATE              CHAR(5);--
   DECLARE V_LAST_SQLSTATE       CHAR(5);--
   DECLARE V_LAST_SQLCODE        INTEGER;--
   DECLARE V_JOB_ID VARCHAR(255);--
   -------------------------Error Codes Declaration------------------------------
   DECLARE V_SUCCESSFUL_OPERATION  		        VARCHAR(10) DEFAULT 'I000000';--
   DECLARE V_DATABASE_ERROR  	                VARCHAR(10) DEFAULT 'E999998';--
   DECLARE V_BILLER_ID_IS_REQUIRED  		    VARCHAR(10) DEFAULT 'E000015';--
   DECLARE V_SADAD_REQ_IS_REQUIRED  		    VARCHAR(10) DEFAULT 'E000030';--
   DECLARE V_SADAD_REP_IS_REQUIRED  		    VARCHAR(10) DEFAULT 'E000031';--
   DECLARE V_SADAD_REQ_IS_INVALID 	            VARCHAR(10) DEFAULT 'E000050';--
   DECLARE V_INVALID_ERROR  	                VARCHAR(10) DEFAULT 'E000066';--
   DECLARE V_INVALID_SUCCESS  	                VARCHAR(10) DEFAULT 'E000067';--
   DECLARE V_INVALID_XML  	                    VARCHAR(10) DEFAULT 'E000111';--
   DECLARE V_BILL_NUMBER_IS_RQUIRED             VARCHAR(10) DEFAULT 'E000042';--
   DECLARE V_ERR_CODE_IS_RQUIRED                VARCHAR(10) DEFAULT 'E000032';--
   DECLARE V_ERR_MSG_IS_RQUIRED                 VARCHAR(10) DEFAULT 'E000033';--
   DECLARE V_INVALID_BILL_NUMBER                VARCHAR(10) DEFAULT 'E000043';--
   DECLARE V_ERROR_EXIST                        VARCHAR(10) DEFAULT 'E000036';--
   -------------------------------------------------------------------------------
   DECLARE V_STATUS_CODE  VARCHAR(30);--
   DECLARE V_STATUS_DESC  VARCHAR(255);--
   DECLARE P_STATUS_CODE  VARCHAR(4000);--
   DECLARE P_STATUS_DESC  VARCHAR(4000);--
   DECLARE V_FAILURE_RESULT  CLOB(1M);--
   DECLARE V_VALID VARCHAR(1) DEFAULT 'N';--
   DECLARE V_BILLER_ID  VARCHAR(15);--
   DECLARE V_PARKED_FLAG VARCHAR(1);--
   ------------------- needed counters -----------------------
   DECLARE V_COUNT         INTEGER DEFAULT 0;--
   DECLARE V_ERR_COUNT     INTEGER DEFAULT 0;--
   DECLARE V_BLR_BILL_CNT   INTEGER DEFAULT 0;--
   DECLARE INVALID_CNT     INTEGER DEFAULT 0;--
   DECLARE SUCCESS_CNT     INTEGER DEFAULT 0;--
   ---------------------   handler   ----------------------
   DECLARE BUSINESS_CONDITION CONDITION ;--
   DECLARE  EXIT HANDLER FOR SQLEXCEPTION 
    BEGIN   
    
    SET V_LAST_SQLSTATE       	=  SQLSTATE; --
    SET V_LAST_SQLCODE          =  SQLCODE; --
    
   -- IF P_STATUS_CODE <> V_SUCCESSFUL_OPERATION THEN ROLLBACK; END IF;--
    
    SET P_STATUS_CODE=  CASE WHEN COALESCE(P_STATUS_CODE, '') = '' THEN V_DATABASE_ERROR ELSE P_STATUS_CODE END  ;--
    CALL PSR.DEBUG_STORED_PROCEDURES(
                          MSG_ID           => 'UPDATE_SADAD_BILLS_CONFIRM'||REPLACE(TO_CHAR(V_START_TIME, 'YYYY-MM-DD HH24:MI:SS'), ' ', 'T'),
                          P_REQUEST_ID     => NULL,
                          P_DBG_MD         => NULL,
                          P_SC_ID          => NULL,
                          P_FUN_ID         => NULL,
                          P_REQ_MODE       => NULL,
                          P_CUST_LANG_PREF => NULL,
                          P_USER_ID        => NULL,
                          STARTTIME        => V_START_TIME,
                          ORA_CODE         => V_LAST_SQLSTATE,
                          VERSION          => V_VERSION,
                          P_PARTNER_ID     => NULL,
                          P_PARTNER_CODE   => NULL,
                          STATUS_CODE      => P_STATUS_CODE,
                          P_NAME           => 'UPDATE_SADAD_BILLS_CONFIRM',
                          PARAM1_NAME      => 'P_STATUS_DESC',
                          PARAM1_VALUE     => P_STATUS_DESC);--
 END; --
 -------------------------------------------------------------------------------------------------------
   SET V_START_TIME = CURRENT_TIMESTAMP;--
   SET V_VERSION = 1.0;--
 -------------------------------------- Loop on SADAD Batches -----------------------------------------
   FOR REC AS C1 CURSOR  FOR  (SELECT SB_CONFIRMATION_ERRORS, 
                                      SB_CONFIRMATION_ERROR_CODE,
                                      SB_CONFIRMATION_ERROR_DESC,
                                      SB_PARTNER_CODE,
                                      SB_SADAD_BILLER_ID,
                                      SB_SADAD_REQ_ID,
                                      SB_SADAD_RPLY_ID,
                                      SB_CONFIRMATION_TIMESTAMP
                                FROM PSR.SADAD_BATCHES
                                 WHERE SB_CLOSED_FLAG IS NOT NULL 
                                   AND SB_BATCH_TYPE = 'SADAD_BILL_UPLOAD'
                                   AND SB_CLOSED_FLAG = 'N'
                                   AND (SB_SADAD_RPLY_ID IS NOT NULL AND SB_CONFIRMATION_TIMESTAMP IS NOT NULL
)) 
    DO 
     ----------------------------------- Insert into History Table ------------------------------ 
       CALL PSR.MANAGE_SADAD_BILL_HISTORY  (P_MSG_ID               => 'UPDATE_SADAD_BILLS_CONFIRM'||REPLACE(TO_CHAR(V_START_TIME, 'YYYY-MM-DD HH24:MI:SS'), ' ', 'T'),
                                         P_REQUEST_ID              => NULL,
                                         P_DBG_MD                  => NULL,
                                         P_SC_ID                   => NULL,
                                         P_FUN_ID                  => NULL,
                                         P_REQ_MODE                => NULL,
                                         P_CUST_LANG_PREF          => NULL,
                                         P_USER_ID                 => NULL,
                                         P_PARTNER_ID              => NULL,
                                         P_PARTNER_CODE            => REC.SB_PARTNER_CODE,
                                         P_STATUS_CODE             => V_STATUS_CODE,
                                         P_STATUS_DESC             => V_STATUS_DESC,
                                         P_BILL_NUMBER             => NULL,
                                         P_SADAD_REQUEST_ID        => REC.SB_SADAD_REQ_ID,
                                         P_JOB_ID                  => NULL); --
                                         
       --------------- Biller ID
       SELECT PPM_PAYMENT_METHOD_ID
       INTO V_BILLER_ID
       FROM GAM.PARTNER_PAYMENT_METHODS
       WHERE PPM_PARTNER_CODE = REC.SB_PARTNER_CODE
         AND PPM_PAYMENT_METHOD = 'SADAD'
         AND PPM_ENABLE_FLAG = 'Y';                      --
     -----------------------------------------------------------------------------------------------------------------------
     IF REC.SB_CONFIRMATION_ERRORS IS NOT NULL AND NVL(REC.SB_CONFIRMATION_ERROR_CODE, '0') <> '0' THEN
         SET V_FAILURE_RESULT = '<Bills><SADADReqID>'||REC.SB_SADAD_REQ_ID||'</SADADReqID><SADADReplyID>'
                                || REC.SB_SADAD_RPLY_ID || '</SADADReplyID>';--
         ------------------------------------- Accounts Confirmed with Errors at SADAD ------------------------------------
         FOR v1 AS
         c1 CURSOR FOR 
           SELECT *
           FROM XMLTABLE('$ERROR_INFO/BILL_ERROR_LIST/BILL_ERROR_INFO' PASSING
                 XMLPARSE(document REC.SB_CONFIRMATION_ERRORS) AS ERROR_INFO
                   COLUMNS
                     P_BILL_NUMBER                    VARCHAR(200) PATH 'BILL_NUMBER'
                    ,P_ERROR_CODE                    VARCHAR(30)  PATH 'ERROR_CODE'
                    ,P_ERROR_MSG                     VARCHAR(255) PATH 'ERROR_MSG')
          DO
                 SET V_VALID = 'Y';--
                 SET V_STATUS_CODE = NULL;--
                 SET V_STATUS_DESC = NULL;--
                 IF P_ERROR_CODE IS NULL OR LENGTH(TRIM(P_ERROR_CODE)) = 0 THEN --^--
                    SET V_STATUS_CODE = V_ERR_CODE_IS_RQUIRED;--
                    SET V_STATUS_DESC = 'SADAD Error Code is mandatory';--
                    SET V_VALID = 'N';--
                 ELSEIF P_ERROR_MSG IS NULL OR LENGTH(TRIM(P_ERROR_MSG)) = 0 THEN --^--
                    SET V_STATUS_CODE = V_ERR_MSG_IS_RQUIRED;--
                    SET V_STATUS_DESC = 'SADAD Error Msg is mandatory';--
                    SET V_VALID = 'N';--
                 ELSEIF P_BILL_NUMBER IS NULL OR LENGTH(TRIM(P_BILL_NUMBER)) = 0 THEN --^--
                    SET V_STATUS_CODE = V_BILL_NUMBER_IS_RQUIRED;--
                    SET V_STATUS_DESC = 'Bill Number is mandatory';--
                    SET V_VALID = 'N';--
                 ELSE --^--
                    SELECT COUNT(*)
                    INTO V_BLR_BILL_CNT
                    FROM PSR.BILLS_SADAD
                    WHERE PARTNER_CODE = REC.SB_PARTNER_CODE
                      AND BILL_NUMBER = P_BILL_NUMBER
                      AND SADAD_BILLER_ID = REC.SB_SADAD_BILLER_ID
                      AND LAST_UPLOAD_SADAD_RQ = REC.SB_SADAD_REQ_ID
                      AND PSR.IS_VALID_ACTION_STATE('BILLS',SADAD_STATE,'SDDC') = 'Y'
                      --AND SADAD_STATE IN ('UA', 'UE', 'UUA', 'UUE')
                      ;--
                    IF V_BLR_BILL_CNT = 0 THEN --|--
                        SET V_STATUS_CODE = V_INVALID_BILL_NUMBER;--
                        SET V_STATUS_DESC = 'Invalid Bill Number';--
                        SET V_VALID = 'N';--
                    END IF; --|--
                 END IF; --^--
                 IF V_VALID = 'N' THEN --&--
                   SET P_STATUS_CODE = V_ERROR_EXIST;--
                   SET P_STATUS_DESC = 'One or more rejected Record';--
                   SET INVALID_CNT = INVALID_CNT + 1;--
                   SET V_FAILURE_RESULT = V_FAILURE_RESULT || '<Bill><StatusCode>' || V_STATUS_CODE
                                         || '</StatusCode><StatusDesc>' || V_STATUS_DESC || '</StatusDesc>
                                          <BillerID>'  || REC.SB_SADAD_BILLER_ID || '</BillerID><BillNumber>'
                                        || P_BILL_NUMBER || '</BillNumber></Bill>';--
                ELSE --&--
                   SET SUCCESS_CNT = SUCCESS_CNT + 1;--
                 -------------------------- Update Bill Record -------------------------   
                 SELECT B.PARKED_FLAG
                 INTO V_PARKED_FLAG
                 FROM PSR.BILLS B
                 WHERE  B.PARTNER_CODE = REC.SB_PARTNER_CODE
                    AND B.BILL_NUMBER = P_BILL_NUMBER;--
                IF NVL(V_PARKED_FLAG, 'N') = 'N' THEN
                  UPDATE PSR.BILLS_SADAD
                  SET   SADAD_ERROR_CODE = DECODE(P_ERROR_CODE, '20017', '0', '20021', '0', P_ERROR_CODE),
                        SADAD_ERROR_MSG = DECODE(P_ERROR_CODE, '20017', 'Success', '20021', 'Success', P_ERROR_MSG),
                        SADAD_STATE = PSR.GET_NEXT_STATE('BILLS',SADAD_STATE,'SDDC',DECODE(P_ERROR_CODE, '20017', 'S', '20021', 'S', 'FT')),
                        LAST_ACTION = 'SDDC',
                        LAST_UPDATE_DATE = CURRENT_TIMESTAMP,
                        LAST_SADAD_CONFIRM_ORG_RQ = REC.SB_SADAD_REQ_ID,
                        LAST_SADAD_CONFIRM_RQ = REC.SB_SADAD_RPLY_ID,
                        LAST_SADAD_CONFIRM_TS = REC.SB_CONFIRMATION_TIMESTAMP,
                        MIGRATED_BILL_NUMBER = DECODE(P_ERROR_CODE, '20017', NULL, '20021', NULL, MIGRATED_BILL_NUMBER)
                    WHERE PARTNER_CODE = REC.SB_PARTNER_CODE
                      AND BILL_NUMBER = P_BILL_NUMBER
                      AND SADAD_BILLER_ID = REC.SB_SADAD_BILLER_ID
                      AND LAST_UPLOAD_SADAD_RQ = REC.SB_SADAD_REQ_ID
                      AND PSR.IS_VALID_ACTION_STATE('BILLS',SADAD_STATE,'SDDC') = 'Y'; --
                 ELSE 
                  UPDATE PSR.BILLS_SADAD BL
                  SET  (BL.SADAD_ERROR_CODE,
                        BL.SADAD_ERROR_MSG,
                        BL.SADAD_STATE,
                        BL.LAST_ACTION,
                        BL.LAST_UPDATE_DATE,
                        BL.LAST_SADAD_CONFIRM_ORG_RQ,
                        BL.LAST_SADAD_CONFIRM_RQ,
                        BL.LAST_SADAD_CONFIRM_TS,
                        BL.BILL_CYCLE, 
                        BL.BILL_AMOUNT, 
                        BL.DUE_DATE, 
                        BL.EXP_DATE, 
                        BL.BILL_REF_INFO,
                        BL.BILL_DETAILS,
                        BL.BENEFICIARY_NAME,
                        BL.BENEFICIARY_ID,
                        BL.BENEFICIARY_ID_TYPE,
                        BL.LAST_SADAD_STATUS,
                        BL.SADAD_BILLER_ID,
                        BL.MIGRATED_BILL_NUMBER)
					=
				   (SELECT DECODE(P_ERROR_CODE, '20017', '0', '20021', '0', P_ERROR_CODE),
				           DECODE(P_ERROR_CODE, '20017', 'Success', '20021', 'Success', P_ERROR_MSG),
						   PSR.GET_NEXT_STATE('BILLS', PSR.GET_NEXT_STATE('BILLS',BL.SADAD_STATE,'SDDC',DECODE(P_ERROR_CODE, '20017', 'S', '20021', 'S', 'FT')), DECODE(B.LAST_ACTION, 'U', 'BLU', 'E', 'BLE'), 'S'),
						   DECODE(B.LAST_ACTION, 'U', 'BLU', 'E', 'BLE'),
						   V_START_TIME,
						   REC.SB_SADAD_REQ_ID,
						   REC.SB_SADAD_RPLY_ID,
						   REC.SB_CONFIRMATION_TIMESTAMP,
						   B.BILL_CYCLE, 
                           B.BILL_AMOUNT, 
                           B.DUE_DATE, 
                           B.EXP_DATE, 
                           B.BILL_REF_INFO,
                           B.BILL_DETAILS,
                           B.BENEFICIARY_NAME,
                           B.BENEFICIARY_ID,
                           B.BENEFICIARY_ID_TYPE,
                           DECODE(B.LAST_ACTION, 'U', 'BillUpdated', 'E', 'BillExpired'),
                           V_BILLER_ID,
                           DECODE(P_ERROR_CODE, '20017', NULL, '20021', NULL, BL.MIGRATED_BILL_NUMBER)
					FROM PSR.BILLS B
					WHERE PARTNER_CODE = REC.SB_PARTNER_CODE
					  AND BILL_NUMBER = P_BILL_NUMBER)
                  WHERE   PARTNER_CODE = REC.SB_PARTNER_CODE
                      AND BILL_NUMBER = P_BILL_NUMBER
                      AND SADAD_BILLER_ID = REC.SB_SADAD_BILLER_ID
                      AND LAST_UPLOAD_SADAD_RQ = REC.SB_SADAD_REQ_ID
                      AND PSR.IS_VALID_ACTION_STATE('BILLS',SADAD_STATE,'SDDC') = 'Y';--
                 END IF;--
                END IF; --&--
          END FOR;--
          SET V_FAILURE_RESULT = V_FAILURE_RESULT || '</Bills>';--
          ------------------------------------- Bills Confirmed at SADAD ------------------------------------
          -------------- Update Bill Record -------------
          UPDATE PSR.BILLS_SADAD BL
          SET (BL.SADAD_ERROR_CODE,
               BL.SADAD_ERROR_MSG,
               BL.SADAD_STATE,
               BL.LAST_ACTION,
               BL.LAST_UPDATE_DATE,
               BL.LAST_SADAD_CONFIRM_ORG_RQ,
               BL.LAST_SADAD_CONFIRM_RQ,
               BL.LAST_SADAD_CONFIRM_TS,
			   BL.BILL_CYCLE, 
               BL.BILL_AMOUNT, 
               BL.DUE_DATE, 
               BL.EXP_DATE, 
               BL.BILL_REF_INFO,
               BL.BILL_DETAILS,
               BL.BENEFICIARY_NAME,
               BL.BENEFICIARY_ID,
               BL.BENEFICIARY_ID_TYPE,
               BL.LAST_SADAD_STATUS,
               BL.SADAD_BILLER_ID,
               BL.MIGRATED_BILL_NUMBER)
			=
		  (SELECT 0,
		          'Success',
				  DECODE (NVL(B.PARKED_FLAG, 'N'), 'N', PSR.GET_NEXT_STATE('BILLS', BL.SADAD_STATE, 'SDDC', 'S'),
				                                        PSR.GET_NEXT_STATE('BILLS', PSR.GET_NEXT_STATE('BILLS', BL.SADAD_STATE, 'SDDC', 'S'), DECODE(B.LAST_ACTION, 'U', 'BLU', 'E', 'BLE'), 'S')
						 ),
				  DECODE (NVL(B.PARKED_FLAG, 'N'), 'N', 'SDDC', DECODE(B.LAST_ACTION, 'U', 'BLU', 'E', 'BLE')),
				  V_START_TIME,
				  REC.SB_SADAD_REQ_ID,
				  REC.SB_SADAD_RPLY_ID,
				  REC.SB_CONFIRMATION_TIMESTAMP,
				  DECODE(NVL(B.PARKED_FLAG, 'N'), 'N', BL.BILL_CYCLE, B.BILL_CYCLE), 
                  DECODE(NVL(B.PARKED_FLAG, 'N'), 'N', BL.BILL_AMOUNT, B.BILL_AMOUNT), 
                  DECODE(NVL(B.PARKED_FLAG, 'N'), 'N', BL.DUE_DATE, B.DUE_DATE), 
                  DECODE(NVL(B.PARKED_FLAG, 'N'), 'N', BL.EXP_DATE, B.EXP_DATE), 
                  DECODE(NVL(B.PARKED_FLAG, 'N'), 'N', BL.BILL_REF_INFO, B.BILL_REF_INFO),
                  DECODE(NVL(B.PARKED_FLAG, 'N'), 'N', BL.BILL_DETAILS, B.BILL_DETAILS),
                  DECODE(NVL(B.PARKED_FLAG, 'N'), 'N', BL.BENEFICIARY_NAME, B.BENEFICIARY_NAME),
                  DECODE(NVL(B.PARKED_FLAG, 'N'), 'N', BL.BENEFICIARY_ID, B.BENEFICIARY_ID),
                  DECODE(NVL(B.PARKED_FLAG, 'N'), 'N', BL.BENEFICIARY_ID_TYPE, B.BENEFICIARY_ID_TYPE),
                  DECODE(NVL(B.PARKED_FLAG, 'N'), 'N', BL.LAST_SADAD_STATUS, DECODE(B.LAST_ACTION, 'U', 'BillUpdated', 'E', 'BillExpired')),
                  DECODE(NVL(B.PARKED_FLAG, 'N'), 'N', BL.SADAD_BILLER_ID, V_BILLER_ID),
                  NULL
		   FROM PSR.BILLS B
		   WHERE B.PARTNER_CODE = REC.SB_PARTNER_CODE
		     AND B.BILL_NUMBER = BL.BILL_NUMBER
		      )
          WHERE BL.PARTNER_CODE = REC.SB_PARTNER_CODE
           AND  BL.LAST_UPLOAD_SADAD_RQ = REC.SB_SADAD_REQ_ID
           AND  PSR.IS_VALID_ACTION_STATE('BILLS', BL.SADAD_STATE, 'SDDC') = 'Y'
           AND  BL.SADAD_BILLER_ID = REC.SB_SADAD_BILLER_ID
           AND  BL.BILL_NUMBER NOT IN (SELECT P_BILL_NUMBER FROM (SELECT *
                                                                  FROM XMLTABLE('$ERROR_INFO/BILL_ERROR_LIST/BILL_ERROR_INFO' PASSING
                                                                             XMLPARSE(document REC.SB_CONFIRMATION_ERRORS) AS ERROR_INFO
                                                                      COLUMNS
                                                                        P_BILL_NUMBER                    VARCHAR(100) PATH 'BILL_NUMBER') ) );--
   ------------------------------------------------------------------------------------------------------------
    SET V_JOB_ID = REC.SB_SADAD_REQ_ID || '_' || REC.SB_SADAD_RPLY_ID || '_' || PSR.RQ_ID_SEQ.NEXTVAL;--
    CALL PSR.MANAGE_JOB_LOG(
                P_MSG_ID         => 'UPDATE_SADAD_BILLS_CONFIRM'||REPLACE(TO_CHAR(V_START_TIME, 'YYYY-MM-DD HH24:MI:SS'), ' ', 'T'),
                P_REQUEST_ID     => NULL,
                P_DBG_MD         => NULL,
                P_SC_ID          => NULL,
                P_FUN_ID         => NULL,
                P_REQ_MODE       => NULL,
                P_CUST_LANG_PREF => NULL,
                P_USER_ID        => NULL,
                P_PARTNER_ID     => NULL,
                P_PARTNER_CODE   => NULL,
                P_STATUS_CODE    => V_STATUS_CODE,
                P_STATUS_DESC    => V_STATUS_DESC,
                P_JOB_ID         => V_JOB_ID,
                P_JOB_DESC       => 'UPDATE_SADAD_BILLS_CONFIRM',
                P_START_TS       => V_START_TIME,
                P_JOB_REQUESTS_STATUS => V_FAILURE_RESULT,
                P_NO_OF_RECS       => (SUCCESS_CNT + INVALID_CNT),
                P_NO_OF_SUCCESS    => SUCCESS_CNT,
                P_NO_OF_FAILURE    => INVALID_CNT);--
--      ELSEIF REC.SB_CONFIRMATION_ERROR_CODE IS NOT NULL AND REC.SB_CONFIRMATION_ERROR_CODE <> '0' THEN 
--          -------------------------- Update Bill Record -------------------------    
--          UPDATE PSR.BILLS_SADAD BL
--          SET (BL.SADAD_ERROR_CODE,
--               BL.SADAD_ERROR_MSG,
--               BL.SADAD_STATE,
--               BL.LAST_ACTION,
--               BL.LAST_UPDATE_DATE,
--               BL.LAST_SADAD_CONFIRM_ORG_RQ,
--               BL.LAST_SADAD_CONFIRM_RQ,
--               BL.LAST_SADAD_CONFIRM_TS,
--			   BL.BILL_CYCLE, 
--               BL.BILL_AMOUNT, 
--               BL.DUE_DATE, 
--               BL.EXP_DATE, 
--               BL.BILL_REF_INFO,
--               BL.BILL_DETAILS,
--               BL.BENEFICIARY_NAME,
--               BL.BENEFICIARY_ID,
--               BL.BENEFICIARY_ID_TYPE,
--               BL.LAST_SADAD_STATUS,
--               BL.SADAD_BILLER_ID)
--			=
--		  (SELECT REC.SB_CONFIRMATION_ERROR_CODE,
--		          REC.SB_CONFIRMATION_ERROR_DESC,
--				  DECODE (NVL(B.PARKED_FLAG, 'N'), 'N', PSR.GET_NEXT_STATE('BILLS', BL.SADAD_STATE, 'SDDC', 'FT'),
--				                                        PSR.GET_NEXT_STATE('BILLS', PSR.GET_NEXT_STATE('BILLS', BL.SADAD_STATE, 'SDDC', 'FT'), DECODE(B.LAST_ACTION, 'U', 'BLU', 'E', 'BLE'), 'S')
--						 ),
--				  DECODE (NVL(B.PARKED_FLAG, 'N'), 'N', 'SDDC', DECODE(B.LAST_ACTION, 'U', 'BLU', 'E', 'BLE')),
--				  V_START_TIME,
--				  REC.SB_SADAD_REQ_ID,
--				  REC.SB_SADAD_RPLY_ID,
--				  REC.SB_CONFIRMATION_TIMESTAMP,
--				  DECODE(NVL(B.PARKED_FLAG, 'N'), 'N', BL.BILL_CYCLE, B.BILL_CYCLE), 
--                  DECODE(NVL(B.PARKED_FLAG, 'N'), 'N', BL.BILL_AMOUNT, B.BILL_AMOUNT), 
--                  DECODE(NVL(B.PARKED_FLAG, 'N'), 'N', BL.DUE_DATE, B.DUE_DATE), 
--                  DECODE(NVL(B.PARKED_FLAG, 'N'), 'N', BL.EXP_DATE, B.EXP_DATE), 
--                  DECODE(NVL(B.PARKED_FLAG, 'N'), 'N', BL.BILL_REF_INFO, B.BILL_REF_INFO),
--                  DECODE(NVL(B.PARKED_FLAG, 'N'), 'N', BL.BILL_DETAILS, B.BILL_DETAILS),
--                  DECODE(NVL(B.PARKED_FLAG, 'N'), 'N', BL.BENEFICIARY_NAME, B.BENEFICIARY_NAME),
--                  DECODE(NVL(B.PARKED_FLAG, 'N'), 'N', BL.BENEFICIARY_ID, B.BENEFICIARY_ID),
--                  DECODE(NVL(B.PARKED_FLAG, 'N'), 'N', BL.BENEFICIARY_ID_TYPE, B.BENEFICIARY_ID_TYPE),
--                  DECODE(NVL(B.PARKED_FLAG, 'N'), 'N', BL.LAST_SADAD_STATUS, DECODE(B.LAST_ACTION, 'U', 'BillUpdated', 'E', 'BillExpired')),
--                  DECODE(NVL(B.PARKED_FLAG, 'N'), 'N', BL.SADAD_BILLER_ID, V_BILLER_ID)
--		   FROM PSR.BILLS B
--		   WHERE B.PARTNER_CODE = REC.SB_PARTNER_CODE
--		     AND B.BILL_NUMBER = BL.BILL_NUMBER
--		      )
--          WHERE BL.PARTNER_CODE = REC.SB_PARTNER_CODE
--           AND  BL.LAST_UPLOAD_SADAD_RQ = REC.SB_SADAD_REQ_ID
--           AND  PSR.IS_VALID_ACTION_STATE('BILLS', BL.SADAD_STATE, 'SDDC') = 'Y'
--           AND  BL.SADAD_BILLER_ID = REC.SB_SADAD_BILLER_ID;--
       ELSEIF REC.SB_CONFIRMATION_ERROR_CODE IS NOT NULL AND REC.SB_CONFIRMATION_ERROR_CODE = '0' THEN
         -------------------------- Update Bill Record ------------------------- 
          UPDATE PSR.BILLS_SADAD BL
          SET (BL.SADAD_ERROR_CODE,
               BL.SADAD_ERROR_MSG,
               BL.SADAD_STATE,
               BL.LAST_ACTION,
               BL.LAST_UPDATE_DATE,
               BL.LAST_SADAD_CONFIRM_ORG_RQ,
               BL.LAST_SADAD_CONFIRM_RQ,
               BL.LAST_SADAD_CONFIRM_TS,
			   BL.BILL_CYCLE, 
               BL.BILL_AMOUNT, 
               BL.DUE_DATE, 
               BL.EXP_DATE, 
               BL.BILL_REF_INFO,
               BL.BILL_DETAILS,
               BL.BENEFICIARY_NAME,
               BL.BENEFICIARY_ID,
               BL.BENEFICIARY_ID_TYPE,
               BL.LAST_SADAD_STATUS,
               BL.SADAD_BILLER_ID,
               BL.MIGRATED_BILL_NUMBER)
			=
		  (SELECT 0,
		          'Success',
				  DECODE (NVL(B.PARKED_FLAG, 'N'), 'N', PSR.GET_NEXT_STATE('BILLS', BL.SADAD_STATE, 'SDDC', 'S'),
				                                        PSR.GET_NEXT_STATE('BILLS', PSR.GET_NEXT_STATE('BILLS', BL.SADAD_STATE, 'SDDC', 'S'), DECODE(B.LAST_ACTION, 'U', 'BLU', 'E', 'BLE'), 'S')
						 ),
				  DECODE (NVL(B.PARKED_FLAG, 'N'), 'N', 'SDDC', DECODE(B.LAST_ACTION, 'U', 'BLU', 'E', 'BLE')),
				  V_START_TIME,
				  REC.SB_SADAD_REQ_ID,
				  REC.SB_SADAD_RPLY_ID,
				  REC.SB_CONFIRMATION_TIMESTAMP,
				  DECODE(NVL(B.PARKED_FLAG, 'N'), 'N', BL.BILL_CYCLE, B.BILL_CYCLE), 
                  DECODE(NVL(B.PARKED_FLAG, 'N'), 'N', BL.BILL_AMOUNT, B.BILL_AMOUNT), 
                  DECODE(NVL(B.PARKED_FLAG, 'N'), 'N', BL.DUE_DATE, B.DUE_DATE), 
                  DECODE(NVL(B.PARKED_FLAG, 'N'), 'N', BL.EXP_DATE, B.EXP_DATE), 
                  DECODE(NVL(B.PARKED_FLAG, 'N'), 'N', BL.BILL_REF_INFO, B.BILL_REF_INFO),
                  DECODE(NVL(B.PARKED_FLAG, 'N'), 'N', BL.BILL_DETAILS, B.BILL_DETAILS),
                  DECODE(NVL(B.PARKED_FLAG, 'N'), 'N', BL.BENEFICIARY_NAME, B.BENEFICIARY_NAME),
                  DECODE(NVL(B.PARKED_FLAG, 'N'), 'N', BL.BENEFICIARY_ID, B.BENEFICIARY_ID),
                  DECODE(NVL(B.PARKED_FLAG, 'N'), 'N', BL.BENEFICIARY_ID_TYPE, B.BENEFICIARY_ID_TYPE),
                  DECODE(NVL(B.PARKED_FLAG, 'N'), 'N', BL.LAST_SADAD_STATUS, DECODE(B.LAST_ACTION, 'U', 'BillUpdated', 'E', 'BillExpired')),
                  DECODE(NVL(B.PARKED_FLAG, 'N'), 'N', BL.SADAD_BILLER_ID, V_BILLER_ID),
                  NULL
		   FROM PSR.BILLS B
		   WHERE B.PARTNER_CODE = REC.SB_PARTNER_CODE
		     AND B.BILL_NUMBER = BL.BILL_NUMBER
		      )
          WHERE BL.PARTNER_CODE = REC.SB_PARTNER_CODE
           AND  BL.LAST_UPLOAD_SADAD_RQ = REC.SB_SADAD_REQ_ID
           AND  PSR.IS_VALID_ACTION_STATE('BILLS', BL.SADAD_STATE, 'SDDC') = 'Y'
           AND  BL.SADAD_BILLER_ID = REC.SB_SADAD_BILLER_ID;   --
       END IF;--
       ----------------------------- Update Parked Flag
       UPDATE PSR.BILLS BL
       SET BL.PARKED_FLAG = 'N'
       WHERE BL.PARTNER_CODE = REC.SB_PARTNER_CODE
         AND BL.PARKED_FLAG = 'Y'
         AND PSR.IS_SADAD_IMAGE ('BILLS', REC.SB_PARTNER_CODE, BL.BILL_NUMBER, BL.ACCOUNT_ID, BL.BILL_CATEGORY, BL.BILL_CYCLE,
                                 BL.BILL_AMOUNT, BL.DUE_DATE, BL.EXP_DATE, BL.DISPLAY_LABLE_AR, BL.DISPLAY_LABLE_EN,
                                 BL.BILL_REF_INFO, BL.BENEFICIARY_NAME, BL.BENEFICIARY_ID, BL.BENEFICIARY_ID_TYPE,
                                 BL.BILL_DETAILS) = 'Y';--
       ----------------------------- Close SADAD Batch
       CALL PSR.MANAGE_SADAD_BATCHES (P_MSG_ID                    => 'UPDATE_SADAD_BILLS_CONFIRM'||REPLACE(TO_CHAR(V_START_TIME, 'YYYY-MM-DD HH24:MI:SS'), ' ', 'T'),
                                    P_REQUEST_ID                  => NULL,
                                    P_DBG_MD                      => NULL,
                                    P_SC_ID                       => NULL,
                                    P_FUN_ID                      => 'E',
                                    P_REQ_MODE                    => NULL,
                                    P_CUST_LANG_PREF              => NULL,
                                    P_USER_ID                     => NULL,
                                    P_PARTNER_ID                  => NULL,
                                    P_PARTNER_CODE                => REC.SB_PARTNER_CODE,
                                    P_STATUS_CODE                 => V_STATUS_CODE,
                                    P_STATUS_DESC                 => V_STATUS_DESC,
					                P_SADAD_BILLER_ID             => REC.SB_SADAD_BILLER_ID ,      
                                    P_SADAD_REQ_ID                => REC.SB_SADAD_REQ_ID,
                                    P_SADAD_RPLY_ID               => NULL,
                                    P_BATCH_TYPE		          => 'SADAD_BILL_UPLOAD',
                                    P_RECORD_COUNT                => NULL,
                                    P_SUCCESS_COUNT               => NULL,
                                    P_ERROR_COUNT                 => NULL,
                                    P_CONFIRMATION_ERRORS         => NULL,
                                    P_UPLOAD_ERROR_CODE           => NULL,
                                    P_UPLOAD_ERROR_DESC           => NULL,
                                    P_CONFIRMATION_ERROR_CODE     => NULL,
                                    P_CONFIRMATION_ERROR_DESC     => NULL);--
    END FOR; --
    SET P_STATUS_CODE = V_SUCCESSFUL_OPERATION;--
    SET P_STATUS_DESC = 'Success';--
    SIGNAL BUSINESS_CONDITION; --
END 