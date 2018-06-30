-- Trigger: application_corrections_after_trigger on application_corrections

-- DROP TRIGGER application_corrections_after_trigger ON application_corrections;

 CREATE TRIGGER application_corrections_after_trigger
  AFTER INSERT
  ON application_corrections
  FOR EACH ROW
  EXECUTE PROCEDURE application_corrections_process();
