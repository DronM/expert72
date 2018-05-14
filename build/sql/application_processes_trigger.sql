-- Trigger: application_processes_after_trigger on application_processes

-- DROP TRIGGER application_processes_after_trigger ON application_processes;

 CREATE TRIGGER application_processes_after_trigger
  AFTER INSERT
  ON application_processes
  FOR EACH ROW
  EXECUTE PROCEDURE application_processes_process();
