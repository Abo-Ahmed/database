CREATE OR REPLACE PROCEDURE PSR.UPDATE_SMPL_BILLS_CONFIRM 
                          (
                            P_MSG_ID                    IN    VARCHAR(48)   ,
                            P_REQUEST_ID                IN    VARCHAR(200)  ,
                            P_DBG_MD                    IN    VARCHAR(1)    ,
                            P_SC_ID                     IN    VARCHAR(20)   ,
                            P_FUN_ID                    IN    VARCHAR(20)   ,
                            P_REQ_MODE                  IN    VARCHAR(20)   ,
                            P_CUST_LANG_PREF            IN    VARCHAR(5)    ,
                            P_USER_ID                   IN    VARCHAR(4000) ,
                            P_PARTNER_ID                IN    VARCHAR(4000) ,
                            P_PARTNER_CODE              IN    VARCHAR(4000) ,
                            P_STATUS_CODE               OUT   VARCHAR(4000) ,
                            P_STATUS_DESC               OUT   VARCHAR(4000) , 
                            P_SMPL_UPLOAD_REQUEST_ID	  IN    VARCHAR(36)   ,
                            P_SMPL_CONFIRM_REQUEST_ID	IN    VARCHAR(36)   , 
                            P_CONFIRMATION_ERROR_CODE 	IN 	  VARCHAR(1) 
                          )
IS
-- variable defination -------------------------------
  -------------------------Error Codes Declaration----------------------------
  V_SUCCESSFUL_OPERATION  		  VARCHAR(10) DEFAULT 'I000000';
  V_DATABASE_ERROR  	          VARCHAR(10) DEFAULT 'E999998';
  V_BILLER_ID_IS_REQUIRED  		  VARCHAR(10) DEFAULT 'E000015';
  V_SMPL_REQ_IS_REQUIRED  		  VARCHAR(10) DEFAULT 'E000030';
  V_SMPL_REP_IS_REQUIRED  		  VARCHAR(10) DEFAULT 'E000031';
  V_SMPL_REQ_IS_INVALID 	      VARCHAR(10) DEFAULT 'E000050';
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
  ---------------------   collections   ----------------
  TYPE BILL_NUMBER_t IS TABLE OF PSR.SMPL_BILLS_CONFIRMATION_ERROR.BILL_NUMBER%TYPE INDEX BY PLS_INTEGER;
  l_BILL_NUMBER   BILL_NUMBER_t;
  
  TYPE ERROR_CODE_t IS TABLE OF PSR.SMPL_BILLS_CONFIRMATION_ERROR.ERROR_CODE%TYPE INDEX BY PLS_INTEGER;
  l_ERROR_CODE   ERROR_CODE_t;

  TYPE ERROR_DESC_t IS TABLE OF PSR.SMPL_BILLS_CONFIRMATION_ERROR.ERROR_DESC%TYPE INDEX BY PLS_INTEGER;
  l_ERROR_DESC   ERROR_DESC_t;
  
  ---------------------   collections   ----------------
  TYPE SMPL_BILL_NUMBER_t IS TABLE OF PSR.BILLS_SMPL.BILL_NUMBER%TYPE INDEX BY PLS_INTEGER;
  l_SMPL_BILL_NUMBER   SMPL_BILL_NUMBER_t;

  TYPE BILLS_BILL_NUMBER_t IS TABLE OF PSR.BILLS.BILL_NUMBER%TYPE INDEX BY PLS_INTEGER;
  l_PARKED_BILL_NUMBER   BILLS_BILL_NUMBER_t;
  
  TYPE PARKED_FLAG_t IS TABLE OF PSR.BILLS.PARKED_FLAG%TYPE INDEX BY PLS_INTEGER;
  l_PARKED_FLAG   PARKED_FLAG_t;
  l_SUTIBLE_PARKED_FLAG   PARKED_FLAG_t;

  TYPE V_VALID_t IS TABLE OF VARCHAR(1) INDEX BY PLS_INTEGER;
  l_V_VALID  V_VALID_t;

