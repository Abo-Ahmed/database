create or replace PROCEDURE GET_STATUS_LIST (             
                                                        P_MSG_ID               IN  VARCHAR2,
                                                        P_SC_ID                IN  VARCHAR2, 
                                                        P_FUN_ID               IN  VARCHAR2, 
                                                        P_REQ_MODE             IN  VARCHAR2,
                                                        P_CUST_LANG_PREF       IN  VARCHAR2,
                                                        P_USER_ID              IN  VARCHAR2,
                                                        P_CLIENT_DATE          IN  VARCHAR2,
                                                        P_VERSION              IN  VARCHAR2,
                                                        P_STATUS_CODE          OUT VARCHAR2,
                                                        P_STATUS_DESC          OUT VARCHAR2,
                                          --------------------------------------------------------  
                                                        P_USER_ROLE            IN  VARCHAR2,
                                                        P_ORDER_BY             IN  VARCHAR2,
                                                        P_ORDER_DIRECTION      IN  VARCHAR2,
                                                        P_MAX_RECORDS          IN  VARCHAR2,
                                                        P_OFFSET               IN  VARCHAR2,
                                                        P_MATCHED_RECORDS      OUT VARCHAR2,
                                                        P_SENT_RECORDS         OUT VARCHAR2,
                                                        P_STATUS_LIST          OUT CLOB
                                          )IS 
                                                           
  /*-------------------------------------------
  This procedure: Assigns users to list of requests
  -------------------------------------------*/ 
  V_START_TIME   TIMESTAMP := CURRENT_TIMESTAMP;
  V_COUNT_USER   INTEGER; 
  V_VERSION      NUMBER                                  := 1.0;
  V_ORA_CODE     STORED_PROCEDURE_DEBUGGING.SPD_ORA%TYPE := SQLERRM;
  V_REF_CUR      SYS_REFCURSOR;
  EXIT_PROCEDURE EXCEPTION;
 
