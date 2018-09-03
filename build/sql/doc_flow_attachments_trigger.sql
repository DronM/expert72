-- Trigger: doc_flow_attachments_after_trigger on doc_flow_attachments

-- DROP TRIGGER doc_flow_attachments_after_trigger ON doc_flow_attachments;

 CREATE TRIGGER doc_flow_attachments_after_trigger
  AFTER UPDATE
  ON doc_flow_attachments
  FOR EACH ROW
  EXECUTE PROCEDURE doc_flow_attachments_process();
  
