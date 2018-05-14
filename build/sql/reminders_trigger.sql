-- DROP TRIGGER reminders_after_trigger ON reminders;

 CREATE TRIGGER reminders_after_trigger
  AFTER INSERT OR UPDATE
  ON reminders
  FOR EACH ROW
  EXECUTE PROCEDURE reminders_process();

