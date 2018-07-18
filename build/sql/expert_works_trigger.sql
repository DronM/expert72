-- Trigger: expert_works_after_trigger on expert_works

-- DROP TRIGGER expert_works_after_trigger ON expert_works;

 CREATE TRIGGER expert_works_after_trigger
  AFTER INSERT OR UPDATE OR DELETE
  ON expert_works
  FOR EACH ROW
  EXECUTE PROCEDURE expert_works_process();
