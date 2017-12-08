-- Trigger: applications_trigger on applications

-- DROP TRIGGER applications_before_trigger ON applications;
/*
CREATE TRIGGER applications_before_trigger
  BEFORE DELETE
  ON applications
  FOR EACH ROW
  EXECUTE PROCEDURE applications_process();
*/
-- DROP TRIGGER applications_after_trigger ON applications;  
 CREATE TRIGGER applications_after_trigger
  AFTER INSERT
  ON applications
  FOR EACH ROW
  EXECUTE PROCEDURE applications_process();
