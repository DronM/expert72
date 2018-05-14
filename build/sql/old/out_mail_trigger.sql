-- DROP TRIGGER out_mail_before_trigger ON out_mail;  
 CREATE TRIGGER out_mail_before_trigger
  BEFORE DELETE
  ON out_mail
  FOR EACH ROW
  EXECUTE PROCEDURE out_mail_process();