BEGIN
  BEGIN
    
    P_STATUS_CODE := ERROR_CODES.SUCCESSFUL_OPERATION;
    P_STATUS_DESC := 'Successful Operation';
    
    IF P_USER_ROLE IS NULL THEN
          P_STATUS_CODE := ERROR_CODES.USER_GROUP_ROLE_CODE_REQUIRED;
          P_STATUS_DESC := 'User Group Role Is Required';
          RAISE EXIT_PROCEDURE;
    ELSE
          SELECT COUNT(1)
          INTO V_COUNT_USER
          FROM BKF_USER_GROUP_ROLES
          WHERE BUGR_ROLE_GROUP_CODE = P_USER_ROLE ;

          IF V_COUNT_USER = 0 THEN
              P_STATUS_CODE := ERROR_CODES.INVALID_USER_GROUP_ROLE;
              P_STATUS_DESC := 'Invalid User Group Role';
              RAISE EXIT_PROCEDURE;
          END IF;
    END IF;

   SELECT XMLELEMENT("States",
                                 ( XMLAGG(XMLELEMENT ("State",
                                          XMLELEMENT   ("ProcessCode" , PROCESS_CODE), 
                                          XMLELEMENT   ("SourceState" , SOURCE_STATE), 
                                          XMLELEMENT   ("Action" , ACTION), 
                                          XMLELEMENT   ("ActionStatus" , ACTION_STATUS), 
                                          XMLELEMENT   ("TargetState" , TARGET_STATE), 
                                          XMLELEMENT   ("ManualActionFlag" , MANUAL_ACTION_FLAG), 
                                          XMLELEMENT   ("AutoRetryFlag" , AUTO_RETRY_FLAG), 
                                          XMLELEMENT   ("ManualAction" , MANUAL_ACTION), 
                                          XMLELEMENT   ("Description" , DESCRIPTION), 
                                          XMLELEMENT   ("UserRole" , BKF_USER_ROLE), 
                                          XMLELEMENT   ("ContactConfig" , NE_CONTACT_CONFIG), 
                                          XMLELEMENT   ("Channel" , NE_CHANNEL), 
                                          XMLELEMENT   ("EventCode" , NE_EVENT_CODE), 
                                          XMLELEMENT   ("TemplateEnglish" , NE_TEMPLATE_EN), 
                                          XMLELEMENT   ("TemplateArabic" , NE_TEMPLATE_AR)          
                         )))).GETCLOBVAL() 
        INTO P_STATUS_LIST
        FROM (                SELECT  ROW_NUMBER() OVER( ORDER BY PROCESS_CODE ASC) PROCESS_CODE_ASC , 
                                      ROW_NUMBER() OVER( ORDER BY SOURCE_STATE ASC) SOURCE_STATE_ASC , 
                                      ROW_NUMBER() OVER( ORDER BY ACTION ASC) ACTION_ASC , 
                                      ROW_NUMBER() OVER( ORDER BY ACTION_STATUS ASC) ACTION_STATUS_ASC , 
                                      ROW_NUMBER() OVER( ORDER BY TARGET_STATE ASC) TARGET_STATE_ASC , 
                                      ROW_NUMBER() OVER( ORDER BY MANUAL_ACTION_FLAG ASC) MANUAL_ACTION_FLAG_ASC , 
                                      ROW_NUMBER() OVER( ORDER BY AUTO_RETRY_FLAG ASC) AUTO_RETRY_FLAG_ASC , 
                                      ROW_NUMBER() OVER( ORDER BY MANUAL_ACTION ASC) MANUAL_ACTION_ASC , 
                                      ROW_NUMBER() OVER( ORDER BY DESCRIPTION ASC) DESCRIPTION_ASC , 
                                      ROW_NUMBER() OVER( ORDER BY BKF_USER_ROLE ASC) BKF_USER_ROLE_ASC , 
                                      ROW_NUMBER() OVER( ORDER BY NE_CONTACT_CONFIG ASC) NE_CONTACT_CONFIG_ASC , 
                                      ROW_NUMBER() OVER( ORDER BY NE_CHANNEL ASC) NE_CHANNEL_ASC , 
                                      ROW_NUMBER() OVER( ORDER BY NE_EVENT_CODE ASC) NE_EVENT_CODE_ASC ,  

                                      ROW_NUMBER() OVER( ORDER BY PROCESS_CODE DESC) PROCESS_CODE_DESC ,
                                      ROW_NUMBER() OVER( ORDER BY SOURCE_STATE DESC) SOURCE_STATE_DESC ,
                                      ROW_NUMBER() OVER( ORDER BY ACTION DESC) ACTION_DESC ,
                                      ROW_NUMBER() OVER( ORDER BY ACTION_STATUS DESC) ACTION_STATUS_DESC ,
                                      ROW_NUMBER() OVER( ORDER BY TARGET_STATE DESC) TARGET_STATE_DESC ,
                                      ROW_NUMBER() OVER( ORDER BY MANUAL_ACTION_FLAG DESC) MANUAL_ACTION_FLAG_DESC ,
                                      ROW_NUMBER() OVER( ORDER BY AUTO_RETRY_FLAG DESC) AUTO_RETRY_FLAG_DESC ,
                                      ROW_NUMBER() OVER( ORDER BY MANUAL_ACTION DESC) MANUAL_ACTION_DESC ,
                                      ROW_NUMBER() OVER( ORDER BY DESCRIPTION DESC) DESCRIPTION_DESC ,
                                      ROW_NUMBER() OVER( ORDER BY BKF_USER_ROLE DESC) BKF_USER_ROLE_DESC ,
                                      ROW_NUMBER() OVER( ORDER BY NE_CONTACT_CONFIG DESC) NE_CONTACT_CONFIG_DESC ,
                                      ROW_NUMBER() OVER( ORDER BY NE_CHANNEL DESC) NE_CHANNEL_DESC ,
                                      ROW_NUMBER() OVER( ORDER BY NE_EVENT_CODE DESC) NE_EVENT_CODE_DESC ,

                                      PROCESS_CODE ,
                                      SOURCE_STATE ,
                                      ACTION ,
                                      ACTION_STATUS ,
                                      TARGET_STATE ,
                                      MANUAL_ACTION_FLAG ,
                                      AUTO_RETRY_FLAG ,
                                      MANUAL_ACTION ,
                                      DESCRIPTION ,
                                      BKF_USER_ROLE ,
                                      NE_CONTACT_CONFIG ,
                                      NE_CHANNEL ,
                                      NE_EVENT_CODE ,
                                      NE_TEMPLATE_EN ,
                                      NE_TEMPLATE_AR 

                                   FROM  LKP_STATE_TRANSITIONS ST
                                   WHERE ST.BKF_USER_ROLE = P_USER_ROLE  
                                   ORDER BY( CASE   WHEN (P_ORDER_BY = 'PROCESS_CODE' AND P_ORDER_DIRECTION ='ASC') THEN PROCESS_CODE_ASC 
                                                    WHEN (P_ORDER_BY = 'SOURCE_STATE' AND P_ORDER_DIRECTION ='ASC') THEN SOURCE_STATE_ASC 
                                                    WHEN (P_ORDER_BY = 'ACTION' AND P_ORDER_DIRECTION ='ASC') THEN ACTION_ASC 
                                                    WHEN (P_ORDER_BY = 'ACTION_STATUS' AND P_ORDER_DIRECTION ='ASC') THEN ACTION_STATUS_ASC 
                                                    WHEN (P_ORDER_BY = 'TARGET_STATE' AND P_ORDER_DIRECTION ='ASC') THEN TARGET_STATE_ASC 
                                                    WHEN (P_ORDER_BY = 'MANUAL_ACTION_FLAG' AND P_ORDER_DIRECTION ='ASC') THEN MANUAL_ACTION_FLAG_ASC 
                                                    WHEN (P_ORDER_BY = 'AUTO_RETRY_FLAG' AND P_ORDER_DIRECTION ='ASC') THEN AUTO_RETRY_FLAG_ASC 
                                                    WHEN (P_ORDER_BY = 'MANUAL_ACTION' AND P_ORDER_DIRECTION ='ASC') THEN MANUAL_ACTION_ASC 
                                                    WHEN (P_ORDER_BY = 'DESCRIPTION' AND P_ORDER_DIRECTION ='ASC') THEN DESCRIPTION_ASC 
                                                    WHEN (P_ORDER_BY = 'BKF_USER_ROLE' AND P_ORDER_DIRECTION ='ASC') THEN BKF_USER_ROLE_ASC 
                                                    WHEN (P_ORDER_BY = 'NE_CONTACT_CONFIG' AND P_ORDER_DIRECTION ='ASC') THEN NE_CONTACT_CONFIG_ASC 
                                                    WHEN (P_ORDER_BY = 'NE_CHANNEL' AND P_ORDER_DIRECTION ='ASC') THEN NE_CHANNEL_ASC 
                                                    WHEN (P_ORDER_BY = 'NE_EVENT_CODE' AND P_ORDER_DIRECTION ='ASC') THEN NE_EVENT_CODE_ASC 
                                                
                                                    WHEN (P_ORDER_BY = 'PROCESS_CODE' AND P_ORDER_DIRECTION ='DESC') THEN PROCESS_CODE_DESC 
                                                    WHEN (P_ORDER_BY = 'SOURCE_STATE' AND P_ORDER_DIRECTION ='DESC') THEN SOURCE_STATE_DESC 
                                                    WHEN (P_ORDER_BY = 'ACTION' AND P_ORDER_DIRECTION ='DESC') THEN ACTION_DESC 
                                                    WHEN (P_ORDER_BY = 'ACTION_STATUS' AND P_ORDER_DIRECTION ='DESC') THEN ACTION_STATUS_DESC 
                                                    WHEN (P_ORDER_BY = 'TARGET_STATE' AND P_ORDER_DIRECTION ='DESC') THEN TARGET_STATE_DESC 
                                                    WHEN (P_ORDER_BY = 'MANUAL_ACTION_FLAG' AND P_ORDER_DIRECTION ='DESC') THEN MANUAL_ACTION_FLAG_DESC 
                                                    WHEN (P_ORDER_BY = 'AUTO_RETRY_FLAG' AND P_ORDER_DIRECTION ='DESC') THEN AUTO_RETRY_FLAG_DESC 
                                                    WHEN (P_ORDER_BY = 'MANUAL_ACTION' AND P_ORDER_DIRECTION ='DESC') THEN MANUAL_ACTION_DESC 
                                                    WHEN (P_ORDER_BY = 'DESCRIPTION' AND P_ORDER_DIRECTION ='DESC') THEN DESCRIPTION_DESC 
                                                    WHEN (P_ORDER_BY = 'BKF_USER_ROLE' AND P_ORDER_DIRECTION ='DESC') THEN BKF_USER_ROLE_DESC 
                                                    WHEN (P_ORDER_BY = 'NE_CONTACT_CONFIG' AND P_ORDER_DIRECTION ='DESC') THEN NE_CONTACT_CONFIG_DESC 
                                                    WHEN (P_ORDER_BY = 'NE_CHANNEL' AND P_ORDER_DIRECTION ='DESC') THEN NE_CHANNEL_DESC 
                                                    WHEN (P_ORDER_BY = 'NE_EVENT_CODE' AND P_ORDER_DIRECTION ='DESC') THEN NE_EVENT_CODE_DESC 
                                                    ELSE PROCESS_CODE_ASC
                                                    END 
                                          )
                                     )
        WHERE P_OFFSET IS NULL 
           OR ( CASE  WHEN (P_ORDER_BY = 'PROCESS_CODE' AND P_ORDER_DIRECTION ='ASC') THEN PROCESS_CODE_ASC 
                      WHEN (P_ORDER_BY = 'SOURCE_STATE' AND P_ORDER_DIRECTION ='ASC') THEN SOURCE_STATE_ASC 
                      WHEN (P_ORDER_BY = 'ACTION' AND P_ORDER_DIRECTION ='ASC') THEN ACTION_ASC 
                      WHEN (P_ORDER_BY = 'ACTION_STATUS' AND P_ORDER_DIRECTION ='ASC') THEN ACTION_STATUS_ASC 
                      WHEN (P_ORDER_BY = 'TARGET_STATE' AND P_ORDER_DIRECTION ='ASC') THEN TARGET_STATE_ASC 
                      WHEN (P_ORDER_BY = 'MANUAL_ACTION_FLAG' AND P_ORDER_DIRECTION ='ASC') THEN MANUAL_ACTION_FLAG_ASC 
                      WHEN (P_ORDER_BY = 'AUTO_RETRY_FLAG' AND P_ORDER_DIRECTION ='ASC') THEN AUTO_RETRY_FLAG_ASC 
                      WHEN (P_ORDER_BY = 'MANUAL_ACTION' AND P_ORDER_DIRECTION ='ASC') THEN MANUAL_ACTION_ASC 
                      WHEN (P_ORDER_BY = 'DESCRIPTION' AND P_ORDER_DIRECTION ='ASC') THEN DESCRIPTION_ASC 
                      WHEN (P_ORDER_BY = 'BKF_USER_ROLE' AND P_ORDER_DIRECTION ='ASC') THEN BKF_USER_ROLE_ASC 
                      WHEN (P_ORDER_BY = 'NE_CONTACT_CONFIG' AND P_ORDER_DIRECTION ='ASC') THEN NE_CONTACT_CONFIG_ASC 
                      WHEN (P_ORDER_BY = 'NE_CHANNEL' AND P_ORDER_DIRECTION ='ASC') THEN NE_CHANNEL_ASC 
                      WHEN (P_ORDER_BY = 'NE_EVENT_CODE' AND P_ORDER_DIRECTION ='ASC') THEN NE_EVENT_CODE_ASC 
                     
                      WHEN (P_ORDER_BY = 'PROCESS_CODE' AND P_ORDER_DIRECTION ='DESC') THEN PROCESS_CODE_DESC 
                      WHEN (P_ORDER_BY = 'SOURCE_STATE' AND P_ORDER_DIRECTION ='DESC') THEN SOURCE_STATE_DESC 
                      WHEN (P_ORDER_BY = 'ACTION' AND P_ORDER_DIRECTION ='DESC') THEN ACTION_DESC 
                      WHEN (P_ORDER_BY = 'ACTION_STATUS' AND P_ORDER_DIRECTION ='DESC') THEN ACTION_STATUS_DESC 
                      WHEN (P_ORDER_BY = 'TARGET_STATE' AND P_ORDER_DIRECTION ='DESC') THEN TARGET_STATE_DESC 
                      WHEN (P_ORDER_BY = 'MANUAL_ACTION_FLAG' AND P_ORDER_DIRECTION ='DESC') THEN MANUAL_ACTION_FLAG_DESC 
                      WHEN (P_ORDER_BY = 'AUTO_RETRY_FLAG' AND P_ORDER_DIRECTION ='DESC') THEN AUTO_RETRY_FLAG_DESC 
                      WHEN (P_ORDER_BY = 'MANUAL_ACTION' AND P_ORDER_DIRECTION ='DESC') THEN MANUAL_ACTION_DESC 
                      WHEN (P_ORDER_BY = 'DESCRIPTION' AND P_ORDER_DIRECTION ='DESC') THEN DESCRIPTION_DESC 
                      WHEN (P_ORDER_BY = 'BKF_USER_ROLE' AND P_ORDER_DIRECTION ='DESC') THEN BKF_USER_ROLE_DESC 
                      WHEN (P_ORDER_BY = 'NE_CONTACT_CONFIG' AND P_ORDER_DIRECTION ='DESC') THEN NE_CONTACT_CONFIG_DESC 
                      WHEN (P_ORDER_BY = 'NE_CHANNEL' AND P_ORDER_DIRECTION ='DESC') THEN NE_CHANNEL_DESC 
                      WHEN (P_ORDER_BY = 'NE_EVENT_CODE' AND P_ORDER_DIRECTION ='DESC') THEN NE_EVENT_CODE_DESC 
                      ELSE PROCESS_CODE_ASC
                      END 
                      BETWEEN P_OFFSET AND (P_OFFSET + P_MAX_RECORDS - 1)
              );

        SELECT COUNT(1)
          INTO P_MATCHED_RECORDS
          FROM  LKP_STATE_TRANSITIONS ST
          WHERE ST.BKF_USER_ROLE = P_USER_ROLE;
                                        

        IF P_OFFSET IS NOT NULL AND P_MAX_RECORDS IS NOT NULL THEN  
          IF P_OFFSET > TO_NUMBER(P_MATCHED_RECORDS) THEN
              P_SENT_RECORDS := '0';
          ELSE
              IF (P_OFFSET + P_MAX_RECORDS - 1) > TO_number(P_MATCHED_RECORDS) THEN
                  P_SENT_RECORDS := (P_MATCHED_RECORDS - P_OFFSET) + 1 ;
              ELSE
                  P_SENT_RECORDS := P_MAX_RECORDS;
              END IF;
          END IF;
        ELSE
          P_SENT_RECORDS := P_MATCHED_RECORDS;
        END IF;                   

  EXCEPTION
  
    WHEN EXIT_PROCEDURE THEN
      NULL;
    WHEN OTHERS THEN
      P_STATUS_CODE := ERROR_CODES.UNRECOVERABLE_DB_ERROR;
  END;
  
  DEBUG_STORED_PROCEDURES(  
                            MSG_ID           => P_MSG_ID,
                            P_NAME           => 'GET_STATUS_LIST ',
                            STARTTIME        => V_START_TIME,
                            STATUS_CODE      => P_STATUS_CODE,
                            STATUS_DESC      => P_STATUS_DESC,
                            P_REQ_MODE       => P_REQ_MODE,
                            P_SC_ID          => P_SC_ID,
                            P_FUN_ID         => P_FUN_ID,
                            P_USER_ID        => P_USER_ID,
                            P_CUST_LANG_PREF => P_CUST_LANG_PREF,
                            ORA_CODE         => V_ORA_CODE,
                            VERSION          => P_VERSION,
                -------------------------------------------------------------------
                            PARAM1_NAME      => 'P_USER_ROLE',
                            PARAM1_VALUE     => P_USER_ROLE ,
                            PARAM2_NAME      => 'P_ORDER_BY',
                            PARAM2_VALUE     => P_ORDER_BY,
                            PARAM3_NAME      => 'P_ORDER_DIRECTION',
                            PARAM3_VALUE     => P_ORDER_DIRECTION,
                            PARAM4_NAME      => 'P_MAX_RECORDS',
                            PARAM4_VALUE     => P_MAX_RECORDS,
                            PARAM5_NAME      => 'P_OFFSET',
                            PARAM5_VALUE     => P_OFFSET,
                            PARAM6_NAME      => 'P_MATCHED_RECORDS',
                            PARAM6_VALUE     => P_MATCHED_RECORDS,
                            PARAM7_NAME      => 'P_SENT_RECORDS',
                            PARAM7_VALUE     => P_SENT_RECORDS,
                            PARAM97_NAME     => 'P_STATUS_LIST',
                            PARAM97_VALUE    => P_STATUS_LIST 
                          );
END GET_STATUS_LIST ;