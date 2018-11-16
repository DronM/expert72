-- Trigger: user_email_confirmations_lk_trigger on user_email_confirmations_lk

-- DROP TRIGGER user_email_confirmations_lk_after_trigger ON user_email_confirmations_lk;  
 CREATE TRIGGER user_email_confirmations_lk_after_trigger
  AFTER INSERT OR UPDATE OR DELETE
  ON user_email_confirmations_lk
  FOR EACH ROW
  EXECUTE PROCEDURE user_email_confirmations_lk_process();
