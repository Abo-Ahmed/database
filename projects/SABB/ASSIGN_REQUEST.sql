create or replace PROCEDURE ASSIGN_REQUEST(             
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
                                                        P_REQUEST_STM_ID_LIST  IN  VARCHAR2,
                                                        P_ASSIGNED_TO_USER     IN  VARCHAR2
                                          )IS 
                                                           
  /*-------------------------------------------
  This procedure: Assigns users to list of requests
  -------------------------------------------*/  
  V_COUNT        INTEGER ; 
  V_COUNT_USER   INTEGER ;
  V_START_TIME   TIMESTAMP                               := SYSTIMESTAMP();
  V_VERSION      NUMBER                                  := 1.0;
  V_ORA_CODE     STORED_PROCEDURE_DEBUGGING.SPD_ORA%TYPE := SQLERRM;
  EXIT_PROCEDURE EXCEPTION;
 
BEGIN
  BEGIN
    
    P_STATUS_CODE := ERROR_CODES.SUCCESSFUL_OPERATION;
    P_STATUS_DESC := 'Successful Operation';
    
    IF P_ASSIGNED_TO_USER IS NULL THEN
          P_STATUS_CODE := ERROR_CODES.ASSIGNED_USER_IS_REQUIRED;
          P_STATUS_DESC := 'Assigned User Is Required';
          RAISE EXIT_PROCEDURE;
    ELSE
          SELECT COUNT(1)
          INTO V_COUNT_USER
          FROM BKF_APPLICATION_USERS
          WHERE BAU_ID = P_ASSIGNED_TO_USER ;

          IF V_COUNT_USER = 0 THEN
              P_STATUS_CODE := ERROR_CODES.INVALID_ASSIGNED_USER;
              P_STATUS_DESC := 'Assigned User Is not Valid';
              RAISE EXIT_PROCEDURE;
          END IF;
    END IF;

    IF P_REQUEST_STM_ID_LIST IS  NULL THEN
          P_STATUS_CODE := ERROR_CODES.REQUEST_ID_LIST_IS_REQUIRED;
          P_STATUS_DESC := 'Request ID List Is Required';
          RAISE EXIT_PROCEDURE;
    END IF;

    UPDATE REQUEST
        SET 
            R_ASSIGNED_TO = P_ASSIGNED_TO_USER,
            R_ASSIGNEMENT_TS = SYSTIMESTAMP
        WHERE
            R_STM_ID In (
                          SELECT REGEXP_SUBSTR(P_REQUEST_STM_ID_LIST,'[^,]+', 1, LEVEL) FROM DUAL
                          CONNECT BY REGEXP_SUBSTR(P_REQUEST_STM_ID_LIST, '[^,]+', 1, LEVEL) IS NOT NULl
                        );

    IF SQL%NOTFOUND THEN
          P_STATUS_CODE := ERROR_CODES.NO_UPDATES_PERFORMED;
          P_STATUS_DESC := 'No Updates is Performed';
          RAISE EXIT_PROCEDURE;
    END IF;

  EXCEPTION
  
    WHEN EXIT_PROCEDURE THEN
      NULL;
    WHEN OTHERS THEN
      P_STATUS_CODE := ERROR_CODES.UNRECOVERABLE_DB_ERROR;
  END;
  
  DEBUG_STORED_PROCEDURES(  
                            MSG_ID           => P_MSG_ID,
                            P_NAME           => 'ASSIGN_REQUEST',
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
                            PARAM1_NAME      => 'P_REQUEST_STM_ID_LIST',
                            PARAM1_VALUE     => P_REQUEST_STM_ID_LIST , 
                            PARAM2_NAME      => 'P_ASSIGNED_TO_USER',
                            PARAM2_VALUE     => P_ASSIGNED_TO_USER
                          );
END ASSIGN_REQUEST;