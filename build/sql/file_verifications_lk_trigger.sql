-- Trigger: file_verifications_lk_trigger on file_verifications_lk

-- DROP TRIGGER file_verifications_lk_after_trigger ON file_verifications_lk;  
/*
 CREATE TRIGGER file_verifications_lk_after_trigger
  AFTER INSERT OR UPDATE OR DELETE
  ON file_verifications_lk
  FOR EACH ROW
  EXECUTE PROCEDURE file_verifications_lk_process();
  */
  
-- DROP TRIGGER file_verifications_lk_before_trigger ON file_verifications_lk;    
   CREATE TRIGGER file_verifications_lk_before_trigger
  BEFORE DELETE
  ON file_verifications_lk
  FOR EACH ROW
  EXECUTE PROCEDURE file_verifications_lk_process();
