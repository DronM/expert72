-- Trigger: file_verifications_trigger on file_verifications

-- DROP TRIGGER file_verifications_before_trigger ON file_verifications;

CREATE TRIGGER file_verifications_before_trigger
  BEFORE DELETE
  ON file_verifications
  FOR EACH ROW
  EXECUTE PROCEDURE file_verifications_process();

