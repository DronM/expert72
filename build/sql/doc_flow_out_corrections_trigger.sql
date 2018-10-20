--DROP TRIGGER doc_flow_out_corrections_after_trigger ON doc_flow_out_corrections;

 CREATE TRIGGER doc_flow_out_registrations_after_trigger
  AFTER INSERT
  ON doc_flow_out_corrections
  FOR EACH ROW
  EXECUTE PROCEDURE doc_flow_out_corrections_process();

