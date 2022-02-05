create or replace PROCEDURE MANAGE_SMPL_REQUEST 
(
    -----------------------------------
    P_MSG_ID         IN VARCHAR2,
    P_REQUEST_ID     IN VARCHAR2,
    P_DBG_MD         IN VARCHAR2,
    P_SC_ID          IN VARCHAR2, 
    P_FUN_ID         IN VARCHAR2,
    P_REQ_MODE       IN VARCHAR2,
    P_CUST_LANG_PREF IN VARCHAR2,
    P_CIF            IN VARCHAR2,
    P_USER_ID        IN VARCHAR2,
    P_AGENT_ID       IN VARCHAR2,
    P_STATUS_CODE    OUT VARCHAR2,
    P_STATUS_DESC    OUT VARCHAR2,
    -------------------------------------------
    P_SMPL_REQUEST_ID         VARCHAR2 ,
    P_SMPL_REQUEST_TS         VARCHAR2, --YYYY-MM-DDThh:mm:ss
    P_REQUEST_SC_ID          VARCHAR2, --Service consumer identifier
    P_REQUEST_SC_IP_ADDRESS  VARCHAR2 ,--IP address of the service consumer
    P_PARTNER_ID             VARCHAR2,
    P_REQUEST_CHANNEL_ID     VARCHAR2 , 
    P_REQUEST_SUB_CHANNEL_ID VARCHAR2 ,
    P_SRC_REQUEST_MODE       VARCHAR2, 
    P_CONFIDENTIALITY_FLAG   VARCHAR2, 
    P_CORRELATION_REFERENCE  VARCHAR2 ,
    P_REQUEST_CLASSIFICATION VARCHAR2,
    P_PREVIOUS_HASH          VARCHAR2,
    --
    P_REQUESTER_ID                VARCHAR2,
    P_REQUESTER_NAME              VARCHAR2 ,
    P_REQUESTER_POSITION          VARCHAR2 ,
    P_REQUESTER_REFERENCE_NUMBER  VARCHAR2 ,
    P_REQUESTER_GEO_LOCATION      VARCHAR2 ,
    P_REQUESTER_GEO_LOCATION_DESC VARCHAR2 ,
    P_PARTY_TYPE                  VARCHAR2, -- BI ??
    P_PARTY_ID                    VARCHAR2,
    P_PARTY_ID_TYPE               VARCHAR2, -- Rajhi -- BI ??
    P_PARTY_NAME                  VARCHAR2,
    P_PARTY_FIRST_NAME            VARCHAR2 , --?? BI
    P_PARTY_SECOND_NAME           VARCHAR2 , -- ?? BI
    P_PARTY_THIRD_NAME            VARCHAR2 , -- ?? BI
    P_PARTY_LAST_NAME             VARCHAR2 , --?? BI
    P_PARTY_NATIONALITY           VARCHAR2 ,
    P_THIRD_PARTY_ID              VARCHAR2,
    P_THIRD_PARTY_ID_TYPE         VARCHAR2,
    P_THIRD_PARTY_NAME            VARCHAR2,
    P_CUSTOMER_FIRST_NAME_AR      VARCHAR2 ,
    P_CUSTOMER_SECOND_NAME_AR     VARCHAR2 ,
    P_CUSTOMER_THIRD_NAME_AR      VARCHAR2 ,
    P_CUSTOMER_LAST_NAME_AR       VARCHAR2 ,
    P_CUSTOMER_FULL_NAME_AR       VARCHAR2 ,
    P_CUSTOMER_FIRST_NAME_EN      VARCHAR2 ,
    P_CUSTOMER_SECOND_NAME_EN     VARCHAR2 ,
    P_CUSTOMER_THIRD_NAME_EN      VARCHAR2 ,
    P_CUSTOMER_LAST_NAME_EN       VARCHAR2 ,
    P_CUSTOMER_FULL_NAME_EN       VARCHAR2 ,
    P_CUSTOMER_CIC                VARCHAR2 ,
    P_ACCOUNT_NUMBER              VARCHAR2 ,
    P_IBAN                        VARCHAR2, 
    P_APPROVER_COMMENT            VARCHAR2 , -- ??
    P_TERMINATION_REASON          VARCHAR2 , -- ??
    P_REQUEST_MESSAGE CLOB,
    P_RESPONSE_MESSAGE CLOB , 
    P_SMPL_REQUEST_TYPE  VARCHAR2,
    P_STM_ID          IN OUT VARCHAR2 , --STM	SMPL Tanfeeth Management System
    P_LAST_STATE IN VARCHAR2,  
    P_SRN IN VARCHAR2, 
    P_BPM_INSTANCE_ID IN VARCHAR2,
    P_FULFILLER_ID  IN VARCHAR2, -- ??
    P_APPROVER_ID IN VARCHAR2, -- ??
    P_request_sub_type  IN VARCHAR2
    )
