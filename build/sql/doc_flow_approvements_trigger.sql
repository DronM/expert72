-- DROP TRIGGER doc_flow_approvements_after_trigger ON doc_flow_approvements;

 CREATE TRIGGER doc_flow_approvements_after_trigger
  AFTER INSERT OR UPDATE
  ON doc_flow_approvements
  FOR EACH ROW
  EXECUTE PROCEDURE doc_flow_approvements_process();
  
 DROP TRIGGER doc_flow_approvements_before_trigger ON doc_flow_approvements;

 CREATE TRIGGER doc_flow_approvements_before_trigger
  BEFORE DELETE OR INSERT OR UPDATE
  ON doc_flow_approvements
  FOR EACH ROW
  EXECUTE PROCEDURE doc_flow_approvements_process();
