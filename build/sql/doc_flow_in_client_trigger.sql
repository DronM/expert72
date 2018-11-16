-- DROP TRIGGER doc_flow_in_client_before_trigger ON doc_flow_in_client;
/*
 CREATE TRIGGER doc_flow_in_client_before_trigger
  BEFORE INSERT OR DELETE
  ON doc_flow_in_client
  FOR EACH ROW
  EXECUTE PROCEDURE doc_flow_in_client_process();
*/  
 CREATE TRIGGER doc_flow_in_client_after_trigger
  AFTER INSERT
  ON doc_flow_in_client
  FOR EACH ROW
  EXECUTE PROCEDURE doc_flow_in_client_process();
    
