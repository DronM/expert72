-- Trigger: application_processes_lk_trigger on application_processes_lk

-- DROP TRIGGER application_processes_lk_after_trigger ON application_processes_lk;  
 CREATE TRIGGER application_processes_lk_after_trigger
  AFTER INSERT OR UPDATE OR DELETE
  ON application_processes_lk
  FOR EACH ROW
  EXECUTE PROCEDURE application_processes_lk_process();
