-- Trigger: applications_trigger on applications

 DROP TRIGGER applications_before_trigger ON applications;

CREATE TRIGGER applications_before_trigger
  BEFORE DELETE OR UPDATE OR INSERT
  ON applications
  FOR EACH ROW
  EXECUTE PROCEDURE applications_process();

