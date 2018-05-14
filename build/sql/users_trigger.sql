-- Trigger: users_trigger on users

-- DROP TRIGGER users_after_trigger ON users;  
 CREATE TRIGGER users_after_trigger
  AFTER INSERT OR UPDATE
  ON users
  FOR EACH ROW
  EXECUTE PROCEDURE users_process();
