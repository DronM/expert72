-- Trigger: application_document_files_trigger on application_document_files

 DROP TRIGGER application_document_files_before_trigger ON application_document_files;

CREATE TRIGGER application_document_files_before_trigger
  BEFORE INSERT OR UPDATE OR DELETE
  ON application_document_files
  FOR EACH ROW
  EXECUTE PROCEDURE application_document_files_process();

