-- DROP TRIGGER doc_flow_examinations_after_trigger ON doc_flow_examinations;

 CREATE TRIGGER doc_flow_examinations_after_trigger
  AFTER INSERT OR UPDATE
  ON doc_flow_examinations
  FOR EACH ROW
  EXECUTE PROCEDURE doc_flow_examinations_process();
  
  -- DROP TRIGGER doc_flow_examinations_before_trigger ON doc_flow_examinations;

 CREATE TRIGGER doc_flow_examinations_before_trigger
  BEFORE DELETE
  ON doc_flow_examinations
  FOR EACH ROW
  EXECUTE PROCEDURE doc_flow_examinations_process();
