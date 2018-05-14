-- DROP TRIGGER doc_flow_registrations_after_trigger ON doc_flow_registrations;

 CREATE TRIGGER doc_flow_registrations_after_trigger
  AFTER INSERT OR UPDATE
  ON doc_flow_registrations
  FOR EACH ROW
  EXECUTE PROCEDURE doc_flow_registrations_process();
  
  -- DROP TRIGGER doc_flow_registrations_before_trigger ON doc_flow_registrations;
/*
 CREATE TRIGGER doc_flow_registrations_before_trigger
  BEFORE DELETE
  ON doc_flow_registrations
  FOR EACH ROW
  EXECUTE PROCEDURE doc_flow_registrations_process();
*/  
