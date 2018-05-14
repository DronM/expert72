-- Trigger: document_templates_before_trigger on document_templates

-- DROP TRIGGER document_templates_before_trigger ON document_templates;

 CREATE TRIGGER document_templates_before_trigger
  BEFORE UPDATE OR DELETE
  ON document_templates
  FOR EACH ROW
  EXECUTE PROCEDURE document_templates_process();
