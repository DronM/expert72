-- Trigger: mail_for_sending_attachments_lk_trigger on mail_for_sending_attachments_lk

-- DROP TRIGGER mail_for_sending_attachments_lk_after_trigger ON mail_for_sending_lk;  
 CREATE TRIGGER mail_for_sending_attachments_lk_after_trigger
  AFTER INSERT OR UPDATE OR DELETE
  ON mail_for_sending_attachments_lk
  FOR EACH ROW
  EXECUTE PROCEDURE mail_for_sending_attachments_lk_process();
