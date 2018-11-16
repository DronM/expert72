-- Trigger: users_lk_trigger on users_lk

-- DROP TRIGGER users_lk_after_trigger ON users_lk;  
 CREATE TRIGGER users_lk_after_trigger
  AFTER INSERT OR UPDATE OR DELETE
  ON users_lk
  FOR EACH ROW
  EXECUTE PROCEDURE users_lk_process();
