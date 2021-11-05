CREATE OR REPLACE PROCEDURE "MANAGE_MERCHANT_TERMINAL" (
                                                          P_MSG_ID                   IN        VARCHAR2,
                                                          P_SC_ID                    IN        VARCHAR2,
                                                          P_FUN_ID                   IN        VARCHAR2,
                                                          P_USER_ID                  IN        VARCHAR2,
                                                          P_PREF_LANG                IN        VARCHAR2 DEFAULT 'EN',
                                                          P_RQ_MODE                  IN        VARCHAR2,
                                                          P_CLIENT_DATE              IN        VARCHAR2,
                                                          P_VERSION                  IN        VARCHAR2,
                                                          P_STATUS_CODE              OUT       VARCHAR2,
                                                          P_STATUS_DESC              OUT       VARCHAR2,
                                                         -------------------------------------------------- 
                                                          P_WALLET_NUMBER            IN        VARCAHR2,
                                                          P_ALINMA_ID                IN        VARCAHR2,
                                                          P_MERCHANT_ID              IN OUT    VARCAHR2,
                                                          P_TERMINAL_ID              IN OUT    VARCAHR2, --[RETURNED ON CREATE] 
                                                          P_TERMINAL_AR_DESC         IN        VARCAHR2, 
                                                          P_TERMINAL_EN_DESC         IN        VARCAHR2, 
                                                          P_TERMINAL_STATUS          IN OUT    VARCAHR2, --[Active / Suspended/ Deleted] --[SUSPEND / UNSUSPEND]
                                                          P_TERMINAL_ADDRESS         IN        VARCAHR2,
                                                          P_TERMINAL_TRX_LIMIT       IN        VARCAHR2,
                                                          P_TERMINAL_DAILY_LIMIT     IN        VARCAHR2,
                                                          P_TERMINAL_CONTACT         IN        VARCAHR2,
                                                          P_TERMINAL_CREATION_DATE   IN        VARCHAR2
                                             ) AS 
EXIT_STORED_PROCEDURE EXCEPTION;
V_START_TIME TIMESTAMP := CURRENT_TIMESTAMP;
V_COUNT INTEGER;
C_INSERT VARCAHR2 := '0001'; --> INSERT
C_UPDATE VARCAHR2 := '0002'; --> UPDATE
C_DELETE VARCAHR2 := '0003'; --> DELETE

BEGIN
  BEGIN
     P_STATUS_CODE := ERROR_CODES.SUCCESSFUL_OPERATION;
     -- Check function id validity
     IF P_FUN_ID IS NULL THEN
          P_STATUS_CODE := ERROR_CODES.FUNCTION_ID_IS_REQUIRED;
          RAISE EXIT_STORED_PROCEDURE;
     ELSE
          IF P_FUN_ID NOT IN ( C_INSERT , C_UPDATE , C_DELETE ) THEN
               P_STATUS_CODE := ERROR_CODES.INVALID_FUNCTION_ID;
               RAISE EXIT_STORED_PROCEDURE;
          END IF;
     END IF;

    -- Check merchant id validity
    IF P_MERCHANT_ID IS NULL THEN
            P_STATUS_CODE := ERROR_CODES.MERCHANT_ID_IS_REQUIRED;
            RAISE EXIT_STORED_PROCEDURE;
    ELSE
            SELECT COUNT(*)
            INTO  V_COUNT
            FROM  MERCHANT
            WHERE M_MERCHANT_ID = P_MERCHANT_ID;

            IF V_COUNT = 0  THEN
                    P_STATUS_CODE := ERROR_CODES.MERCHANT_ID_IS_NOT_VALID;
                    RAISE EXIT_STORED_PROCEDURE;
            END IF;

    END IF;


    IF P_FUN_ID = C_INSERT THEN

          INSERT INTO MERCHANT_TERMINAL
          ( 
            MT_TERMINAL_ID ,
            MT_MERCHANT_ID ,
            MT_AR_DESCRIPTION ,
            MT_EN_DESCRIPTION ,
            MT_STATUS ,
            MT_ADDRESS ,
            MT_TRANSACTION_LIMIT ,
            MT_DAILY_LIMIT ,
            MT_CONTACT ,
            MT_IWALLET_NUMBER,
            MT_CREATION_DATE
          )

          VALUES
          (
           MERCHANT_TERMINAL_SEQ.NEXT,
           P_MERCHANT_ID,
           P_TERMINAL_AR_DESC,
           P_TERMINAL_EN_DESC,
           P_TERMINAL_STATUS,
           P_TERMINAL_ADDRESS,
           P_TERMINAL_TRX_LIMIT,
           P_TERMINAL_DAILY_LIMIT,
           P_TERMINAL_CONTACT,
           P_WALLET_NUMBER,
           P_TERMINAL_CREATION_DATE
          );

    ELSE IF P_FUN_ID = C_UPDATE THEN

          SELECT COUNT(*)
            INTO  V_COUNT
            FROM  MERCHANT_TERMINAL
            WHERE MT_TERMINAL_ID = P_TERMINAL_ID;

            IF V_COUNT = 0  THEN
                    P_STATUS_CODE := ERROR_CODES.TERMINAL_ID_IS_NOT_VALID;
                    RAISE EXIT_STORED_PROCEDURE;
            END IF;

             UPDATE MERCHANT_TERMINAL 
                SET 
                  MT_MERCHANT_ID        = P_MERCHANT_ID ,
                  MT_AR_DESCRIPTION     = P_TERMINAL_AR_DESC  ,
                  MT_EN_DESCRIPTION     = P_TERMINAL_EN_DESC  ,
                  MT_STATUS             = P_TERMINAL_STATUS ,
                  MT_ADDRESS            = P_TERMINAL_ADDRESS  ,
                  MT_TRANSACTION_LIMIT  = P_TERMINAL_TRX_LIMIT  ,
                  MT_DAILY_LIMIT        = P_TERMINAL_DAILY_LIMIT  ,
                  MT_CONTACT            = P_TERMINAL_CONTACT  ,
                  MT_IWALLET_NUMBER     = P_WALLET_NUMBER ,
                  MT_CREATION_DATE      = P_TERMINAL_CREATION_DATE

                WHERE MT_TERMINAL_ID  = P_TERMINAL_ID;
                      

    ELSE
                  DELETE FROM  MERCHANT_TERMINAL
                  WHERE MT_TERMINAL_ID  = P_TERMINAL_ID;

    END IF;
    
  EXCEPTION
    WHEN EXIT_STORED_PROCEDURE THEN
      NULL;
    WHEN OTHERS THEN
      P_STATUS_CODE    := ERROR_CODES.UNRECOVERABLE_DB_ERROR;
      P_STATUS_DESC    := SQLERRM || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE;
     NULL;
