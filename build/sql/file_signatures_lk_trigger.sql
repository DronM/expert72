-- Trigger: file_signatures_lk_trigger on file_signatures_lk

-- DROP TRIGGER file_signatures_lk_after_trigger ON file_signatures_lk;  
 CREATE TRIGGER file_signatures_lk_after_trigger
  AFTER INSERT OR UPDATE OR DELETE
  ON file_signatures_lk
  FOR EACH ROW
  EXECUTE PROCEDURE file_signatures_lk_process();
