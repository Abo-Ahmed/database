create or replace TRIGGER UPDATE_COC_SNOOZE
   AFTER UPDATE  ON CUSTOMERS_OTHER_CONTACTS FOR EACH ROW


DECLARE
   V_REAL_DUE TIMESTAMP(6);
   
   
BEGIN
   
IF ((:NEW.COC_SNOOZE_TO_DATE <> :OLD.COC_SNOOZE_TO_DATE  AND :NEW.COC_SNOOZE_TO_DATE IS NOT NULL) OR
    (:NEW.COC_BLOCK_TO_TIME <> :OLD.COC_BLOCK_TO_TIME  AND :NEW.COC_BLOCK_TO_TIME IS NOT NULL))THEN
    
    
    V_REAL_DUE := GET_CONTACT_DUE_TO_TIMESTAMP (P_SNOOZE_TIME      => :NEW.COC_SNOOZE_TO_DATE,
                                                P_BLOCK_TIME       => :NEW.COC_BLOCK_TO_TIME);
                                      
  
   FOR I IN (SELECT MN_RELATION_TYPE_CODE, MN_RELATION_VALUE, MN_DUE_TO_TIMESTAMP
             FROM MESSAGE_NOTIFICATIONS
             WHERE MN_NOTIFICATION_CHANNEL = :NEW.COC_TYPE
             AND MN_RELATION_TYPE_CODE = :NEW.COC_RELATION_TYPE_CODE
             AND MN_RELATION_VALUE = :NEW.COC_RELATION_VALUE
             AND MN_CONTACT = :NEW.COC_DETAILS
             AND (MN_DUE_TO_TIMESTAMP = NULL
              OR MN_DUE_TO_TIMESTAMP < V_REAL_DUE )) LOOP
              
  
      UPDATE MESSAGE_NOTIFICATIONS
      SET MN_DUE_TO_TIMESTAMP = V_REAL_DUE
      WHERE MN_NOTIFICATION_CHANNEL = :NEW.COC_TYPE
      AND MN_CONTACT = :NEW.COC_DETAILS
      AND MN_RELATION_TYPE_CODE = I.MN_RELATION_TYPE_CODE
      AND MN_RELATION_VALUE = I.MN_RELATION_VALUE;
      
  END LOOP;
  
   FOR Y IN (SELECT MNB_RELATION_TYPE_CODE, MNB_RELATION_VALUE, MNB_DUE_TO_TIMESTAMP
             FROM MESSAGE_NOTIFICATIONS_BULK
             WHERE MNB_NOTIFICATION_CHANNEL = :NEW.COC_TYPE
             AND MNB_RELATION_TYPE_CODE = :NEW.COC_RELATION_TYPE_CODE
             AND MNB_RELATION_VALUE = :NEW.COC_RELATION_VALUE
             AND MNB_CONTACT = :NEW.COC_DETAILS
             AND (MNB_DUE_TO_TIMESTAMP = NULL
              OR MNB_DUE_TO_TIMESTAMP < V_REAL_DUE )) LOOP
              
  
      UPDATE MESSAGE_NOTIFICATIONS_BULK
      SET MNB_DUE_TO_TIMESTAMP = V_REAL_DUE
      WHERE MNB_NOTIFICATION_CHANNEL = :NEW.COC_TYPE
      AND MNB_CONTACT = :NEW.COC_DETAILS
      AND MNB_RELATION_TYPE_CODE = Y.MNB_RELATION_TYPE_CODE
      AND MNB_RELATION_VALUE = Y.MNB_RELATION_VALUE;
      
  END LOOP;
  
   FOR V IN (SELECT MNE_RELATION_TYPE_CODE, MNE_RELATION_VALUE, MNE_DUE_TO_TIMESTAMP
             FROM MESSAGE_NOTIFICATIONS_ESHAAR
             WHERE MNE_NOTIFICATION_CHANNEL = :NEW.COC_TYPE
             AND MNE_RELATION_TYPE_CODE = :NEW.COC_RELATION_TYPE_CODE
             AND MNE_RELATION_VALUE = :NEW.COC_RELATION_VALUE
             AND MNE_CONTACT = :NEW.COC_DETAILS
             AND (MNE_DUE_TO_TIMESTAMP = NULL
              OR MNE_DUE_TO_TIMESTAMP < V_REAL_DUE )) LOOP
              
  
      UPDATE MESSAGE_NOTIFICATIONS_ESHAAR
      SET MNE_DUE_TO_TIMESTAMP = V_REAL_DUE
      WHERE MNE_NOTIFICATION_CHANNEL = :NEW.COC_TYPE
      AND MNE_CONTACT = :NEW.COC_DETAILS
      AND MNE_RELATION_TYPE_CODE = V.MNE_RELATION_TYPE_CODE
      AND MNE_RELATION_VALUE = V.MNE_RELATION_VALUE;
      
  END LOOP;

  
END IF;
 
      
END;