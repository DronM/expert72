-- Trigger: user_certificates_lk_trigger on user_certificates_lk

-- DROP TRIGGER user_certificates_lk_after_trigger ON user_certificates_lk;  
 CREATE TRIGGER user_certificates_lk_after_trigger
  AFTER INSERT OR UPDATE OR DELETE
  ON user_certificates_lk
  FOR EACH ROW
  EXECUTE PROCEDURE user_certificates_lk_process();
