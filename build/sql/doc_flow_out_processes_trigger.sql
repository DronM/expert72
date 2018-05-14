-- DROP TRIGGER doc_flow_out_processes_after_trigger ON doc_flow_out_processes;

 CREATE TRIGGER doc_flow_out_processes_after_trigger
  AFTER INSERT OR UPDATE
  ON doc_flow_out_processes
  FOR EACH ROW
  EXECUTE PROCEDURE doc_flow_out_processes_process();
  
  -- DROP TRIGGER doc_flow_out_processes_before_trigger ON doc_flow_out_processes;

 CREATE TRIGGER doc_flow_out_processes_before_trigger
  BEFORE DELETE
  ON doc_flow_out_processes
  FOR EACH ROW
  EXECUTE PROCEDURE doc_flow_out_processes_process();
