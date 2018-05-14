-- Trigger: doc_flow_out_client_before_trigger on doc_flow_out_client

-- DROP TRIGGER doc_flow_out_client_before_trigger ON doc_flow_out_client;
/*
 CREATE TRIGGER doc_flow_out_client_before_trigger
  BEFORE DELETE
  ON doc_flow_out_client
  FOR EACH ROW
  EXECUTE PROCEDURE doc_flow_out_client_process();
*/  
  
  -- Trigger: doc_flow_out_client_after_trigger on doc_flow_out_client

-- DROP TRIGGER doc_flow_out_client_after_trigger ON doc_flow_out_client;

 CREATE TRIGGER doc_flow_out_client_after_trigger
  AFTER INSERT OR UPDATE
  ON doc_flow_out_client
  FOR EACH ROW
  EXECUTE PROCEDURE doc_flow_out_client_process();