AS

  V_START_TIME TIMESTAMP                             := SYSTIMESTAMP();
  V_VERSION NUMBER                                   := 1.0;
  V_ORA_CODE STORED_PROCEDURE_DEBUGGING.SPD_ORA%TYPE := SQLERRM;
  EXIT_PROCEDURE EXCEPTION;
  
  
  V_SMPL_REQUEST_ID    REQUEST.R_REQUEST_ID%TYPE;
  V_SOURCE_STATE_CODE  REQUEST.R_STATE%TYPE;
  --  -- V_ORG_p2 VARCHAR2(500) := p2;
  
  -- V_REQUEST_COUNT       INTEGER;
  --V_STATUS_CODE VARCHAR2(100);
  --V_STM_ID VARCHAR2(100);

-- 
--  V_TARGET_STATE_CODE  REQUEST.R_STATE%TYPE;
--  V_REQUEST_MESSAGE    REQUEST.R_REQUEST_MESSAGE%TYPE;
--  V_RESPONSE_MESSAGE   REQUEST.R_RESPONSE_MESSAGE%TYPE;
--  
--  V_ACTION_STATUS      REQUEST.R_NEED_APPROVAL%TYPE;
--  V_LAST_ACTION        REQUEST.R_LAST_ACTION%TYPE;
--  V_REQUEST_TYPE       REQUEST.R_REQUEST_TYPE%TYPE;
--  V_SMPL_REQUEST_TYPE   MAKER_CHECKER_CONFIGURATION.SMPL_REQUEST_TYPE%TYPE;
--  V_BPM_REQUEST_TYPE    MAKER_CHECKER_CONFIGURATION.BPM_REQUEST_TYPE%TYPE;
--  V_MAKER_CHECKER_FLAG  MAKER_CHECKER_CONFIGURATION.MAKER_CHECKER_FLAG%TYPE;
--  

  
  
BEGIN
  BEGIN
    
 /*-------------------------------   
Created by:   
Creaded Date: 09/10/2018
Description: 

Create new request record in STM upon receiving from SMPL or update the information & status during request fulfilling processing.

The following Fields will be passed to create/update the request record:
	Mode (Create , Update Info, Update Status)
	Request Reference Number
	CIC number
	Party Type (IND, COR, GOV, CHR, CHM)
	Party ID Type
	Party ID Number
	Party Name
	Account Number
	Submit timestamp
	New Application Status 
	Request Information XML
Audit trail should be recorded for status update along with information like Old Status, new Status and update timestamp, user information, approval information

-------------------------------------------------------------------------------------------------------------------------------------*/
    
