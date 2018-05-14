-- Trigger: doc_flow_in_before_trigger on doc_flow_in

 DROP TRIGGER doc_flow_in_before_trigger ON doc_flow_in;

CREATE TRIGGER doc_flow_in_before_trigger
  BEFORE INSERT OR DELETE
  ON doc_flow_in
  FOR EACH ROW
  EXECUTE PROCEDURE doc_flow_in_process();

