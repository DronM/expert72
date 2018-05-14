 DROP TRIGGER doc_flow_out_before_trigger ON doc_flow_out;

 CREATE TRIGGER doc_flow_out_before_trigger
  BEFORE INSERT OR UPDATE OR DELETE
  ON doc_flow_out
  FOR EACH ROW
  EXECUTE PROCEDURE doc_flow_out_process();
  
