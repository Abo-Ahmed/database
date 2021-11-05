CREATE OR REPLACE PROCEDURE PSR.UPDATE_SADAD_BILLS_CONFIRM (
                                            IN P_PARTNER_CODE	VARCHAR(100),
                                            IN P_SADAD_UPLOAD_REQUEST_ID	VARCHAR(36),
                                            IN P_SADAD_CONFIRM_REQUEST_ID	INT,
                                            IN P_CONFIRMATION_ERROR_CODE 	VARCHAR(80) --X CHECK THIS SIZE
                                                              )
BEGIN
    -- variable defination -------------------------------
      DECLARE V_START_TIME                     TIMESTAMP(9);
      DECLARE V_VERSION                        DECIMAL(4,2);
      DECLARE SQLCODE                          INTEGER;
      DECLARE SQLSTATE                         CHAR(5);
      DECLARE V_LAST_SQLSTATE                  CHAR(5);
      DECLARE V_LAST_SQLCODE                   INTEGER;
      DECLARE V_JOB_ID                         VARCHAR(255);
      -------------------------Error Codes Declaration----------------------------
      DECLARE V_SUCCESSFUL_OPERATION  		     VARCHAR(10) DEFAULT 'I000000';
      DECLARE V_DATABASE_ERROR  	             VARCHAR(10) DEFAULT 'E999998';
      DECLARE V_BILLER_ID_IS_REQUIRED  		     VARCHAR(10) DEFAULT 'E000015';
      DECLARE V_SADAD_REQ_IS_REQUIRED  		     VARCHAR(10) DEFAULT 'E000030';
      DECLARE V_SADAD_REP_IS_REQUIRED  		     VARCHAR(10) DEFAULT 'E000031';
      DECLARE V_SADAD_REQ_IS_INVALID 	         VARCHAR(10) DEFAULT 'E000050';
      DECLARE V_INVALID_ERROR  	               VARCHAR(10) DEFAULT 'E000066';
      DECLARE V_INVALID_SUCCESS  	             VARCHAR(10) DEFAULT 'E000067';
      DECLARE V_INVALID_XML  	                 VARCHAR(10) DEFAULT 'E000111';
      DECLARE V_BILL_NUMBER_IS_RQUIRED         VARCHAR(10) DEFAULT 'E000042';
      DECLARE V_ERR_CODE_IS_RQUIRED            VARCHAR(10) DEFAULT 'E000032';
      DECLARE V_ERR_MSG_IS_RQUIRED             VARCHAR(10) DEFAULT 'E000033';
      DECLARE V_INVALID_BILL_NUMBER            VARCHAR(10) DEFAULT 'E000043';
      DECLARE V_ERROR_EXIST                    VARCHAR(10) DEFAULT 'E000036';
      -----------------------------------------------------------------------------
      DECLARE V_STATUS_CODE                    VARCHAR(30);
      DECLARE V_STATUS_DESC                    VARCHAR(255);
      DECLARE P_STATUS_CODE                    VARCHAR(4000);
      DECLARE P_STATUS_DESC                    VARCHAR(4000);
      DECLARE V_FAILURE_RESULT                 CLOB(1M);
      DECLARE V_VALID                          VARCHAR(1) DEFAULT 'N';
      DECLARE V_BILLER_ID                      VARCHAR(15);
      DECLARE V_PARKED_FLAG                    VARCHAR(1);
      ------------------- needed counters ---------------------
      DECLARE V_COUNT                          INTEGER DEFAULT 0;
      DECLARE V_ERR_COUNT                      INTEGER DEFAULT 0;
      DECLARE V_BLR_BILL_CNT                   INTEGER DEFAULT 0;
      DECLARE INVALID_CNT                      INTEGER DEFAULT 0;
      DECLARE SUCCESS_CNT                      INTEGER DEFAULT 0;
      ---------------------   handler   --------------------
      DECLARE BUSINESS_CONDITION               CONDITION ;
      DECLARE EXIT HANDLER FOR                 SQLEXCEPTION         
      BEGIN   
        
        SET V_LAST_SQLSTATE       	=  SQLSTATE; 
        SET V_LAST_SQLCODE          =  SQLCODE; 
         
        SET P_STATUS_CODE = CASE  WHEN COALESCE(P_STATUS_CODE, '') = '' 
                                  THEN V_DATABASE_ERROR 
                                  ELSE P_STATUS_CODE 
                            END  ;
        
        CALL PSR.DEBUG_STORED_PROCEDURES
                                      (
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
                                        PARAM1_VALUE     => P_STATUS_DESC
                                      );
      END; 
      --ss
      SET V_START_TIME = CURRENT_TIMESTAMP;
      SET V_VERSION = 1.0;
    
    -- Insert into History Table ------------------------- 
      CALL PSR.MANAGE_SADAD_BILL_HISTORY  (
                                            P_MSG_ID                  => 'UPDATE_SADAD_BILLS_CONFIRM'||REPLACE(TO_CHAR(V_START_TIME, 'YYYY-MM-DD HH24:MI:SS'), ' ', 'T'),
                                            P_REQUEST_ID              => NULL,
                                            P_DBG_MD                  => NULL,
                                            P_SC_ID                   => NULL,
                                            P_FUN_ID                  => NULL,
                                            P_REQ_MODE                => NULL,
                                            P_CUST_LANG_PREF          => NULL,
                                            P_USER_ID                 => NULL,
                                            P_PARTNER_ID              => NULL,
                                            P_PARTNER_CODE            => P_PARTNER_CODE,
                                            P_STATUS_CODE             => V_STATUS_CODE,
                                            P_STATUS_DESC             => V_STATUS_DESC,
                                            P_BILL_NUMBER             => NULL,
                                            P_SADAD_REQUEST_ID        => P_SADAD_UPLOAD_REQUEST_ID,
                                            P_JOB_ID                  => NULL
                                          ); 
    -- Biller ID -----------------------------------------
      SELECT PPM_PAYMENT_METHOD_ID
        INTO V_BILLER_ID
        FROM GAM.PARTNER_PAYMENT_METHODS
        WHERE PPM_PARTNER_CODE = P_PARTNER_CODE
          AND PPM_PAYMENT_METHOD = 'SADAD'
          AND PPM_ENABLE_FLAG = 'Y'; 
    -- Loop on SADAD Bills -------------------------------
      IF P_SADAD_CONFIRM_REQUEST_ID IS NOT NULL AND P_SADAD_CONFIRM_REQUEST_ID = '0' THEN
        -------------------------- Update Bill Record ------------------------- 
          UPDATE PSR.BILLS_SADAD BL
            SET (
                  BL.SADAD_ERROR_CODE,
                  BL.SADAD_ERROR_MSG,
                  BL.SADAD_STATE,
                  BL.LAST_ACTION,
                  BL.LAST_UPDATE_DATE,
                  BL.LAST_SADAD_CONFIRM_ORG_RQ,
              --    BL.LAST_SADAD_CONFIRM_RQ,
              --    BL.LAST_SADAD_CONFIRM_TS,
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
                  BL.MIGRATED_BILL_NUMBER
                )
                =
                (
                  SELECT  0,
                          'Success',
                          DECODE  (
                                    NVL(B.PARKED_FLAG, 'N'), 
                                    'N', 
                                    PSR.GET_NEXT_STATE('BILLS', BL.SADAD_STATE, 'SDDC', 'S'),
                                    PSR.GET_NEXT_STATE  (
                                                          'BILLS', 
                                                          PSR.GET_NEXT_STATE('BILLS', BL.SADAD_STATE, 'SDDC', 'S'), 
                                                          DECODE(B.LAST_ACTION, 'U', 'BLU', 'E', 'BLE'),
                                                          'S'
                                                        )
                                  ),
                          DECODE  (
                                    NVL(B.PARKED_FLAG, 'N'), 
                                    'N', 
                                    'SDDC', 
                                    DECODE(B.LAST_ACTION, 'U', 'BLU', 'E', 'BLE')
                                  ),
                          V_START_TIME,
                          P_SADAD_UPLOAD_REQUEST_ID,
                      --    REC.SB_SADAD_RPLY_ID,
                      --    REC.SB_CONFIRMATION_TIMESTAMP,
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
                    WHERE B.PARTNER_CODE = P_PARTNER_CODE
                      AND B.BILL_NUMBER = BL.BILL_NUMBER
                )
                
              WHERE BL.PARTNER_CODE = P_PARTNER_CODE
                AND  BL.LAST_UPLOAD_SADAD_RQ = P_SADAD_UPLOAD_REQUEST_ID
                AND  PSR.IS_VALID_ACTION_STATE('BILLS', BL.SADAD_STATE, 'SDDC') = 'Y'
              --  AND  BL.SADAD_BILLER_ID = REC.SB_SADAD_BILLER_ID
              ;   
      
      ELSEIF P_SADAD_CONFIRM_REQUEST_ID IS NOT NULL OR NVL(P_SADAD_CONFIRM_REQUEST_ID, '0') <> '0' THEN
         
        SET V_FAILURE_RESULT = '<Bills><SADADReqID>'
                                ||P_SADAD_UPLOAD_REQUEST_ID
                                ||'</SADADReqID><SADADReplyID>'
                                -- ||  REC.SB_SADAD_RPLY_ID 
                                || '</SADADReplyID>';
   
        --S

        --E
        
        SET V_FAILURE_RESULT = V_FAILURE_RESULT || '</Bills>';
        ------------------------------------- Bills Confirmed at SADAD ----------------------------------
        -------------- Update Bill Record -----------
        UPDATE PSR.BILLS_SADAD BL
          SET (
                BL.SADAD_ERROR_CODE,
                BL.SADAD_ERROR_MSG,
                BL.SADAD_STATE,
                BL.LAST_ACTION,
                BL.LAST_UPDATE_DATE,
                BL.LAST_SADAD_CONFIRM_ORG_RQ,
                --BL.LAST_SADAD_CONFIRM_RQ,
                --BL.LAST_SADAD_CONFIRM_TS,
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
                BL.MIGRATED_BILL_NUMBER
              )
              =
              (
                SELECT  0,
                        'Success',
                        DECODE  (
                                  NVL(B.PARKED_FLAG, 'N'), 
                                  'N', 
                                  PSR.GET_NEXT_STATE('BILLS', BL.SADAD_STATE, 'SDDC', 'S'),
                                  PSR.GET_NEXT_STATE( 'BILLS', 
                                                      PSR.GET_NEXT_STATE('BILLS', BL.SADAD_STATE, 'SDDC', 'S'), 
                                                      DECODE(B.LAST_ACTION, 'U', 'BLU', 'E', 'BLE')
                                                      ,'S'
                                                    )
                                ),
                        DECODE  (
                                  NVL(B.PARKED_FLAG, 'N'), 
                                  'N', 
                                  'SDDC', 
                                  DECODE(B.LAST_ACTION, 'U', 'BLU', 'E', 'BLE')
                                ),
                        V_START_TIME,
                        P_SADAD_UPLOAD_REQUEST_ID,
                        -- REC.SB_SADAD_RPLY_ID,
                        -- REC.SB_CONFIRMATION_TIMESTAMP,
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
                  WHERE B.PARTNER_CODE = P_PARTNER_CODE
                    AND B.BILL_NUMBER = BL.BILL_NUMBER
              )
              WHERE  BL.PARTNER_CODE = P_PARTNER_CODE
                AND  BL.LAST_UPLOAD_SADAD_RQ = P_SADAD_UPLOAD_REQUEST_ID
                AND  PSR.IS_VALID_ACTION_STATE('BILLS', BL.SADAD_STATE, 'SDDC') = 'Y'
                -- AND  BL.SADAD_BILLER_ID = REC.SB_SADAD_BILLER_ID
                AND  BL.BILL_NUMBER NOT IN (
                                            SELECT BILL_NUMBER 
                                                FROM  PSR.SADAD_BILLS_CONFIRMATION_ERROR
                                                WHERE PARTNER_CODE = P_PARTNER_CODE 
                                                  AND SADAD_UPLOAD_REQUEST_ID = P_SADAD_UPLOAD_REQUEST_ID  
                                                  AND SADAD_CONFIRM_REQUEST_ID = P_SADAD_CONFIRM_REQUEST_ID 
                                            )
              ;
        
        SET V_JOB_ID = P_SADAD_UPLOAD_REQUEST_ID || '_' || 
                              -- REC.SB_SADAD_RPLY_ID || '_' || 
                              PSR.RQ_ID_SEQ.NEXTVAL;
                
        CALL PSR.MANAGE_JOB_LOG (
                                  P_MSG_ID              => 'UPDATE_SADAD_BILLS_CONFIRM'
                                                            ||REPLACE ( 
                                                                        TO_CHAR(V_START_TIME, 'YYYY-MM-DD HH24:MI:SS'),
                                                                        ' ',
                                                                        'T'
                                                                      ),
                                  P_REQUEST_ID          => NULL,
                                  P_DBG_MD              => NULL,
                                  P_SC_ID               => NULL,
                                  P_FUN_ID              => NULL,
                                  P_REQ_MODE            => NULL,
                                  P_CUST_LANG_PREF      => NULL,
                                  P_USER_ID             => NULL,
                                  P_PARTNER_ID          => NULL,
                                  P_PARTNER_CODE        => NULL,
                                  P_STATUS_CODE         => V_STATUS_CODE,
                                  P_STATUS_DESC         => V_STATUS_DESC,
                                  P_JOB_ID              => V_JOB_ID,
                                  P_JOB_DESC            => 'UPDATE_SADAD_BILLS_CONFIRM',
                                  P_START_TS            => V_START_TIME,
                                  P_JOB_REQUESTS_STATUS => V_FAILURE_RESULT,
                                  P_NO_OF_RECS          => (SUCCESS_CNT + INVALID_CNT),
                                  P_NO_OF_SUCCESS       => SUCCESS_CNT,
                                  P_NO_OF_FAILURE       => INVALID_CNT
                                );
      END IF;
    -- Update Parked Flag --------------------------------
      UPDATE PSR.BILLS BL
        SET BL.PARKED_FLAG = 'N'
        WHERE BL.PARTNER_CODE = P_PARTNER_CODE
          AND BL.PARKED_FLAG = 'Y'
          AND PSR.IS_SADAD_IMAGE  (
                                    'BILLS', 
                                    P_PARTNER_CODE, 
                                    BL.BILL_NUMBER, 
                                    BL.ACCOUNT_ID, 
                                    BL.BILL_CATEGORY, 
                                    BL.BILL_CYCLE,
                                    BL.BILL_AMOUNT, 
                                    BL.DUE_DATE, 
                                    BL.EXP_DATE, 
                                    BL.DISPLAY_LABLE_AR, 
                                    BL.DISPLAY_LABLE_EN,
                                    BL.BILL_REF_INFO, 
                                    BL.BENEFICIARY_NAME, 
                                    BL.BENEFICIARY_ID, 
                                    BL.BENEFICIARY_ID_TYPE,
                                    BL.BILL_DETAILS
                                  ) = 'Y';
    --ee
    -- success ------------------------------------------- 
      SET P_STATUS_CODE = V_SUCCESSFUL_OPERATION;
      SET P_STATUS_DESC = 'Success';
      SIGNAL BUSINESS_CONDITION; 

END 