END;
  IF P_STATUS_CODE <> ERROR_CODES.UNRECOVERABLE_DB_ERROR THEN
     P_STATUS_DESC := GET_ERROR_DESCRIPTION(P_STATUS_CODE);
 END IF;

 DEBUG_STORED_PROCEDURES(MSG_ID          => P_MSG_ID,
                         PROCEDURE_NAME  => 'MANAGE_MERCHANT_TERMINAL',
                         START_TIME      => V_START_TIME,
                         STATUS_CODE     => P_STATUS_CODE,
                         STATUS_DESC     => P_STATUS_DESC,
                         RQ_MODE         => P_RQ_MODE,
                         SC_ID           => P_SC_ID,
                         FUNCTION_ID     => P_FUN_ID,
                         USER_ID         => P_USER_ID,
                         PREF_LANG       => P_PREF_LANG,
                         VERSION         => P_VERSION,          
                         PARAM1_NAME     => 'P_WALLET_NUMBER',
                         PARAM1_VALUE    => P_WALLET_NUMBER, 
                         PARAM2_NAME     => 'P_ALINMA_ID',
                         PARAM2_VALUE    => P_ALINMA_ID, 
                         PARAM3_NAME     => 'P_MERCHANT_ID',
                         PARAM3_VALUE    => P_MERCHANT_ID, 
                         PARAM4_NAME     => 'P_TERMINAL_ID',
                         PARAM4_VALUE    => P_TERMINAL_ID, 
                         PARAM5_NAME     => 'P_TERMINAL_DESC',
                         PARAM5_VALUE    => P_TERMINAL_DESC, 
                         PARAM6_NAME     => 'P_TERMINAL_DESC',
                         PARAM6_VALUE    => P_TERMINAL_DESC, 
                         PARAM7_NAME     => 'P_TERMINAL_STATUS',
                         PARAM7_VALUE    => P_TERMINAL_STATUS, 
                         PARAM8_NAME     => 'P_TERMINAL_ADDRESS',
                         PARAM8_VALUE    => P_TERMINAL_ADDRESS, 
                         PARAM9_NAME     => 'P_TERMINAL_TRX_LIMIT',
                         PARAM9_VALUE    => P_TERMINAL_TRX_LIMIT, 
                         PARAM10_NAME     => 'P_TERMINAL_DAILY_LIMIT',
                         PARAM10_VALUE    => P_TERMINAL_DAILY_LIMIT, 
                         PARAM11_NAME    => 'P_TERMINAL_CONTACT',
                         PARAM11_VALUE   => P_TERMINAL_CONTACT, 
                         PARAM12_NAME    =>'END'
                         );
  
END MANAGE_MERCHANT_TERMINAL;