-------------------------------------------------Validations-----------------------------------------------
  
    IF P_SRN IS NULL THEN
       P_STATUS_CODE := ERROR_CODES.SMPL_REQUEST_ID_IS_REQUIRED;
       P_STATUS_DESC := 'SMPL Request Reference is Required';
       RAISE EXIT_PROCEDURE;
    END IF;
       
    
    P_STATUS_CODE := ERROR_CODES.SUCCESSFUL_OPERATION;
    P_STATUS_DESC := 'Successful Operation';
      
      
    IF     P_FUN_ID='C' THEN
      
           IF P_SMPL_REQUEST_TS IS NULL THEN
             P_STATUS_CODE := ERROR_CODES.SMAM_SMPL_REQ_TS_IS_REQUIRED;
             P_STATUS_DESC := 'SMPL Request Time Stamp is Required';
             RAISE EXIT_PROCEDURE;
          END IF;
          
          BEGIN
          
            SELECT R_REQUEST_ID
             INTO V_SMPL_REQUEST_ID
             FROM REQUEST WHERE R_REQUEST_ID = P_SMPL_REQUEST_ID;
            
           
           EXCEPTION
            WHEN NO_DATA_FOUND THEN
                                         
                INSERT INTO REQUEST (R_REQUEST_ID, R_PARTNER_ID, --R_LAST_ACTION,
                R_STATE, R_STM_ID, R_REQUEST_TS
                              , R_REQUEST_MODE, R_CORRELATION_REFERENCE, R_PREVIOUS_HASH, R_REQUEST_CLASSIFICATION, R_REQUESTER_ID, R_REQUESTER_NAME
                              , R_REQUESTER_POSITION, R_REQUESTER_REFERENCE_NUMBER, R_REQUESTER_GEO_LOCATION, R_REQUESTER_GEO_LOCATION_DESC
                              , R_PARTY_TYPE, R_PARTY_ID, R_PARTY_ID_TYPE, R_PARTY_NAME, R_PARTY_FIRST_NAME, R_PARTY_SECOND_NAME
                              , R_PARTY_THIRD_NAME, R_PARTY_LAST_NAME, R_PARTY_NATIONALITY, R_THIRD_PARTY_ID, R_THIRD_PARTY_ID_TYPE
                              , R_THIRD_PARTY_NAME, R_CUSTOMER_FIRST_NAME_AR, R_CUSTOMER_SECOND_NAME_AR, R_CUSTOMER_THIRD_NAME_AR
                              , R_CUSTOMER_LAST_NAME_AR, R_CUSTOMER_FULL_NAME_AR, R_CUSTOMER_FIRST_NAME_EN
                              , R_CUSTOMER_SECOND_NAME_EN, R_CUSTOMER_THIRD_NAME_EN, R_CUSTOMER_LAST_NAME_EN, R_CUSTOMER_FULL_NAME_EN
                              , R_CUSTOMER_CIC, R_ACCOUNT_NUMBER, R_IBAN, R_APPROVER_COMMENT, R_TERMINATION_REASON, R_CREATION_DATE
                              , R_DATA_COLLECTION_RETRY, R_REQUEST_MESSAGE, R_CONFIDENTIALITY_FLAG, R_SUB_CHANNEL_ID
                              , R_CHANNEL_ID, R_SC_IP_ADDRESS, R_SC_ID, R_RESPONSE_MESSAGE, R_REQUEST_TYPE, R_CALLBACK_RETRY
                              ,-- R_EAI_STATUS_CODE, 
                          --    R_RETURN_CODE,
                              --R_OUTPUT_ATTRIBUTE_NAME, R_OUTPUT_ATTRIBUTE_VALUE, R_INPUT_ATTRIBUTE_NAME, R_INPUT_ATTRIBUTE_VALUE,
                              R_SRN, R_STATE_TS
                              
                              )
                              
                  VALUES (  P_SMPL_REQUEST_ID, P_PARTNER_ID, --P_ACTION,
                  P_LAST_STATE, P_STM_ID,  TO_TIMESTAMP(P_SMPL_REQUEST_TS,'YYYY-MM-DD"T"hh24:mi:ss')
                          , P_SRC_REQUEST_MODE, P_SMPL_REQUEST_ID, P_PREVIOUS_HASH, P_REQUEST_CLASSIFICATION, P_REQUESTER_ID, P_REQUESTER_NAME
                          , P_REQUESTER_POSITION, P_REQUESTER_REFERENCE_NUMBER, P_REQUESTER_GEO_LOCATION, P_REQUESTER_GEO_LOCATION_DESC
                          , P_PARTY_TYPE, P_PARTY_ID, P_PARTY_ID_TYPE, P_PARTY_NAME, P_PARTY_FIRST_NAME , P_PARTY_SECOND_NAME
                          , P_PARTY_THIRD_NAME, P_PARTY_LAST_NAME, P_PARTY_NATIONALITY, P_THIRD_PARTY_ID, P_THIRD_PARTY_ID_TYPE
                          , P_THIRD_PARTY_NAME, P_CUSTOMER_FIRST_NAME_AR, P_CUSTOMER_SECOND_NAME_AR, P_CUSTOMER_THIRD_NAME_AR
                          , P_CUSTOMER_LAST_NAME_AR, P_CUSTOMER_FULL_NAME_AR, P_CUSTOMER_FIRST_NAME_EN
                          , P_CUSTOMER_SECOND_NAME_EN, P_CUSTOMER_THIRD_NAME_EN,P_CUSTOMER_LAST_NAME_EN, P_CUSTOMER_FULL_NAME_EN
                          , P_CUSTOMER_CIC, P_ACCOUNT_NUMBER, P_IBAN, P_APPROVER_COMMENT, P_TERMINATION_REASON, SYSTIMESTAMP
                          , 0, P_REQUEST_MESSAGE, P_CONFIDENTIALITY_FLAG, P_REQUEST_SUB_CHANNEL_ID, P_REQUEST_CHANNEL_ID
                          , P_REQUEST_SC_IP_ADDRESS, P_REQUEST_SC_ID, P_RESPONSE_MESSAGE, P_SMPL_REQUEST_TYPE, 0,
      -- P_EAI_STATUS_CODE, 
       --                   P_RETURN_CODE, 
                          --P_OUTPUT_ATTRIBUTE_NAME,P_OUTPUT_ATTRIBUTE_VALUE, P_INPUT_ATTRIBUTE_NAME , P_INPUT_ATTRIBUTE_VALUE,
                          P_SRN,  SYSTIMESTAMP
                         
                          );
                   END;       
                   
          IF V_SMPL_REQUEST_ID IS NOT NULL THEN
            P_STATUS_CODE := ERROR_CODES.SMPL_REQUEST_ID_IS_REPEATED;
            P_STATUS_DESC := 'SMPL Request Id is Repeated';
            RAISE EXIT_PROCEDURE;
          END IF;
                      
       ELSIF     P_FUN_ID='U' THEN----update
          
          BEGIN
            SELECT R_STATE
              INTO V_SOURCE_STATE_CODE
              FROM REQUEST  WHERE R_REQUEST_ID =  P_SMPL_REQUEST_ID;
           EXCEPTION 
              WHEN NO_DATA_FOUND THEN
                   P_STATUS_CODE := ERROR_CODES.INVALID_SMPL_REQUEST_ID;
                   P_STATUS_DESC := 'SMPL Request Id is Invalid';
                   RAISE EXIT_PROCEDURE;  
           END;
           
            IF P_LAST_STATE IS NOT NULL and P_LAST_STATE <> V_SOURCE_STATE_CODE THEN
                  MANAGE_REQUEST_HISTORY(
                               P_MSG_ID => P_MSG_ID,
                               P_REQUEST_ID => P_REQUEST_ID,
                               P_DBG_MD => P_DBG_MD,
                               P_SC_ID => P_SC_ID,
                               P_FUN_ID => P_FUN_ID,
                               P_REQ_MODE => P_REQ_MODE,
                               P_CUST_LANG_PREF => P_CUST_LANG_PREF,
                               P_CIF => P_CIF,
                               P_USER_ID => P_USER_ID,
                               P_AGENT_ID => P_AGENT_ID,
                               P_STATUS_CODE => P_STATUS_CODE,
                               P_STATUS_DESC => P_STATUS_DESC,
                               P_SMPL_REQUEST_ID => P_SMPL_REQUEST_ID
                               );
            END IF;
          
             UPDATE REQUEST SET R_STATE = NVL(P_LAST_STATE,R_STATE),
                                R_STATE_TS = DECODE(P_LAST_STATE,NULL,R_STATE,SYSTIMESTAMP),
                               R_LST_UPDATE_DATE = SYSTIMESTAMP,
                               R_RESPONSE_MESSAGE = P_RESPONSE_MESSAGE,
                               
                  R_CUSTOMER_FIRST_NAME_AR = P_CUSTOMER_FIRST_NAME_AR, --
                  R_CUSTOMER_SECOND_NAME_AR=P_CUSTOMER_SECOND_NAME_AR,
                  R_CUSTOMER_THIRD_NAME_AR=P_CUSTOMER_THIRD_NAME_AR,
                  R_CUSTOMER_LAST_NAME_AR=P_CUSTOMER_LAST_NAME_AR,
                  R_CUSTOMER_FULL_NAME_AR=P_CUSTOMER_FULL_NAME_AR,
                  R_CUSTOMER_FIRST_NAME_EN=P_CUSTOMER_FIRST_NAME_EN,
                  R_CUSTOMER_SECOND_NAME_EN=P_CUSTOMER_SECOND_NAME_EN,
                  R_CUSTOMER_THIRD_NAME_EN=P_CUSTOMER_THIRD_NAME_EN,
                  R_CUSTOMER_LAST_NAME_EN=P_CUSTOMER_LAST_NAME_EN,
                  R_CUSTOMER_FULL_NAME_EN=P_CUSTOMER_FULL_NAME_EN,
                  R_CUSTOMER_CIC=P_CUSTOMER_CIC,
                  R_APPROVER_COMMENT=P_APPROVER_COMMENT,
                  R_TERMINATION_REASON=P_TERMINATION_REASON,
                  R_BPM_INSTANCE_ID=P_BPM_INSTANCE_ID,
                  R_BPM_INSTANCE_TS= NVL(R_BPM_INSTANCE_TS,SYSTIMESTAMP),
                  R_APPROVER_ID= P_APPROVER_ID,--P_USER_ID,
                  R_FULFILLER_ID=P_FULFILLER_ID               
                WHERE R_REQUEST_ID =  P_SMPL_REQUEST_ID;
      ELSE --Function Id is Invalid
          P_STATUS_CODE := ERROR_CODES.INVALID_FUNCTION_ID;
          P_STATUS_DESC := 'Function Id is Invalid';
           RAISE EXIT_PROCEDURE;  
      END IF;
      --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--

    
  EXCEPTION
  WHEN EXIT_PROCEDURE THEN
    NULL;
  WHEN OTHERS THEN
    P_STATUS_CODE := ERROR_CODES.UNRECOVERABLE_DB_ERROR;
    P_STATUS_DESC := 'DB generic Error';
    V_ORA_CODE    := SQLERRM || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE;
  END;
  DEBUG_STORED_PROCEDURES(MSG_ID => P_MSG_ID, P_REQUEST_ID => P_REQUEST_ID, P_DBG_MD => P_DBG_MD, P_SC_ID => P_SC_ID, P_FUN_ID => P_FUN_ID, P_REQ_MODE => P_REQ_MODE, P_CUST_LANG_PREF => P_CUST_LANG_PREF, P_CIF => P_CIF, P_USER_ID => P_USER_ID, P_AGENT_ID => P_AGENT_ID, STARTTIME => V_START_TIME, ORA_CODE => V_ORA_CODE, VERSION => V_VERSION, STATUS_CODE => P_STATUS_CODE, P_NAME =>'MANAGE_SMPL_REQUEST',
  
               PARAM1_NAME   => 'P_SMPL_REQUEST_ID',
          	   PARAM1_VALUE  => P_SMPL_REQUEST_ID,
               PARAM2_NAME   => 'P_SMPL_REQUEST_TS',
          	   PARAM2_VALUE  => P_SMPL_REQUEST_TS,
               PARAM3_NAME   => 'P_REQUEST_SC_ID',
               PARAM3_VALUE  => P_REQUEST_SC_ID,
               PARAM4_NAME   => 'P_REQUEST_SC_IP_ADDRESS',
               PARAM4_VALUE  => P_REQUEST_SC_IP_ADDRESS,
               PARAM5_NAME   => 'P_PARTNER_ID',
               PARAM5_VALUE  => P_PARTNER_ID,
               PARAM6_NAME   => 'P_REQUEST_CHANNEL_ID',
               PARAM6_VALUE  => P_REQUEST_CHANNEL_ID,
               PARAM7_NAME   => 'P_REQUEST_SUB_CHANNEL_ID',
               PARAM7_VALUE  => P_REQUEST_SUB_CHANNEL_ID,
               PARAM8_NAME   => 'P_SRC_REQUEST_MODE',
               PARAM8_VALUE  => P_SRC_REQUEST_MODE,
               PARAM9_NAME   => 'P_CONFIDENTIALITY_FLAG',
               PARAM9_VALUE  => P_CONFIDENTIALITY_FLAG,
               PARAM10_NAME  => 'P_CORRELATION_REFERENCE',
               PARAM10_VALUE => P_CORRELATION_REFERENCE,
               PARAM11_NAME  => 'P_REQUEST_CLASSIFICATION',
               PARAM11_VALUE => P_REQUEST_CLASSIFICATION,
               PARAM12_NAME  => 'P_PREVIOUS_HASH',
               PARAM12_VALUE => P_PREVIOUS_HASH,
              -- PARAM13_NAME  => 'P_ACTION',
            --   PARAM13_VALUE => P_ACTION,
               PARAM14_NAME  => 'P_REQUESTER_ID',
               PARAM14_VALUE => P_REQUESTER_ID,
               PARAM15_NAME  => 'P_REQUESTER_NAME',
               PARAM15_VALUE => P_REQUESTER_NAME,
               PARAM16_NAME  => 'P_REQUESTER_POSITION',
               PARAM16_VALUE => P_REQUESTER_POSITION,
               PARAM17_NAME  => 'P_REQUESTER_REFERENCE_NUMBER',
               PARAM17_VALUE => P_REQUESTER_REFERENCE_NUMBER,
               PARAM18_NAME  => 'P_REQUESTER_GEO_LOCATION',
               PARAM18_VALUE => P_REQUESTER_GEO_LOCATION,
               PARAM19_NAME  => 'P_REQUESTER_GEO_LOCATION_DESC',
               PARAM19_VALUE => P_REQUESTER_GEO_LOCATION_DESC,
               PARAM20_NAME  => 'P_PARTY_TYPE',
               PARAM20_VALUE => P_PARTY_TYPE,
               PARAM21_NAME  => 'P_PARTY_ID',
               PARAM21_VALUE => P_PARTY_ID,
               PARAM22_NAME  => 'P_PARTY_ID_TYPE',
               PARAM22_VALUE => P_PARTY_ID_TYPE,
               PARAM23_NAME  => 'P_PARTY_NAME',
               PARAM23_VALUE => P_PARTY_NAME,
               PARAM24_NAME  => 'P_PARTY_FIRST_NAME',
               PARAM24_VALUE => P_PARTY_FIRST_NAME,
               PARAM25_NAME  => 'P_PARTY_SECOND_NAME',
               PARAM25_VALUE => P_PARTY_SECOND_NAME,
               PARAM26_NAME  => 'P_PARTY_THIRD_NAME',
               PARAM26_VALUE => P_PARTY_THIRD_NAME,
               PARAM27_NAME  => 'P_PARTY_LAST_NAME',
               PARAM27_VALUE => P_PARTY_LAST_NAME,
               PARAM28_NAME  => 'P_PARTY_NATIONALITY',
               PARAM28_VALUE => P_PARTY_NATIONALITY,
               PARAM29_NAME  => 'P_THIRD_PARTY_ID',
               PARAM29_VALUE => P_THIRD_PARTY_ID,
               PARAM30_NAME  => 'P_THIRD_PARTY_ID_TYPE',
               PARAM30_VALUE => P_THIRD_PARTY_ID_TYPE,
               PARAM31_NAME  => 'P_THIRD_PARTY_NAME',
               PARAM31_VALUE => P_THIRD_PARTY_NAME,
               PARAM32_NAME  => 'P_CUSTOMER_FIRST_NAME_AR',
               PARAM32_VALUE => P_CUSTOMER_FIRST_NAME_AR,
               PARAM33_NAME  => 'P_CUSTOMER_SECOND_NAME_AR',
               PARAM33_VALUE => P_CUSTOMER_SECOND_NAME_AR,
               PARAM34_NAME  => 'P_CUSTOMER_THIRD_NAME_AR',
               PARAM34_VALUE => P_CUSTOMER_THIRD_NAME_AR,
               PARAM35_NAME  => 'P_CUSTOMER_LAST_NAME_AR',
               PARAM35_VALUE => P_CUSTOMER_LAST_NAME_AR,
               PARAM36_NAME  => 'P_CUSTOMER_FULL_NAME_AR',
               PARAM36_VALUE => P_CUSTOMER_FULL_NAME_AR,
               PARAM37_NAME  => 'P_CUSTOMER_FIRST_NAME_EN',
               PARAM37_VALUE => P_CUSTOMER_FIRST_NAME_EN,
               PARAM38_NAME  => 'P_CUSTOMER_SECOND_NAME_EN',
               PARAM38_VALUE => P_CUSTOMER_SECOND_NAME_EN,
               PARAM39_NAME  => 'P_CUSTOMER_THIRD_NAME_EN',
               PARAM39_VALUE => P_CUSTOMER_THIRD_NAME_EN,
               PARAM40_NAME  => 'P_CUSTOMER_LAST_NAME_EN',
               PARAM40_VALUE => P_CUSTOMER_LAST_NAME_EN,
               PARAM41_NAME  => 'P_CUSTOMER_FULL_NAME_EN',
               PARAM41_VALUE => P_CUSTOMER_FULL_NAME_EN,
               PARAM42_NAME  => 'P_CUSTOMER_CIC',
               PARAM42_VALUE => P_CUSTOMER_CIC,
               PARAM43_NAME  => 'P_ACCOUNT_NUMBER',
               PARAM43_VALUE => P_ACCOUNT_NUMBER,
               PARAM44_NAME  => 'P_IBAN',
               PARAM44_VALUE => P_IBAN,
               PARAM45_NAME  => 'P_APPROVER_COMMENT',
               PARAM45_VALUE => P_APPROVER_COMMENT,
               PARAM46_NAME  => 'P_TERMINATION_REASON',
               PARAM46_VALUE => P_TERMINATION_REASON,
          --     PARAM47_NAME  => 'P_INPUT_ATTRIBUTE_NAME',
          --     PARAM47_VALUE => P_INPUT_ATTRIBUTE_NAME,
          --     PARAM48_NAME  => 'P_INPUT_ATTRIBUTE_VALUE',
          --     PARAM48_VALUE => P_INPUT_ATTRIBUTE_VALUE,
          --     PARAM49_NAME  => 'P_OUTPUT_ATTRIBUTE_NAME',
          --     PARAM49_VALUE => P_OUTPUT_ATTRIBUTE_NAME,
          --     PARAM50_NAME  => 'P_OUTPUT_ATTRIBUTE_VALUE',
          --     PARAM50_VALUE => P_OUTPUT_ATTRIBUTE_VALUE,
          --     PARAM51_NAME  => 'P_EAI_STATUS_CODE',
          --     PARAM51_VALUE => P_EAI_STATUS_CODE,
          --     PARAM52_NAME  => 'P_RETURN_CODE',
          --     PARAM52_VALUE => P_RETURN_CODE,
               PARAM53_NAME  => 'P_SMPL_REQUEST_TYPE',
               PARAM53_VALUE => P_SMPL_REQUEST_TYPE,
               PARAM54_NAME  => 'P_STM_ID',
               PARAM54_VALUE => P_STM_ID,
          --     PARAM55_NAME  => 'P_REPEATED_REQUEST_ID',
          --     PARAM55_VALUE => P_REPEATED_REQUEST_ID,
          --     PARAM56_NAME  => 'P_EAI_STATUS_DESC',
          --     PARAM56_VALUE => P_EAI_STATUS_DESC,
               PARAM57_NAME  => 'P_LAST_STATE',
               PARAM57_VALUE => P_LAST_STATE,
               PARAM58_NAME  => 'P_SRN',
               PARAM58_VALUE => P_SRN,
          --     PARAM59_NAME  => 'P_MATCHING_SCORE',
          --     PARAM59_VALUE => P_MATCHING_SCORE,
          --     PARAM60_NAME  => 'P_MATCHING_STATUS',
          --     PARAM60_VALUE => P_MATCHING_STATUS,
               PARAM61_NAME  => 'P_BPM_INSTANCE_ID',
               PARAM61_VALUE => P_BPM_INSTANCE_ID,
          --     PARAM62_NAME  => 'P_MANUAL_FLAG',
          --     PARAM62_VALUE => P_MANUAL_FLAG,
               PARAM63_NAME => 'P_FULFILLER_ID',
               PARAM63_VALUE => P_FULFILLER_ID,
               PARAM64_NAME => 'P_APPROVER_ID',
               PARAM64_VALUE => P_APPROVER_ID,
          --     PARAM97_NAME => 'P_MULTIPLE_CICS',
          --     PARAM97_VALUE =>P_MULTIPLE_CICS,
               PARAM98_NAME => 'P_RESPONSE_MESSAGE',
               PARAM98_VALUE =>P_RESPONSE_MESSAGE,
               PARAM99_NAME => 'P_REQUEST_MESSAGE',
               PARAM99_VALUE =>P_REQUEST_MESSAGE
  );
END MANAGE_SMPL_REQUEST;