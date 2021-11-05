CREATE OR REPLACE PROCEDURE PSR.UPDATE_SADAD_BILLS_CONFIRM 
                          (
                            P_PARTNER_CODE				IN 	VARCHAR(100),				  											
                            P_SADAD_UPLOAD_REQUEST_ID	IN  VARCHAR(36),
                            P_SADAD_CONFIRM_REQUEST_ID	IN  VARCHAR(36) --x this type should be INT
                            --P_CONFIRMATION_ERROR_CODE 	IN 	VARCHAR(1) --x CHECK THIS SIZE
                          )

IS
-- variable defination -------------------------------
  -------------------------Error Codes Declaration----------------------------
  V_SUCCESSFUL_OPERATION  		  VARCHAR(10) DEFAULT 'I000000';
  V_DATABASE_ERROR  	          VARCHAR(10) DEFAULT 'E999998';
  V_BILLER_ID_IS_REQUIRED  		  VARCHAR(10) DEFAULT 'E000015';
  V_SADAD_REQ_IS_REQUIRED  		  VARCHAR(10) DEFAULT 'E000030';
  V_SADAD_REP_IS_REQUIRED  		  VARCHAR(10) DEFAULT 'E000031';
  V_SADAD_REQ_IS_INVALID 	      VARCHAR(10) DEFAULT 'E000050';
  V_INVALID_ERROR  	            VARCHAR(10) DEFAULT 'E000066';
  V_INVALID_SUCCESS  	          VARCHAR(10) DEFAULT 'E000067';
  V_INVALID_XML  	              VARCHAR(10) DEFAULT 'E000111';
  V_BILL_NUMBER_IS_RQUIRED      VARCHAR(10) DEFAULT 'E000042';
  V_ERR_CODE_IS_RQUIRED         VARCHAR(10) DEFAULT 'E000032';
  V_ERR_MSG_IS_RQUIRED          VARCHAR(10) DEFAULT 'E000033';
  V_INVALID_BILL_NUMBER         VARCHAR(10) DEFAULT 'E000043';
  V_ERROR_EXIST                 VARCHAR(10) DEFAULT 'E000036';
  ------------------------- Declaration----------------------------
  V_START_TIME                  TIMESTAMP(9);
  V_VERSION             			  INT    := 1.0;
  SQLCODE                       INTEGER;
  SQLSTATE                      CHAR(5);
  V_LAST_SQLSTATE               CHAR(5);
  V_LAST_SQLCODE                INTEGER;
  V_JOB_ID                      VARCHAR(255);
  -----------------------------------------------------------------------------
  V_STATUS_CODE                 VARCHAR(30);
  V_STATUS_DESC                 VARCHAR(255);
  P_STATUS_CODE                 VARCHAR(4000);
  P_STATUS_DESC                 VARCHAR(4000);
  V_FAILURE_RESULT              CLOB;
  V_VALID                       VARCHAR(1) := 'N';
  V_BILLER_ID                   VARCHAR(15);
  V_PARKED_FLAG                 VARCHAR(1);
  ------------------- needed counters ---------------------
  V_COUNT                       INT    := 0.0;
  V_ERR_COUNT                   INT    := 0.0;
  V_BLR_BILL_CNT                INT    := 0.0;
  INVALID_CNT                   INT    := 0.0;
  SUCCESS_CNT                   INT    := 0.0;
  ---------------------   handler   --------------------
  EXIT_STORED_PROCEDURE         EXCEPTION ;

  TYPE BILL_NUMBER_t IS TABLE OF PSR.SADAD_BILLS_CONFIRMATION_ERROR.BILL_NUMBER%TYPE INDEX BY PLS_INTEGER;
  l_BILL_NUMBER   BILL_NUMBER_t;

  TYPE ERROR_CODE_t IS TABLE OF PSR.SADAD_BILLS_CONFIRMATION_ERROR.ERROR_CODE%TYPE INDEX BY PLS_INTEGER;
  l_ERROR_CODE   ERROR_CODE_t;

  TYPE ERROR_DESC_t IS TABLE OF PSR.SADAD_BILLS_CONFIRMATION_ERROR.ERROR_DESC%TYPE INDEX BY PLS_INTEGER;
  l_ERROR_DESC   ERROR_DESC_t;

