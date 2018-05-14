-- Trigger: doc_flow_approvement_templates_before_trigger on public.doc_flow_approvement_templates

-- DROP TRIGGER doc_flow_approvement_templates_before_trigger ON public.doc_flow_approvement_templates;

CREATE TRIGGER doc_flow_approvement_templates_before_trigger
  BEFORE INSERT OR UPDATE
  ON public.doc_flow_approvement_templates
  FOR EACH ROW
  EXECUTE PROCEDURE public.doc_flow_approvement_templates_process();

