-- Trigger: mail_for_sending_before_trigger on application_processes

-- DROP TRIGGER mail_for_sending_before_trigger ON mail_for_sending;

 CREATE TRIGGER mail_for_sending_before_trigger
  BEFORE INSERT OR DELETE
  ON mail_for_sending
  FOR EACH ROW
  EXECUTE PROCEDURE mail_for_sending_process();