BEGIN
  BEGIN

    V_START_TIME := CURRENT_TIMESTAMP;
    -- Insert into History Table ------------------------- 
      PSR.MANAGE_SMPL_BILL_HISTORY (
                                      P_MSG_ID                  => 'UPDATE_SMPL_BILLS_CONFIRM'||REPLACE(TO_CHAR(V_START_TIME, 'YYYY-MM-DD HH24:MI:SS'), ' ', 'T'),
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
                                      P_SMPL_REQUEST_ID        => P_SMPL_UPLOAD_REQUEST_ID,
                                      P_JOB_ID                  => NULL
                                    ); 

    -- Biller ID -----------------------------------------
      SELECT PPM_PAYMENT_METHOD_ID
        INTO V_BILLER_ID
        FROM GAM.PARTNER_PAYMENT_METHODS
        WHERE PPM_PARTNER_CODE = P_PARTNER_CODE
          AND PPM_PAYMENT_METHOD = 'SMPL'
          AND PPM_ENABLE_FLAG = 'Y'; 
    -- Loop on SMPL Bills -------------------------------
    IF P_CONFIRMATION_ERROR_CODE IS NOT NULL AND P_CONFIRMATION_ERROR_CODE = '0' THEN
      -------------------------- Update Bill Record ------------------------- 
        UPDATE PSR.BILLS_SMPL BL
          SET (
                BL.SMPL_ERROR_CODE,
                BL.SMPL_ERROR_MSG,
                BL.SMPL_STATE,
                BL.LAST_ACTION,
                BL.LAST_UPDATE_DATE,
                BL.LAST_SMPL_CONFIRM_ORG_RQ,
                BL.LAST_SMPL_CONFIRM_RQ,
                BL.LAST_SMPL_CONFIRM_TS,
                BL.BILL_CYCLE, 
                BL.BILL_AMOUNT, 
                BL.DUE_DATE, 
                BL.EXP_DATE, 
                BL.BILL_REF_INFO,
                BL.BILL_DETAILS,
                BL.BENEFICIARY_NAME,
                BL.BENEFICIARY_ID,
                BL.BENEFICIARY_ID_TYPE,
                BL.LAST_SMPL_STATUS,
                BL.SMPL_BILLER_ID,
                BL.MIGRATED_BILL_NUMBER
              )
              =
              (
                SELECT  0,
                        'Success',
                        DECODE  (
                                  NVL(B.PARKED_FLAG, 'N'), 
                                  'N', 
                                  PSR.GET_NEXT_STATE('BILLS', BL.SMPL_STATE, 'SDDC', 'S'),
                                  PSR.GET_NEXT_STATE  (
                                                        'BILLS', 
                                                        PSR.GET_NEXT_STATE('BILLS', BL.SMPL_STATE, 'SDDC', 'S'), 
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
                        P_SMPL_UPLOAD_REQUEST_ID,
                        P_SMPL_CONFIRM_REQUEST_ID,
                        CURRENT_TIMESTAMP,
                        DECODE(NVL(B.PARKED_FLAG, 'N'), 'N', BL.BILL_CYCLE, B.BILL_CYCLE), 
                        DECODE(NVL(B.PARKED_FLAG, 'N'), 'N', BL.BILL_AMOUNT, B.BILL_AMOUNT), 
                        DECODE(NVL(B.PARKED_FLAG, 'N'), 'N', BL.DUE_DATE, B.DUE_DATE), 
                        DECODE(NVL(B.PARKED_FLAG, 'N'), 'N', BL.EXP_DATE, B.EXP_DATE), 
                        DECODE(NVL(B.PARKED_FLAG, 'N'), 'N', BL.BILL_REF_INFO, B.BILL_REF_INFO),
                        DECODE(NVL(B.PARKED_FLAG, 'N'), 'N', BL.BILL_DETAILS, B.BILL_DETAILS),
                        DECODE(NVL(B.PARKED_FLAG, 'N'), 'N', BL.BENEFICIARY_NAME, B.BENEFICIARY_NAME),
                        DECODE(NVL(B.PARKED_FLAG, 'N'), 'N', BL.BENEFICIARY_ID, B.BENEFICIARY_ID),
                        DECODE(NVL(B.PARKED_FLAG, 'N'), 'N', BL.BENEFICIARY_ID_TYPE, B.BENEFICIARY_ID_TYPE),
                        DECODE(NVL(B.PARKED_FLAG, 'N'), 'N', BL.LAST_SMPL_STATUS, DECODE(B.LAST_ACTION, 'U', 'BillUpdated', 'E', 'BillExpired')),
                        DECODE(NVL(B.PARKED_FLAG, 'N'), 'N', BL.SMPL_BILLER_ID, V_BILLER_ID),
                        NULL
                  FROM PSR.BILLS B
                  WHERE B.PARTNER_CODE = P_PARTNER_CODE
                    AND B.BILL_NUMBER = BL.BILL_NUMBER
              )
              
            WHERE BL.PARTNER_CODE = P_PARTNER_CODE
              AND  BL.LAST_UPLOAD_SMPL_RQ = P_SMPL_UPLOAD_REQUEST_ID
              AND  PSR.IS_VALID_ACTION_STATE('BILLS', BL.SMPL_STATE, 'SDDC') = 'Y' ;   
    
    ELSIF P_CONFIRMATION_ERROR_CODE IS NOT NULL OR NVL(P_CONFIRMATION_ERROR_CODE, '0') <> '0' THEN
        
      -- intialize xml
        V_FAILURE_RESULT := '<Bills><SMPLReqID>'
                              ||P_SMPL_UPLOAD_REQUEST_ID
                              ||'</SMPLReqID><SMPLReplyID>'
                              ||  P_SMPL_CONFIRM_REQUEST_ID 
                              || '</SMPLReplyID>';

      -- BULK COLLECT collections 
        SELECT  BILL_NUMBER , ERROR_CODE , ERROR_DESC
          BULK COLLECT INTO 
              l_BILL_NUMBER , l_ERROR_CODE , l_ERROR_DESC
          FROM  PSR.SMPL_BILLS_CONFIRMATION_ERROR
          WHERE PARTNER_CODE = P_PARTNER_CODE 
              AND SMPL_UPLOAD_REQUEST_ID = P_SMPL_UPLOAD_REQUEST_ID  
              AND SMPL_CONFIRM_REQUEST_ID = P_SMPL_CONFIRM_REQUEST_ID ;
        
        SELECT BILL_NUMBER
          BULK COLLECT INTO
                l_SMPL_BILL_NUMBER
            FROM PSR.BILLS_SMPL
            WHERE PARTNER_CODE = P_PARTNER_CODE
              AND SMPL_BILLER_ID = V_BILLER_ID
              AND LAST_UPLOAD_SMPL_RQ = P_SMPL_UPLOAD_REQUEST_ID
              AND PSR.IS_VALID_ACTION_STATE('BILLS',SMPL_STATE,'SDDC') = 'Y';

        SELECT B.PARKED_FLAG , B.BILL_NUMBER
          BULK COLLECT INTO 
                l_PARKED_FLAG , l_PARKED_BILL_NUMBER
          FROM PSR.BILLS B
          WHERE  B.PARTNER_CODE = P_PARTNER_CODE;
      -- Lopp on bills
        FOR index IN 1 .. l_BILL_NUMBER.COUNT
        LOOP
          l_V_VALID(index) := 'Y';
          V_STATUS_CODE := NULL;
          V_STATUS_DESC := NULL;
              
          IF l_ERROR_CODE (index) IS NULL OR LENGTH(TRIM(l_ERROR_CODE(index))) = 0 THEN 
          
            V_STATUS_CODE := V_ERR_CODE_IS_RQUIRED;
            V_STATUS_DESC := 'SMPL Error Code is mandatory';
            l_V_VALID(index) := 'N';
          
          ELSIF l_ERROR_DESC IS NULL OR LENGTH(TRIM(l_ERROR_DESC(index))) = 0 THEN 
          
            V_STATUS_CODE := V_ERR_MSG_IS_RQUIRED;
            V_STATUS_DESC := 'SMPL Error Msg is mandatory';
            l_V_VALID(index) := 'N';

          ELSIF l_BILL_NUMBER IS NULL OR LENGTH(TRIM(l_BILL_NUMBER(index))) = 0 THEN 
              
            V_STATUS_CODE := V_BILL_NUMBER_IS_RQUIRED;
            V_STATUS_DESC := 'Bill Number is mandatory';
            l_V_VALID(index) := 'N';
          
          ELSE 
          
            V_BLR_BILL_CNT := 0;
            -- count specified bill on SMPL bills
              FOR inner_index IN 1 .. l_SMPL_BILL_NUMBER.COUNT
              LOOP
                  IF l_SMPL_BILL_NUMBER(inner_index) = l_BILL_NUMBER(index) THEN
                    V_BLR_BILL_CNT := V_BLR_BILL_CNT + 1;
                  END IF;
              END LOOP;
            
            IF V_BLR_BILL_CNT = 0 THEN 
                V_STATUS_CODE := V_INVALID_BILL_NUMBER;
                V_STATUS_DESC := 'Invalid Bill Number';
                l_V_VALID(index) := 'N';
            END IF;
          
          END IF; 
          
          IF l_V_VALID(index) = 'N' THEN 
              
            P_STATUS_CODE := V_ERROR_EXIST;
            P_STATUS_DESC := 'One or more rejected Record';
            INVALID_CNT := INVALID_CNT + 1;
            
            V_FAILURE_RESULT := V_FAILURE_RESULT 
                                  || '<Bill><StatusCode>' 
                                  || V_STATUS_CODE
                                  || '</StatusCode><StatusDesc>' 
                                  || V_STATUS_DESC 
                                  || '</StatusDesc><BillerID>'  
                                  || '</BillerID><BillNumber>'
                                  || l_BILL_NUMBER(index) 
                                  || '</BillNumber></Bill>';
            
          ELSE
            
            SUCCESS_CNT := SUCCESS_CNT + 1;
            -------------------------- Update Bill Record -------------------------   
            -- fetch parked flag for each bill
              FOR inner_index IN 1 .. l_PARKED_BILL_NUMBER.COUNT
              LOOP
                  IF l_PARKED_BILL_NUMBER(inner_index) = l_BILL_NUMBER(index) THEN
                    l_SUTIBLE_PARKED_FLAG(index) := l_PARKED_FLAG(inner_index);
                  END IF;
              END LOOP;  
            
          END IF;
              
        END LOOP;
      
      -- enhanced for all statements
        FORALL index IN 1 .. l_SMPL_BILL_NUMBER.COUNT
            UPDATE PSR.BILLS_SMPL
                SET SMPL_ERROR_CODE = DECODE(l_ERROR_CODE(index), '20017', '0', '20021', '0', l_ERROR_CODE(index)),
                    SMPL_ERROR_MSG = DECODE(l_ERROR_CODE(index), '20017', 'Success', '20021', 'Success', l_ERROR_DESC(index)),
                    SMPL_STATE = PSR.GET_NEXT_STATE('BILLS',SMPL_STATE,'SDDC',DECODE(l_ERROR_CODE(index), '20017', 'S', '20021', 'S', 'FT')),
                    LAST_ACTION = 'SDDC',
                    LAST_UPDATE_DATE = CURRENT_TIMESTAMP,
                    LAST_SMPL_CONFIRM_ORG_RQ = P_SMPL_UPLOAD_REQUEST_ID,
                    LAST_SMPL_CONFIRM_RQ = P_SMPL_CONFIRM_REQUEST_ID,
                    LAST_SMPL_CONFIRM_TS = CURRENT_TIMESTAMP,
                    MIGRATED_BILL_NUMBER = DECODE(l_ERROR_CODE(index), '20017', NULL, '20021', NULL, MIGRATED_BILL_NUMBER)
                WHERE PARTNER_CODE = P_PARTNER_CODE
                AND BILL_NUMBER = l_BILL_NUMBER(index)
                AND LAST_UPLOAD_SMPL_RQ = P_SMPL_UPLOAD_REQUEST_ID
                AND PSR.IS_VALID_ACTION_STATE('BILLS',SMPL_STATE,'SDDC') = 'Y'
                AND l_V_VALID(index) = 'N' 
                AND NVL(l_PARKED_FLAG(index), 'N') <> 'N'; 
        FORALL index IN 1 .. l_SMPL_BILL_NUMBER.COUNT
          UPDATE PSR.BILLS_SMPL BL
              SET  (
                    BL.SMPL_ERROR_CODE,
                    BL.SMPL_ERROR_MSG,
                    BL.SMPL_STATE,
                    BL.LAST_ACTION,
                    BL.LAST_UPDATE_DATE,
                    BL.LAST_SMPL_CONFIRM_ORG_RQ,
                    BL.LAST_SMPL_CONFIRM_RQ,
                    BL.LAST_SMPL_CONFIRM_TS,
                    BL.BILL_CYCLE, 
                    BL.BILL_AMOUNT, 
                    BL.DUE_DATE, 
                    BL.EXP_DATE, 
                    BL.BILL_REF_INFO,
                    BL.BILL_DETAILS,
                    BL.BENEFICIARY_NAME,
                    BL.BENEFICIARY_ID,
                    BL.BENEFICIARY_ID_TYPE,
                    BL.LAST_SMPL_STATUS,
                    BL.SMPL_BILLER_ID,
                    BL.MIGRATED_BILL_NUMBER
                  )
                =
                  ( 
                    SELECT  DECODE(l_ERROR_CODE(index), '20017', '0', '20021', '0', l_ERROR_CODE(index)),
                    DECODE(l_ERROR_CODE(index), '20017', 'Success', '20021', 'Success', l_ERROR_DESC(index)),
                    PSR.GET_NEXT_STATE('BILLS', PSR.GET_NEXT_STATE('BILLS',BL.SMPL_STATE,'SDDC',DECODE(l_ERROR_CODE(index), '20017', 'S', '20021', 'S', 'FT')), DECODE(B.LAST_ACTION, 'U', 'BLU', 'E', 'BLE'), 'S'),
                    DECODE(B.LAST_ACTION, 'U', 'BLU', 'E', 'BLE'),
                    V_START_TIME,
                    P_SMPL_UPLOAD_REQUEST_ID,
                    P_SMPL_CONFIRM_REQUEST_ID,
                    CURRENT_TIMESTAMP,
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
                  AND LAST_UPLOAD_SMPL_RQ = P_SMPL_UPLOAD_REQUEST_ID
                  AND PSR.IS_VALID_ACTION_STATE('BILLS',SMPL_STATE,'SDDC') = 'Y'
                  AND l_V_VALID(index) <> 'N' 
                  AND NVL(l_PARKED_FLAG(index), 'N') <> 'N';


      -- finilize xml
        V_FAILURE_RESULT := V_FAILURE_RESULT || '</Bills>';
      
      -- Update Bill Record -----------
        UPDATE PSR.BILLS_SMPL BL
          SET (
                BL.SMPL_ERROR_CODE,
                BL.SMPL_ERROR_MSG,
                BL.SMPL_STATE,
                BL.LAST_ACTION,
                BL.LAST_UPDATE_DATE,
                BL.LAST_SMPL_CONFIRM_ORG_RQ,
                BL.LAST_SMPL_CONFIRM_RQ,
                BL.LAST_SMPL_CONFIRM_TS,
                BL.BILL_CYCLE, 
                BL.BILL_AMOUNT, 
                BL.DUE_DATE, 
                BL.EXP_DATE, 
                BL.BILL_REF_INFO,
                BL.BILL_DETAILS,
                BL.BENEFICIARY_NAME,
                BL.BENEFICIARY_ID,
                BL.BENEFICIARY_ID_TYPE,
                BL.LAST_SMPL_STATUS,
                BL.SMPL_BILLER_ID,
                BL.MIGRATED_BILL_NUMBER
              )
              =
              (
                SELECT  0,
                        'Success',
                        DECODE  (
                                  NVL(B.PARKED_FLAG, 'N'), 
                                  'N', 
                                  PSR.GET_NEXT_STATE('BILLS', BL.SMPL_STATE, 'SDDC', 'S'),
                                  PSR.GET_NEXT_STATE( 'BILLS', 
                                                      PSR.GET_NEXT_STATE('BILLS', BL.SMPL_STATE, 'SDDC', 'S'), 
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
                        P_SMPL_UPLOAD_REQUEST_ID,
                        P_SMPL_CONFIRM_REQUEST_ID,
                        CURRENT_TIMESTAMP,
                        DECODE(NVL(B.PARKED_FLAG, 'N'), 'N', BL.BILL_CYCLE, B.BILL_CYCLE), 
                        DECODE(NVL(B.PARKED_FLAG, 'N'), 'N', BL.BILL_AMOUNT, B.BILL_AMOUNT), 
                        DECODE(NVL(B.PARKED_FLAG, 'N'), 'N', BL.DUE_DATE, B.DUE_DATE), 
                        DECODE(NVL(B.PARKED_FLAG, 'N'), 'N', BL.EXP_DATE, B.EXP_DATE), 
                        DECODE(NVL(B.PARKED_FLAG, 'N'), 'N', BL.BILL_REF_INFO, B.BILL_REF_INFO),
                        DECODE(NVL(B.PARKED_FLAG, 'N'), 'N', BL.BILL_DETAILS, B.BILL_DETAILS),
                        DECODE(NVL(B.PARKED_FLAG, 'N'), 'N', BL.BENEFICIARY_NAME, B.BENEFICIARY_NAME),
                        DECODE(NVL(B.PARKED_FLAG, 'N'), 'N', BL.BENEFICIARY_ID, B.BENEFICIARY_ID),
                        DECODE(NVL(B.PARKED_FLAG, 'N'), 'N', BL.BENEFICIARY_ID_TYPE, B.BENEFICIARY_ID_TYPE),
                        DECODE(NVL(B.PARKED_FLAG, 'N'), 'N', BL.LAST_SMPL_STATUS, DECODE(B.LAST_ACTION, 'U', 'BillUpdated', 'E', 'BillExpired')),
                        DECODE(NVL(B.PARKED_FLAG, 'N'), 'N', BL.SMPL_BILLER_ID, V_BILLER_ID),
                        NULL
                  FROM PSR.BILLS B
                  WHERE B.PARTNER_CODE = P_PARTNER_CODE
                    AND B.BILL_NUMBER = BL.BILL_NUMBER
              )
              WHERE  BL.PARTNER_CODE = P_PARTNER_CODE
                AND  BL.LAST_UPLOAD_SMPL_RQ = P_SMPL_UPLOAD_REQUEST_ID
                AND  PSR.IS_VALID_ACTION_STATE('BILLS', BL.SMPL_STATE, 'SDDC') = 'Y'
                AND  BL.BILL_NUMBER NOT IN (
                                            SELECT BILL_NUMBER 
                                                FROM  PSR.SMPL_BILLS_CONFIRMATION_ERROR
                                                WHERE PARTNER_CODE = P_PARTNER_CODE 
                                                  AND SMPL_UPLOAD_REQUEST_ID = P_SMPL_UPLOAD_REQUEST_ID  
                                                  AND SMPL_CONFIRM_REQUEST_ID = P_SMPL_CONFIRM_REQUEST_ID 
                                            )
              ;

      V_JOB_ID := P_SMPL_UPLOAD_REQUEST_ID || '_' || 
                            P_SMPL_CONFIRM_REQUEST_ID || '_' || 
                            PSR.RQ_ID_SEQ.NEXTVAL;
              
      PSR.MANAGE_JOB_LOG (
                          P_MSG_ID              => 'UPDATE_SMPL_BILLS_CONFIRM'
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
                          P_JOB_DESC            => 'UPDATE_SMPL_BILLS_CONFIRM',
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
          AND PSR.IS_SMPL_IMAGE  (
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
                                MSG_ID           => 'UPDATE_SMPL_BILLS_CONFIRM'||REPLACE(TO_CHAR(V_START_TIME, 'YYYY-MM-DD HH24:MI:SS'), ' ', 'T'),
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
                                P_NAME           => 'UPDATE_SMPL_BILLS_CONFIRM',
                                PARAM1_NAME      => 'P_STATUS_DESC',
                                PARAM1_VALUE     => P_STATUS_DESC
                              );

END PSR.UPDATE_SMPL_BILLS_CONFIRM; 