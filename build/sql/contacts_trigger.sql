 DROP TRIGGER contacts_before_trigger ON contacts;  
 CREATE TRIGGER contacts_before_trigger
  BEFORE INSERT OR UPDATE
  ON contacts
  FOR EACH ROW
  EXECUTE PROCEDURE contacts_process();
