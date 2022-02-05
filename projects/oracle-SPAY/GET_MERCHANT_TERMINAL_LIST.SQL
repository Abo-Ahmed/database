create or replace PROCEDURE "GET_MERCHANT_TERMINAL_LIST" (
                                                          P_MSG_ID                   IN        VARCHAR2,
                                                          P_SC_ID                    IN        VARCHAR2,
                                                          P_FUN_ID                   IN        VARCHAR2,
                                                          P_USER_ID                  IN        VARCHAR2,
                                                          P_PREF_LANG                IN        VARCHAR2 DEFAULT 'EN',
                                                          P_RQ_MODE                  IN        VARCHAR2,
                                                          P_CLIENT_DATE              IN        DATE,  
                                                          P_CUST_ID                  IN        VARCHAR2, --POI for Consumer OR ALSMPLId for Merchant
                                                          P_CUST_ID_TYPE             IN        VARCHAR2,
                                                          P_SEC_INFO                 IN        VARCHAR2,
                                                          P_SEC_INFO_TYPE            IN        VARCHAR2,    
                                                          P_STATUS_CODE              OUT       VARCHAR2,
                                                          P_STATUS_DESC              OUT       VARCHAR2, 
                                                          ----------------------------------------------
                                                          P_SWALLET_NUMBER           IN        VARCHAR2,
                                                          P_MERCHANT_ID              IN        VARCHAR2,
                                                          P_OFFSET                   IN        VARCHAR2,
                                                          P_SIZE                     IN        VARCHAR2,
                                                          P_SENT_RECORDS             OUT       VARCHAR2,
                                                          P_MATCHED_RECORDS          OUT       VARCHAR2,
                                                          P_MERCHANT_TERMINAL_LIST   OUT       CLOB 
                                                      ) AS
  EXIT_STORED_PROCEDURE EXCEPTION;
  V_VERSION             NUMBER          := 1.0;
  V_START_TIME          TIMESTAMP := CURRENT_TIMESTAMP;
  V_COUNT               INTEGER;
