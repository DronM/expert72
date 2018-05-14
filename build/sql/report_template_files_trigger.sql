-- Trigger: report_template_files_before_trigger on public.report_template_files

-- DROP TRIGGER report_template_files_before_trigger ON public.report_template_files;

CREATE TRIGGER report_template_files_before_trigger
  BEFORE INSERT OR UPDATE
  ON public.report_template_files
  FOR EACH ROW
  EXECUTE PROCEDURE public.report_template_files_process();