BEGIN
  BEGIN

    V_START_TIME := CURRENT_TIMESTAMP;
    -- Insert into History Table ------------------------- 
      PSR.MANAGE_SADAD_BILL_HISTORY (
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
    
    ELSIF P_SADAD_CONFIRM_REQUEST_ID IS NOT NULL OR NVL(P_SADAD_CONFIRM_REQUEST_ID, '0') <> '0' THEN
        
      V_FAILURE_RESULT := '<Bills><SADADReqID>'
                              ||P_SADAD_UPLOAD_REQUEST_ID
                              ||'</SADADReqID><SADADReplyID>'
                              -- ||  REC.SB_SADAD_RPLY_ID 
                              || '</SADADReplyID>';

      SELECT  BILL_NUMBER , ERROR_CODE , ERROR_DESC
        BULK COLLECT INTO 
            l_BILL_NUMBER , l_ERROR_CODE , l_ERROR_DESC
        FROM  PSR.SADAD_BILLS_CONFIRMATION_ERROR
        WHERE PARTNER_CODE = P_PARTNER_CODE 
            AND SADAD_UPLOAD_REQUEST_ID = P_SADAD_UPLOAD_REQUEST_ID  
            AND SADAD_CONFIRM_REQUEST_ID = P_SADAD_CONFIRM_REQUEST_ID ;
      
      FOR index IN 1 .. l_BILL_NUMBER.COUNT
      LOOP
        V_VALID := 'Y';
        V_STATUS_CODE := NULL;
        V_STATUS_DESC := NULL;
            
        IF l_ERROR_CODE (index) IS NULL OR LENGTH(TRIM(l_ERROR_CODE(index))) = 0 THEN 
        
          V_STATUS_CODE := V_ERR_CODE_IS_RQUIRED;
          V_STATUS_DESC := 'SADAD Error Code is mandatory';
          V_VALID := 'N';
        
        ELSIF l_ERROR_DESC IS NULL OR LENGTH(TRIM(l_ERROR_DESC(index))) = 0 THEN 
        
          V_STATUS_CODE := V_ERR_MSG_IS_RQUIRED;
          V_STATUS_DESC := 'SADAD Error Msg is mandatory';
          V_VALID := 'N';

        ELSIF l_BILL_NUMBER IS NULL OR LENGTH(TRIM(l_BILL_NUMBER(index))) = 0 THEN 
            
          V_STATUS_CODE := V_BILL_NUMBER_IS_RQUIRED;
          V_STATUS_DESC := 'Bill Number is mandatory';
          V_VALID := 'N';
        
        ELSE 
        
          SELECT COUNT(*)
          INTO V_BLR_BILL_CNT
          FROM PSR.BILLS_SADAD
          WHERE PARTNER_CODE = P_PARTNER_CODE
            AND BILL_NUMBER = l_BILL_NUMBER(index)
            AND SADAD_BILLER_ID = V_BILLER_ID
            AND LAST_UPLOAD_SADAD_RQ = P_SADAD_UPLOAD_REQUEST_ID
            AND PSR.IS_VALID_ACTION_STATE('BILLS',SADAD_STATE,'SDDC') = 'Y'
            ;

          IF V_BLR_BILL_CNT = 0 THEN 

              V_STATUS_CODE := V_INVALID_BILL_NUMBER;
              V_STATUS_DESC := 'Invalid Bill Number';
              V_VALID := 'N';
          END IF;
        END IF; 
        
        IF V_VALID = 'N' THEN 
            
          P_STATUS_CODE := V_ERROR_EXIST;
          P_STATUS_DESC := 'One or more rejected Record';
          INVALID_CNT := INVALID_CNT + 1;
          
          V_FAILURE_RESULT := V_FAILURE_RESULT 
                                || '<Bill><StatusCode>' 
                                || V_STATUS_CODE
                                || '</StatusCode><StatusDesc>' 
                                || V_STATUS_DESC 
                                || '</StatusDesc><BillerID>'  
                      --x           || REC.SB_SADAD_BILLER_ID 
                                || '</BillerID><BillNumber>'
                                || l_BILL_NUMBER(index) 
                                || '</BillNumber></Bill>';
          
        ELSE
          
          	SUCCESS_CNT := SUCCESS_CNT + 1;
          -------------------------- Update Bill Record -------------------------   
            SELECT B.PARKED_FLAG
            INTO V_PARKED_FLAG
            FROM PSR.BILLS B
            WHERE  B.PARTNER_CODE = P_PARTNER_CODE
            AND  B.BILL_NUMBER = l_BILL_NUMBER(index);

                      
          IF NVL(V_PARKED_FLAG, 'N') = 'N' THEN

            UPDATE PSR.BILLS_SADAD
                SET SADAD_ERROR_CODE = DECODE(l_ERROR_CODE(index), '20017', '0', '20021', '0', l_ERROR_CODE(index)),
                    SADAD_ERROR_MSG = DECODE(l_ERROR_CODE(index), '20017', 'Success', '20021', 'Success', l_ERROR_DESC(index)),
                    SADAD_STATE = PSR.GET_NEXT_STATE('BILLS',SADAD_STATE,'SDDC',DECODE(l_ERROR_CODE(index), '20017', 'S', '20021', 'S', 'FT')),
                    LAST_ACTION = 'SDDC',
                    LAST_UPDATE_DATE = CURRENT_TIMESTAMP,
                    LAST_SADAD_CONFIRM_ORG_RQ = P_SADAD_UPLOAD_REQUEST_ID,
                    -- LAST_SADAD_CONFIRM_RQ = REC.SB_SADAD_RPLY_ID,
                    -- LAST_SADAD_CONFIRM_TS = REC.SB_CONFIRMATION_TIMESTAMP,
                    MIGRATED_BILL_NUMBER = DECODE(l_ERROR_CODE(index), '20017', NULL, '20021', NULL, MIGRATED_BILL_NUMBER)
                WHERE PARTNER_CODE = P_PARTNER_CODE
                AND BILL_NUMBER = l_BILL_NUMBER(index)
                -- AND SADAD_BILLER_ID = REC.SB_SADAD_BILLER_ID
                AND LAST_UPLOAD_SADAD_RQ = P_SADAD_UPLOAD_REQUEST_ID
                AND PSR.IS_VALID_ACTION_STATE('BILLS',SADAD_STATE,'SDDC') = 'Y'; 

          ELSE 
          
            UPDATE PSR.BILLS_SADAD BL
              SET  (
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
                    SELECT  DECODE(l_ERROR_CODE(index), '20017', '0', '20021', '0', l_ERROR_CODE(index)),
                    DECODE(l_ERROR_CODE(index), '20017', 'Success', '20021', 'Success', l_ERROR_DESC(index)),
                    PSR.GET_NEXT_STATE('BILLS', PSR.GET_NEXT_STATE('BILLS',BL.SADAD_STATE,'SDDC',DECODE(l_ERROR_CODE(index), '20017', 'S', '20021', 'S', 'FT')), DECODE(B.LAST_ACTION, 'U', 'BLU', 'E', 'BLE'), 'S'),
                    DECODE(B.LAST_ACTION, 'U', 'BLU', 'E', 'BLE'),
                    V_START_TIME,
                    P_SADAD_UPLOAD_REQUEST_ID,
                    --REC.SB_SADAD_RPLY_ID,
                    --REC.SB_CONFIRMATION_TIMESTAMP,
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
                    DECODE(l_ERROR_CODE(index), '20017', NULL, '20021', NULL, BL.MIGRATED_BILL_NUMBER)
                    FROM  PSR.BILLS B
                    WHERE PARTNER_CODE = P_PARTNER_CODE
                    AND BILL_NUMBER = l_BILL_NUMBER(index)
                  )
                WHERE PARTNER_CODE = P_PARTNER_CODE
                  AND BILL_NUMBER = l_BILL_NUMBER(index)
                  --AND SADAD_BILLER_ID = REC.SB_SADAD_BILLER_ID
                  AND LAST_UPLOAD_SADAD_RQ = P_SADAD_UPLOAD_REQUEST_ID
                  AND PSR.IS_VALID_ACTION_STATE('BILLS',SADAD_STATE,'SDDC') = 'Y';
          END IF;

        END IF;
        
                    
        
      END LOOP;
      
      V_FAILURE_RESULT := V_FAILURE_RESULT || '</Bills>';
      
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

      V_JOB_ID := P_SADAD_UPLOAD_REQUEST_ID || '_' || 
                            -- REC.SB_SADAD_RPLY_ID || '_' || 
                            PSR.RQ_ID_SEQ.NEXTVAL;
              
      PSR.MANAGE_JOB_LOG (
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
    
    END IF ;

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
  EXCEPTION
    WHEN EXIT_STORED_PROCEDURE THEN
      NULL;
    WHEN OTHERS THEN
      P_STATUS_CODE := V_DATABASE_ERROR;
      P_STATUS_DESC := SQLERRM||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE;
  END;
  -- debugging
    P_STATUS_CODE := V_SUCCESSFUL_OPERATION;
    P_STATUS_DESC := 'Success';    
    V_LAST_SQLSTATE   :=  SQLSTATE; 
    V_LAST_SQLCODE    :=  SQLCODE; 
      
    P_STATUS_CODE := CASE   WHEN COALESCE(P_STATUS_CODE, '') = '' 
                            THEN V_DATABASE_ERROR 
                            ELSE P_STATUS_CODE 
                        END  ;

    PSR.DEBUG_STORED_PROCEDURES
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

END PSR.UPDATE_SADAD_BILLS_CONFIRM;