BEGIN
  BEGIN
    P_STATUS_CODE := ERROR_CODES.SUCCESSFUL_OPERATION;
    
 /*   -- Check merchant id validity
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

    END IF;*/
  
    SELECT XMLELEMENT("MerchantTerminalList", --
           XMLAGG( -- 
           XMLELEMENT("MerchantTerminal", --
           XMLELEMENT("TerminalId", RF.MT_TERMINAL_ID), --
           XMLELEMENT("TerminalArDesc", RF.MT_AR_DESCRIPTION), --
           XMLELEMENT("TerminalEnDesc", RF.MT_EN_DESCRIPTION), --
           XMLELEMENT("TerminalStatus", RF.MT_STATUS), --
           XMLELEMENT("TerminalAddress", RF.MT_ADDRESS), --
           XMLELEMENT("TerminalTrxLimit", RF.MT_TRANSACTION_LIMIT), --
           XMLELEMENT("TerminalDailyLimit", RF.MT_DAILY_LIMIT), --
           XMLELEMENT("TerminalContact", RF.MT_CONTACT),
           XMLELEMENT("CreationDate", RF.MT_CREATION_DATE)--TO_CHAR
           ))).GETCLOBVAL()
      INTO P_MERCHANT_TERMINAL_LIST
      FROM (SELECT ROW_NUMBER() OVER(ORDER BY MT.MT_TERMINAL_ID) R,
                    MT.MT_TERMINAL_ID,
                    MT.MT_AR_DESCRIPTION,
                    MT.MT_EN_DESCRIPTION,
                    MT.MT_STATUS,
                    MT.MT_ADDRESS,
                    MT.MT_TRANSACTION_LIMIT,
                    MT.MT_DAILY_LIMIT,
                    MT.MT_CONTACT,
                    MT.MT_CREATION_DATE
              FROM MERCHANT_TERMINAL MT , MERCHANT M
              WHERE ( P_MERCHANT_ID IS NULL OR MT.MT_MERCHANT_ID = P_MERCHANT_ID) 
                AND ( P_SWALLET_NUMBER IS NULL OR MT.MT_SWALLET_NUMBER = P_SWALLET_NUMBER )
                AND ( P_CUST_ID IS NULL OR M.M_ALSMPL_ID = P_CUST_ID) 
                AND ( MT.MT_MERCHANT_ID = M.M_MERCHANT_ID)
                ) RF
                
     WHERE (P_OFFSET IS NULL)
        OR (P_SIZE IS NULL)
        OR (R BETWEEN P_OFFSET AND (P_OFFSET + P_SIZE - 1));
  
    SELECT COUNT(1)
      INTO P_MATCHED_RECORDS
      FROM MERCHANT_TERMINAL 
     WHERE  (P_MERCHANT_ID IS NULL OR MT_MERCHANT_ID = P_MERCHANT_ID)
        AND (P_SWALLET_NUMBER IS NULL OR P_SWALLET_NUMBER = MT_SWALLET_NUMBER);
  
    --get number of sent records 
    IF P_OFFSET IS NOT NULL THEN
      IF P_MATCHED_RECORDS + 0 < P_SIZE + 0 THEN
        P_SENT_RECORDS := P_MATCHED_RECORDS;
      ELSE
        P_SENT_RECORDS := P_SIZE;
      END IF;
    ELSE
      P_SENT_RECORDS := P_MATCHED_RECORDS;
    END IF;
  EXCEPTION
    WHEN EXIT_STORED_PROCEDURE THEN
    
      NULL;
    WHEN OTHERS THEN
      P_STATUS_CODE := ERROR_CODES.UNRECOVERABLE_DB_ERROR;
      P_STATUS_DESC := SQLERRM;
  END;
  IF P_STATUS_CODE <> ERROR_CODES.UNRECOVERABLE_DB_ERROR THEN
    P_STATUS_DESC := GET_ERROR_DESCRIPTION(P_STATUS_CODE);
  END IF;
  DEBUG_STORED_PROCEDURES(MSG_ID         => P_MSG_ID,
                          PROCEDURE_NAME => 'GET_MERCHANT_TERMINAL_LIST',
                          START_TIME     => V_START_TIME,
                          STATUS_CODE    => P_STATUS_CODE,
                          STATUS_DESC    => P_STATUS_DESC,
                          RQ_MODE        => P_RQ_MODE,
                          SC_ID          => P_SC_ID,
                          FUNCTION_ID    => P_FUN_ID,
                          USER_ID        => P_USER_ID,
                          PREF_LANG      => P_PREF_LANG,
                          VERSION        => V_VERSION,
                          CLIENT_DATE    => P_CLIENT_DATE,
                          CUST_ID        => P_CUST_ID,
                          CUST_ID_TYPE   => P_CUST_ID_TYPE,
                          SEC_INFO       => P_SEC_INFO,
                          SEC_INFO_TYPE  => P_SEC_INFO_TYPE,
                          
                          PARAM1_NAME    => 'P_SWALLET_NUMBER',
                          PARAM1_VALUE   => P_SWALLET_NUMBER,
                          --PARAM2_NAME    => 'P_ALSMPL_ID',
                          --PARAM2_VALUE   => P_ALSMPL_ID,
                          PARAM3_NAME    => 'P_MERCHANT_ID',
                          PARAM3_VALUE   => P_MERCHANT_ID,
                          PARAM4_NAME    => 'P_OFFSET',
                          PARAM4_VALUE   => P_OFFSET,
                          PARAM5_NAME    => 'P_SIZE',
                          PARAM5_VALUE   => P_SIZE,
                          PARAM6_NAME    => 'P_SENT_RECORDS',
                          PARAM6_VALUE   => P_SENT_RECORDS,
                          PARAM7_NAME    => 'P_MATCHED_RECORDS',
                          PARAM7_VALUE   => P_MATCHED_RECORDS,
                          PARAM8_NAME    => 'P_MERCHANT_TERMINAL_LIST',
                          PARAM8_VALUE   => P_MERCHANT_TERMINAL_LIST,
                          PARAM9_NAME    => 'END');
END GET_MERCHANT_TERMINAL_LIST;